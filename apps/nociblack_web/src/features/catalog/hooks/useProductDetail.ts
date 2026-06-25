import { useEffect, useState } from "react";

import type { CatalogItem } from "../domain/entities/CatalogItem";
import { SupabaseCatalogRepository } from "../domain/repositories/SupabaseCatalogRepository";

const catalogRepository = new SupabaseCatalogRepository();

type UseProductDetailResult = {
  item: CatalogItem | null;
  isLoading: boolean;
  errorMessage: string | null;
};

export function useProductDetail(slug: string | undefined): UseProductDetailResult {
  const [item, setItem] = useState<CatalogItem | null>(null);
  const [isLoading, setIsLoading] = useState(true);
  const [errorMessage, setErrorMessage] = useState<string | null>(null);

  useEffect(() => {
    async function loadProductDetail(): Promise<void> {
      if (!slug) {
        setItem(null);
        setIsLoading(false);
        setErrorMessage("Article introuvable.");
        return;
      }

      try {
        setIsLoading(true);
        setErrorMessage(null);

        const publishedItem = await catalogRepository.getPublishedItemBySlug(slug);

        if (!publishedItem) {
          setItem(null);
          setErrorMessage("Article introuvable.");
          return;
        }

        setItem(publishedItem);
      } catch {
        setItem(null);
        setErrorMessage("Impossible de charger l'article.");
      } finally {
        setIsLoading(false);
      }
    }

    loadProductDetail();
  }, [slug]);

  return {
    item,
    isLoading,
    errorMessage,
  };
}