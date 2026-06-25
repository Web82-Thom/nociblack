import { useCallback, useEffect, useState } from 'react';

import type { CatalogItem } from '../domain/entities/CatalogItem';
import { SupabaseCatalogRepository } from '../domain/repositories/SupabaseCatalogRepository';

const catalogRepository = new SupabaseCatalogRepository();

export function useCatalog() {
  const [items, setItems] = useState<CatalogItem[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [errorMessage, setErrorMessage] = useState<string | null>(null);

  const reload = useCallback(async () => {
    try {
      setErrorMessage(null);

      const publishedItems = await catalogRepository.getPublishedItems();

      setItems(publishedItems);
    } catch {
      setErrorMessage('Impossible de charger le catalogue.');
    } finally {
      setIsLoading(false);
    }
  }, []);

  useEffect(() => {
  async function loadInitialCatalog() {
    await reload();
  }

  void loadInitialCatalog();
}, [reload]);

  return {
    items,
    isLoading,
    errorMessage,
    reload,
  };
}