#!/usr/bin/env bash
# fetch-docs.sh
# Fetches user-facing docs from LrGeniusAI/docs/wiki and writes them
# to src/content/docs/ with frontmatter and rewritten internal links.
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
    Help-Ollama-Setup) echo "Help: Ollama Setup" ;;
    Help-LM-Studio-Setup) echo "Help: LM Studio Setup" ;;
    Google-Vertex-AI-Login) echo "Google Vertex AI Login" ;;
    Troubleshooting) echo "Troubleshooting" ;;
    *) echo "$1" ;;
  esac
}

# User-facing docs to include on the website.
# Dev docs (Backend-API, Feature-Priority-Decision, Image-Culling-Implementation-Plan, etc.) are excluded.
USER_DOCS=(
  FAQ
  Getting-Started
  Help-Analyze-and-Index
  Help-AI-Edit
  Help-Advanced-Search
  Help-Cull-Photos
  Help-People-Faces
  Help-Find-Similar
  Help-Keyword-Dedup-and-Declutter
  Help-Train-From-Edits
  Help-Choosing-AI-Model
  Help-Ollama-Setup
  Help-LM-Studio-Setup
  Google-Vertex-AI-Login
  Troubleshooting
)

GITHUB_BASE="https://raw.githubusercontent.com/LrGenius/LrGeniusAI/${BRANCH}/docs/wiki"

rewrite_links() {
  # Rewrite wiki-style relative links to /help/docs/<lowercase-slug>
  # Handles: [text](Slug) and [text](Slug#anchor)
  # Astro normalizes content IDs to lowercase, so links must also be lowercase.
  # Special-case slugs that aren't hosted as docs pages are mapped to GitHub URLs.
  python3 -c "
import sys, re

GITHUB_REPO = 'https://github.com/LrGenius/LrGeniusAI'
SLUG_OVERRIDES = {
    'project-readme': f'{GITHUB_REPO}#readme',
    'plugin-readme': f'{GITHUB_REPO}/blob/main/plugin/README.md',
}

def lower_slug(m):
    slug = m.group(1).lower()
    anchor = m.group(2) or ''
    if slug in SLUG_OVERRIDES:
        return f']({SLUG_OVERRIDES[slug]})'
    return f'](/help/docs/{slug}{anchor})'

content = sys.stdin.read()
result = re.sub(r'\]\(([A-Za-z][A-Za-z0-9_-]+)(#[^)]+)?\)', lower_slug, content)
print(result, end='')
"
}

for slug in "${USER_DOCS[@]}"; do
  echo -n "Fetching ${slug}.md ... "

  if [[ -n "${LOCAL_PATH}" ]]; then
    SRC="${LOCAL_PATH}/docs/wiki/${slug}.md"
    if [[ ! -f "${SRC}" ]]; then
      echo "SKIP (not found locally)"
      continue
    fi
    raw_content="$(cat "${SRC}")"
  else
    tmp_file="$(mktemp)"
    http_code=$(curl -sL -w "%{http_code}" "${GITHUB_BASE}/${slug}.md" -o "${tmp_file}")
    if [[ "${http_code}" != "200" ]]; then
      rm -f "${tmp_file}"
      echo "SKIP (HTTP ${http_code})"
      continue
    fi
    raw_content="$(cat "${tmp_file}")"
    rm -f "${tmp_file}"
  fi

  title="$(get_title "${slug}")"
  body="$(echo "${raw_content}" | rewrite_links)"

  {
    echo "---"
    printf 'title: "%s"\n' "${title}"
    echo "---"
    echo ""
    echo "${body}"
  } > "${DEST_DIR}/${slug}.md"

  echo "OK"
done

echo ""
echo "Docs written to ${DEST_DIR}"
