import { defineConfig } from 'astro/config';
import sitemap from '@astrojs/sitemap';

// https://astro.build/config
export default defineConfig({
  site: 'https://lrgenius.github.io',
  integrations: [sitemap()],
  i18n: {
    defaultLocale: 'en',
    locales: ['en'],
    routing: {
      prefixDefaultLocale: false,
    }
  }
});


