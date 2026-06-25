export interface CatalogItem {
  id: string;
  title: string;
  slug: string;
  description: string | null;
  priceCents: number;
  categoryId: string;
  categoryName: string;
  stockQuantity: number;
  primaryImageUrl: string | null;
  imageUrls: string[];
  createdAt: string;
  updatedAt: string;
}
