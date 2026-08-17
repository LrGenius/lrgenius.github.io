import { defineConfig } from 'astro/config';
import sitemap from '@astrojs/sitemap';

// https://astro.build/config
export default defineConfig({
  site: 'https://lrgenius.com',
  integrations: [
    sitemap({
      filter: (page) => {
        // Exclude legacy /help/[slug]/ redirects (keep /help/ index and /help/docs/...)
        if (/\/help\/[^/]+\/$/.test(page) && !page.includes('/help/docs/')) return false;
        // Vertex AI support was removed in August 2026. The page stays reachable
        // so old links do not 404, but it should not be advertised in search.
        if (page.includes('/help/docs/google-vertex-ai-login')) return false;
        return true;
      },
    }),
  ],
  i18n: {
    defaultLocale: 'en',
    locales: ['en'],
    routing: {
      prefixDefaultLocale: false,
    }
  }
});


