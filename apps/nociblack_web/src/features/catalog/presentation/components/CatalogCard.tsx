import type { CatalogItem } from '../../domain/entities/CatalogItem';

type CatalogCardProps = {
  item: CatalogItem;
};

export function CatalogCard({
  item,
}: CatalogCardProps) {
  return (
    <article>
      {item.primaryImageUrl && (
        <img
          src={item.primaryImageUrl}
          alt={item.title}
        />
      )}

      <h2>{item.title}</h2>

      <p>{item.categoryName}</p>

      {/*
        Prix volontairement masqué en V1.
        Conserver ce bloc pour l'activer facilement plus tard.

        <p>{(item.priceCents / 100).toFixed(2)} €</p>
      */}
    </article>
  );
}