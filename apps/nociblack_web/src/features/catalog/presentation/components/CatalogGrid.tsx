import type { CatalogItem } from '../../domain/entities/CatalogItem';
import { CatalogCard } from './CatalogCard';

import styles from './CatalogGrid.module.css';

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
    <section className={styles.grid}>
      {items.map((item) => (
        <CatalogCard
          key={item.id}
          item={item}
        />
      ))}
    </section>
  );
}