import { defineCollection, z } from 'astro:content';
import { glob } from 'astro/loaders';

const testimonialsCollection = defineCollection({
  loader: glob({ pattern: '**/*.md', base: './src/content/testimonials' }),
  schema: z.object({
    title: z.string(),
    type: z.enum(['video', 'blog', 'social']),
    url: z.string().url(),
    author: z.string().optional(),
  }),
});

export const collections = {
  testimonials: testimonialsCollection,
};
