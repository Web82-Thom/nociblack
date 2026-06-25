import { supabase } from "../../../../core/supabase/supabaseClient";

import type { CatalogItem } from "../../domain/entities/CatalogItem";
import type { CatalogRepository } from "../../domain/repositories/CatalogRepository";

type CatalogItemRow = {
  id: string;
  title: string;
  slug: string;
  description: string | null;
  price_cents: number;
  stock_quantity: number;
  created_at: string;
  updated_at: string;
  category_id: string;
  categories: {
    name: string;
  } | null;

  item_images: {
    image_url: string;
    is_primary: boolean;
    display_order: number;
  }[];
};

function getPublicImageUrl(imagePath: string | null): string | null {
  if (!imagePath) return null;

  const normalizedPath = imagePath.replace(/^item-images\//, "");

  const { data } = supabase.storage
    .from("item-images")
    .getPublicUrl(normalizedPath);

  return data.publicUrl;
}

export class SupabaseCatalogRepository implements CatalogRepository {
  private mapCatalogItem(row: CatalogItemRow): CatalogItem {
    const orderedImages = [...row.item_images].sort(
      (leftImage, rightImage) =>
        leftImage.display_order - rightImage.display_order,
    );
    const primaryImage =
      orderedImages.find((image) => image.is_primary) ?? orderedImages[0];
    return {
      id: row.id,
      title: row.title,
      slug: row.slug,
      description: row.description,
      priceCents: row.price_cents,
      categoryId: row.category_id,
      categoryName: row.categories?.name ?? "",
      stockQuantity: row.stock_quantity,
      primaryImageUrl: getPublicImageUrl(primaryImage?.image_url ?? null),
      imageUrls: orderedImages
        .map((image) => getPublicImageUrl(image.image_url))
        .filter((imageUrl): imageUrl is string => imageUrl !== null),
      createdAt: row.created_at,
      updatedAt: row.updated_at,
    };
  }

  async getPublishedItems(): Promise<CatalogItem[]> {
    const { data, error } = await supabase
      .from("items")
      .select(
        `
        id,
        title,
        slug,
        description,
        price_cents,
        category_id,
        stock_quantity,
        created_at,
        updated_at,
        categories (
          name
        ),
        item_images (
          image_url,
          is_primary,
          display_order
        )
      `,
      )
      .eq("status", "PUBLISHED")
      .order("display_order", { ascending: true })
      .order("title", { ascending: true });

    if (error) {
      throw error;
    }

    const rows = (data ?? []) as unknown as CatalogItemRow[];

    return rows.map((row) => this.mapCatalogItem(row));
  }

  async getPublishedItemBySlug(slug: string): Promise<CatalogItem | null> {
    const { data, error } = await supabase
      .from("items")
      .select(
        `
      id,
      title,
      slug,
      description,
      price_cents,
      category_id,
      stock_quantity,
      created_at,
      updated_at,
      categories (
        name
      ),
      item_images (
        image_url,
        is_primary,
        display_order
      )
    `,
      )
      .eq("status", "PUBLISHED")
      .eq("slug", slug)
      .maybeSingle();

    if (error) {
      throw error;
    }

    if (!data) {
      return null;
    }
    const row = data as unknown as CatalogItemRow;

    return this.mapCatalogItem(row);
  }
}
