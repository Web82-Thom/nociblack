import { supabase } from '../../../../core/supabase/supabaseClient';

import type { CatalogItem } from '../../domain/entities/CatalogItem';
import type { CatalogRepository } from '../../domain/repositories/CatalogRepository';

type CatalogItemRow = {
  id: string;
  title: string;
  slug: string;
  description: string | null;
  price_cents: number;
  stock_quantity: number;
  created_at: string;
  updated_at: string;

  categories: {
    name: string;
  }[];

  item_images: {
    image_url: string;
    is_primary: boolean;
  }[];
};

function getPublicImageUrl(imagePath: string | null): string | null {
  if (!imagePath) return null;

  const normalizedPath = imagePath.replace(/^item-images\//, '');

  const { data } = supabase.storage
    .from('item-images')
    .getPublicUrl(normalizedPath);

  return data.publicUrl;
}

export class SupabaseCatalogRepository implements CatalogRepository {
  async getPublishedItems(): Promise<CatalogItem[]> {
    const { data, error } = await supabase
      .from('items')
      .select(`
        id,
        title,
        slug,
        description,
        price_cents,
        stock_quantity,
        created_at,
        updated_at,
        categories (
          name
        ),
        item_images (
          image_url,
          is_primary
        )
      `)
      .eq('status', 'PUBLISHED')
      .order('display_order', { ascending: true })
      .order('title', { ascending: true });

    if (error) {
      throw error;
    }

    const rows = (data ?? []) as CatalogItemRow[];

    return rows.map((row) => {
      const primaryImage =
        row.item_images.find((image) => image.is_primary) ??
        row.item_images[0];

      return {
        id: row.id,
        title: row.title,
        slug: row.slug,
        description: row.description,
        priceCents: row.price_cents,

        categoryId: '',
        categoryName: row.categories[0]?.name ?? '',

        stockQuantity: row.stock_quantity,

        primaryImageUrl: getPublicImageUrl(primaryImage?.image_url ?? null),

        createdAt: row.created_at,
        updatedAt: row.updated_at,
      };
    });
  }
}