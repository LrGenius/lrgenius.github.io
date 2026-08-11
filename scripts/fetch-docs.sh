#!/usr/bin/env bash
# fetch-docs.sh
# Fetches user-facing docs from LrGeniusAI/docs/wiki and writes them
# to src/content/docs/ with frontmatter and rewritten internal links.
#
# Every page in docs/wiki is published *except* those matching EXCLUDE_GLOBS.
# It used to be the other way round — an explicit allowlist — which meant a new
# wiki page silently 404'd on the site until someone remembered to add it here.
#
# Usage:
#   bash scripts/fetch-docs.sh [branch]          # fetch from GitHub
#   bash scripts/fetch-docs.sh --local <path>    # copy from local repo

set -euo pipefail

BRANCH="${1:-main}"
LOCAL_PATH=""

if [[ "${BRANCH}" == "--local" ]]; then
  LOCAL_PATH="${2:-}"
  if [[ -z "${LOCAL_PATH}" ]]; then
    echo "Usage: $0 --local <path-to-LrGeniusAI-repo>"
    exit 1
  fi
  echo "Using local repo: ${LOCAL_PATH}"
fi

DEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/src/content/docs"
mkdir -p "${DEST_DIR}"

# Pages that exist in the wiki but do not belong on the website.
#   Dev-*       developer documentation (backend API, implementation plans, and
#               the README-derived pages, which are better read on GitHub)
#   Home        the wiki's own landing page; /help is the website's version
#   _*          wiki special pages (_Sidebar, _Footer)
EXCLUDE_GLOBS=(
  'Dev-*'
  'Home'
  '_*'
)

is_excluded() {
  local slug="$1" pattern
  for pattern in "${EXCLUDE_GLOBS[@]}"; do
    # shellcheck disable=SC2053 # deliberate glob match, not a string compare
    [[ "${slug}" == ${pattern} ]] && return 0
  done
  return 1
}

# Titles for pages whose file name does not make a good title on its own.
# Anything not listed falls back to the page's own `# ` heading, so a new page
# needs no entry here.
get_title() {
  case "$1" in
    FAQ) echo "FAQ — Frequently Asked Questions" ;;
    Getting-Started) echo "Getting Started" ;;
    Help-Analyze-and-Index) echo "Help: Analyze and Index" ;;
    Help-AI-Edit) echo "Help: AI Edit Photos" ;;
    Help-Advanced-Search) echo "Help: Advanced Search" ;;
    Help-Cull-Photos) echo "Help: Cull Photos" ;;
    Help-People-Faces) echo "Help: People & Faces" ;;
    Help-Find-Similar) echo "Help: Find Similar Images" ;;
    Help-Keyword-Dedup-and-Declutter) echo "Help: Keyword Deduplication and De-Clutter" ;;
    Help-Train-From-Edits) echo "Help: Save Edits as AI Training Examples" ;;
    Help-Choosing-AI-Model) echo "Help: Choosing an AI Model" ;;
    Help-Local-AI-Models) echo "Help: Built-In Local AI Models" ;;
    Help-Ollama-Setup) echo "Help: Ollama Setup" ;;
    Help-LM-Studio-Setup) echo "Help: LM Studio Setup" ;;
    Google-Vertex-AI-Login) echo "Google Vertex AI Login" ;;
    Troubleshooting) echo "Troubleshooting" ;;
    *) echo "" ;;
  esac
}

# First `# ` heading of a page, used when get_title has no entry.
# `*` rather than `\+`: the latter is a GNU extension that BSD sed treats as a
# literal plus, which silently matches nothing on macOS.
title_from_heading() {
  sed -n 's/^# *//p' "$1" | head -n 1
}

TMP_DIR="$(mktemp -d)"
cleanup() {
  rm -rf "${TMP_DIR}"
}
trap cleanup EXIT

if [[ -n "${LOCAL_PATH}" ]]; then
  SRC_DIR="${LOCAL_PATH}/docs/wiki"
  if [[ ! -d "${SRC_DIR}" ]]; then
    echo "No docs/wiki directory in ${LOCAL_PATH}"
    exit 1
  fi
