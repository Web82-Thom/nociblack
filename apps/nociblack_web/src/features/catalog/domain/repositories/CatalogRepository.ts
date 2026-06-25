import type { CatalogItem } from '../entities/CatalogItem';

export interface CatalogRepository {
  getPublishedItems(): Promise<CatalogItem[]>;
}