import { z, defineCollection } from 'astro:content';

const downloadsCollection = defineCollection({
  type: 'content',
  schema: z.object({
    version: z.string(),
    date: z.date(),
  }),
});

const testimonialsCollection = defineCollection({
  type: 'content',
  schema: z.object({
    title: z.string(),
    type: z.enum(['video', 'blog', 'social']),
    url: z.string().url(),
    author: z.string().optional(),
  }),
});

export const collections = {
  'downloads': downloadsCollection,
  'testimonials': testimonialsCollection,
};

