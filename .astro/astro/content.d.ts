declare module 'astro:content' {
	interface RenderResult {
		Content: import('astro/runtime/server/index.js').AstroComponentFactory;
		headings: import('astro').MarkdownHeading[];
		remarkPluginFrontmatter: Record<string, any>;
	}
	interface Render {
		'.md': Promise<RenderResult>;
	}

	export interface RenderedContent {
		html: string;
		metadata?: {
			imagePaths: Array<string>;
			[key: string]: unknown;
		};
	}
}

declare module 'astro:content' {
	type Flatten<T> = T extends { [K: string]: infer U } ? U : never;

	export type CollectionKey = keyof AnyEntryMap;
	export type CollectionEntry<C extends CollectionKey> = Flatten<AnyEntryMap[C]>;

	export type ContentCollectionKey = keyof ContentEntryMap;
	export type DataCollectionKey = keyof DataEntryMap;

	type AllValuesOf<T> = T extends any ? T[keyof T] : never;
	type ValidContentEntrySlug<C extends keyof ContentEntryMap> = AllValuesOf<
		ContentEntryMap[C]
	>['slug'];

	/** @deprecated Use `getEntry` instead. */
	export function getEntryBySlug<
		C extends keyof ContentEntryMap,
		E extends ValidContentEntrySlug<C> | (string & {}),
	>(
		collection: C,
		// Note that this has to accept a regular string too, for SSR
		entrySlug: E,
	): E extends ValidContentEntrySlug<C>
		? Promise<CollectionEntry<C>>
		: Promise<CollectionEntry<C> | undefined>;

	/** @deprecated Use `getEntry` instead. */
	export function getDataEntryById<C extends keyof DataEntryMap, E extends keyof DataEntryMap[C]>(
		collection: C,
		entryId: E,
	): Promise<CollectionEntry<C>>;

	export function getCollection<C extends keyof AnyEntryMap, E extends CollectionEntry<C>>(
		collection: C,
		filter?: (entry: CollectionEntry<C>) => entry is E,
	): Promise<E[]>;
	export function getCollection<C extends keyof AnyEntryMap>(
		collection: C,
		filter?: (entry: CollectionEntry<C>) => unknown,
	): Promise<CollectionEntry<C>[]>;

	export function getEntry<
		C extends keyof ContentEntryMap,
		E extends ValidContentEntrySlug<C> | (string & {}),
	>(entry: {
		collection: C;
		slug: E;
	}): E extends ValidContentEntrySlug<C>
		? Promise<CollectionEntry<C>>
		: Promise<CollectionEntry<C> | undefined>;
	export function getEntry<
		C extends keyof DataEntryMap,
		E extends keyof DataEntryMap[C] | (string & {}),
	>(entry: {
		collection: C;
		id: E;
	}): E extends keyof DataEntryMap[C]
		? Promise<DataEntryMap[C][E]>
		: Promise<CollectionEntry<C> | undefined>;
	export function getEntry<
		C extends keyof ContentEntryMap,
		E extends ValidContentEntrySlug<C> | (string & {}),
	>(
		collection: C,
		slug: E,
	): E extends ValidContentEntrySlug<C>
		? Promise<CollectionEntry<C>>
		: Promise<CollectionEntry<C> | undefined>;
	export function getEntry<
		C extends keyof DataEntryMap,
		E extends keyof DataEntryMap[C] | (string & {}),
	>(
		collection: C,
		id: E,
	): E extends keyof DataEntryMap[C]
		? Promise<DataEntryMap[C][E]>
		: Promise<CollectionEntry<C> | undefined>;

	/** Resolve an array of entry references from the same collection */
	export function getEntries<C extends keyof ContentEntryMap>(
		entries: {
			collection: C;
			slug: ValidContentEntrySlug<C>;
		}[],
	): Promise<CollectionEntry<C>[]>;
	export function getEntries<C extends keyof DataEntryMap>(
		entries: {
			collection: C;
			id: keyof DataEntryMap[C];
		}[],
	): Promise<CollectionEntry<C>[]>;

	export function render<C extends keyof AnyEntryMap>(
		entry: AnyEntryMap[C][string],
	): Promise<RenderResult>;

	export function reference<C extends keyof AnyEntryMap>(
		collection: C,
	): import('astro/zod').ZodEffects<
		import('astro/zod').ZodString,
		C extends keyof ContentEntryMap
			? {
					collection: C;
					slug: ValidContentEntrySlug<C>;
				}
			: {
					collection: C;
					id: keyof DataEntryMap[C];
				}
	>;
	// Allow generic `string` to avoid excessive type errors in the config
	// if `dev` is not running to update as you edit.
	// Invalid collection names will be caught at build time.
	export function reference<C extends string>(
		collection: C,
	): import('astro/zod').ZodEffects<import('astro/zod').ZodString, never>;

	type ReturnTypeOrOriginal<T> = T extends (...args: any[]) => infer R ? R : T;
	type InferEntrySchema<C extends keyof AnyEntryMap> = import('astro/zod').infer<
		ReturnTypeOrOriginal<Required<ContentConfig['collections'][C]>['schema']>
	>;

