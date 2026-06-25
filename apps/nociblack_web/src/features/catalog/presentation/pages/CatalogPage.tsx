import { CatalogGrid } from '../components/CatalogGrid';
import { useCatalog } from '../../hooks/useCatalog';

export function CatalogPage() {
  const {
    items,
    isLoading,
    errorMessage,
  } = useCatalog();

  if (isLoading) {
    return <p>Chargement du catalogue...</p>;
  }

  if (errorMessage) {
    return <p>{errorMessage}</p>;
  }

  return <CatalogGrid items={items} />;
}