else
  # One tarball instead of a request per page: it cannot half-succeed, and it
  # is not subject to the unauthenticated API rate limit that a contents-API
  # listing would be on a shared runner.
  echo "Downloading LrGeniusAI@${BRANCH} ..."
  TARBALL="${TMP_DIR}/repo.tar.gz"
  http_code=$(curl -sL -w "%{http_code}" -o "${TARBALL}" \
    "https://codeload.github.com/LrGenius/LrGeniusAI/tar.gz/${BRANCH}")
  if [[ "${http_code}" != "200" ]]; then
    echo "Failed to download LrGeniusAI@${BRANCH} (HTTP ${http_code})"
    exit 1
  fi
  # Extracted whole rather than filtered to docs/wiki: the archive is ~1 MB,
  # and selecting paths portably would mean branching on GNU tar vs bsdtar
  # (--wildcards exists only on the former).
  tar -xzf "${TARBALL}" -C "${TMP_DIR}"
  SRC_DIR="$(find "${TMP_DIR}" -type d -path '*/docs/wiki' -print -quit)"
  if [[ -z "${SRC_DIR}" ]]; then
    echo "Downloaded archive contains no docs/wiki directory"
    exit 1
  fi
fi

rewrite_links() {
  # Rewrite wiki-style relative links to /help/docs/<lowercase-slug>
  # Handles: [text](Slug) and [text](Slug#anchor)
  # Astro normalizes content IDs to lowercase, so links must also be lowercase.
  # Special-case slugs that aren't hosted as docs pages are mapped to GitHub URLs.
  python3 -c "
import sys, re

GITHUB_REPO = 'https://github.com/LrGenius/LrGeniusAI'
# Slugs that are not hosted as docs pages (see EXCLUDE_GLOBS) are mapped to
# GitHub instead, so the link resolves rather than 404ing. The wiki pages carry
# a 'Dev-' prefix; the un-prefixed keys are the older names and are kept so
# historical links keep working.
SLUG_OVERRIDES = {
    'dev-project-readme': f'{GITHUB_REPO}#readme',
    'project-readme': f'{GITHUB_REPO}#readme',
    'dev-plugin-readme': f'{GITHUB_REPO}/blob/main/plugin/README.md',
    'plugin-readme': f'{GITHUB_REPO}/blob/main/plugin/README.md',
    'dev-server-readme': f'{GITHUB_REPO}/blob/main/server-rs/README.md',
    'server-readme': f'{GITHUB_REPO}/blob/main/server-rs/README.md',
}
# Anything else excluded from the site is sent to the wiki page of the same
# name, which always exists.
EXCLUDED_PREFIXES = ('dev-',)

def lower_slug(m):
    slug = m.group(1).lower()
    anchor = m.group(2) or ''
    if slug in SLUG_OVERRIDES:
        return f']({SLUG_OVERRIDES[slug]})'
    if slug.startswith(EXCLUDED_PREFIXES):
        return f']({GITHUB_REPO}/wiki/{m.group(1)}{anchor})'
    return f'](/help/docs/{slug}{anchor})'

content = sys.stdin.read()
result = re.sub(r'\]\(([A-Za-z][A-Za-z0-9_-]+)(#[^)]+)?\)', lower_slug, content)
print(result, end='')
"
}

published=0
skipped=0

for src_file in "${SRC_DIR}"/*.md; do
  [[ -e "${src_file}" ]] || continue
  slug="$(basename "${src_file}" .md)"

  if is_excluded "${slug}"; then
    echo "Skipping ${slug}.md (excluded)"
    skipped=$((skipped + 1))
    continue
  fi

  echo -n "Publishing ${slug}.md ... "

  title="$(get_title "${slug}")"
  if [[ -z "${title}" ]]; then
    title="$(title_from_heading "${src_file}")"
  fi
  if [[ -z "${title}" ]]; then
    title="${slug//-/ }"
  fi

  body="$(rewrite_links < "${src_file}")"

  {
    echo "---"
    # Escape double quotes so a title containing one cannot break the YAML.
    printf 'title: "%s"\n' "${title//\"/\\\"}"
    echo "---"
    echo ""
    echo "${body}"
  } > "${DEST_DIR}/${slug}.md"

  published=$((published + 1))
  echo "OK"
done

# A page removed from (or renamed in) the wiki must not linger in a stale
# working copy and get published from there.
for existing in "${DEST_DIR}"/*.md; do
  [[ -e "${existing}" ]] || continue
  slug="$(basename "${existing}" .md)"
  if [[ ! -f "${SRC_DIR}/${slug}.md" ]] || is_excluded "${slug}"; then
    echo "Removing stale ${slug}.md"
    rm -f "${existing}"
  fi
done

if [[ "${published}" -eq 0 ]]; then
  echo "No docs were published — refusing to leave the site without help pages"
  exit 1
fi

echo ""
echo "Published ${published} page(s), skipped ${skipped}, to ${DEST_DIR}"