	type ContentEntryMap = {
		"downloads": {
"v1.0.0.md": {
	id: "v1.0.0.md";
  slug: "v100";
  body: string;
  collection: "downloads";
  data: InferEntrySchema<"downloads">
} & { render(): Render[".md"] };
"v1.1.0.md": {
	id: "v1.1.0.md";
  slug: "v110";
  body: string;
  collection: "downloads";
  data: InferEntrySchema<"downloads">
} & { render(): Render[".md"] };
"v1.2.0.md": {
	id: "v1.2.0.md";
  slug: "v120";
  body: string;
  collection: "downloads";
  data: InferEntrySchema<"downloads">
} & { render(): Render[".md"] };
"v1.3.0.md": {
	id: "v1.3.0.md";
  slug: "v130";
  body: string;
  collection: "downloads";
  data: InferEntrySchema<"downloads">
} & { render(): Render[".md"] };
"v1.3.1.md": {
	id: "v1.3.1.md";
  slug: "v131";
  body: string;
  collection: "downloads";
  data: InferEntrySchema<"downloads">
} & { render(): Render[".md"] };
"v1.4.0.md": {
	id: "v1.4.0.md";
  slug: "v140";
  body: string;
  collection: "downloads";
  data: InferEntrySchema<"downloads">
} & { render(): Render[".md"] };
"v1.4.1.md": {
	id: "v1.4.1.md";
  slug: "v141";
  body: string;
  collection: "downloads";
  data: InferEntrySchema<"downloads">
} & { render(): Render[".md"] };
"v1.5.0.md": {
	id: "v1.5.0.md";
  slug: "v150";
  body: string;
  collection: "downloads";
  data: InferEntrySchema<"downloads">
} & { render(): Render[".md"] };
"v1.5.1.md": {
	id: "v1.5.1.md";
  slug: "v151";
  body: string;
  collection: "downloads";
  data: InferEntrySchema<"downloads">
} & { render(): Render[".md"] };
"v1.6.0.md": {
	id: "v1.6.0.md";
  slug: "v160";
  body: string;
  collection: "downloads";
  data: InferEntrySchema<"downloads">
} & { render(): Render[".md"] };
"v1.7.0.md": {
	id: "v1.7.0.md";
  slug: "v170";
  body: string;
  collection: "downloads";
  data: InferEntrySchema<"downloads">
} & { render(): Render[".md"] };
};
"testimonials": {
"1_yt-gwegner.md": {
	id: "1_yt-gwegner.md";
  slug: "1_yt-gwegner";
  body: string;
  collection: "testimonials";
  data: InferEntrySchema<"testimonials">
} & { render(): Render[".md"] };
"1_yt-pott_1.md": {
	id: "1_yt-pott_1.md";
  slug: "1_yt-pott_1";
  body: string;
  collection: "testimonials";
  data: InferEntrySchema<"testimonials">
} & { render(): Render[".md"] };
"1_yt-pott_2.md": {
	id: "1_yt-pott_2.md";
  slug: "1_yt-pott_2";
  body: string;
  collection: "testimonials";
  data: InferEntrySchema<"testimonials">
} & { render(): Render[".md"] };
"blog-fotokram-info.md": {
	id: "blog-fotokram-info.md";
  slug: "blog-fotokram-info";
  body: string;
  collection: "testimonials";
  data: InferEntrySchema<"testimonials">
} & { render(): Render[".md"] };
"blog-gwegner.md": {
	id: "blog-gwegner.md";
  slug: "blog-gwegner";
  body: string;
  collection: "testimonials";
  data: InferEntrySchema<"testimonials">
} & { render(): Render[".md"] };
"blog-maschke-academy.md": {
	id: "blog-maschke-academy.md";
  slug: "blog-maschke-academy";
  body: string;
  collection: "testimonials";
  data: InferEntrySchema<"testimonials">
} & { render(): Render[".md"] };
"blog-natur-focus-de.md": {
	id: "blog-natur-focus-de.md";
  slug: "blog-natur-focus-de";
  body: string;
  collection: "testimonials";
  data: InferEntrySchema<"testimonials">
} & { render(): Render[".md"] };
"blog-naturfotografie-kruse-de.md": {
	id: "blog-naturfotografie-kruse-de.md";
  slug: "blog-naturfotografie-kruse-de";
  body: string;
  collection: "testimonials";
  data: InferEntrySchema<"testimonials">
} & { render(): Render[".md"] };
"social-dslr-forum-de.md": {
	id: "social-dslr-forum-de.md";
  slug: "social-dslr-forum-de";
  body: string;
  collection: "testimonials";
  data: InferEntrySchema<"testimonials">
} & { render(): Render[".md"] };
"social-reddit-UndeadCaesar.md": {
	id: "social-reddit-UndeadCaesar.md";
  slug: "social-reddit-undeadcaesar";
  body: string;
  collection: "testimonials";
  data: InferEntrySchema<"testimonials">
} & { render(): Render[".md"] };
};

	};

	type DataEntryMap = {
		
	};

	type AnyEntryMap = ContentEntryMap & DataEntryMap;

	export type ContentConfig = typeof import("../../src/content/config.js");
}
