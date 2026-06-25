import type { CatalogItem } from '../../domain/entities/CatalogItem';
import { CatalogCard } from './CatalogCard';

type CatalogGridProps = {
  items: CatalogItem[];
};

export function CatalogGrid({
  items,
}: CatalogGridProps) {
  if (items.length === 0) {
    return <p>Aucun article disponible.</p>;
  }

  return (
    <section>
      {items.map((item) => (
        <CatalogCard
          key={item.id}
          item={item}
        />
      ))}
    </section>
  );
}