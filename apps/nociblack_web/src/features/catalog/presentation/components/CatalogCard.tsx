import type { CatalogItem } from "../../domain/entities/CatalogItem";
import { Link } from "react-router";

import styles from "./CatalogCard.module.css";

type CatalogCardProps = {
  item: CatalogItem;
};

export function CatalogCard({ item }: CatalogCardProps) {
  return (
    <article className={styles.card}>
      <div className={styles.imageContainer}>
        {item.primaryImageUrl ? (
          <img
            className={styles.image}
            src={item.primaryImageUrl}
            alt={item.title}
            draggable={false}
          />
        ) : (
          <div className={styles.imagePlaceholder}>Aucune image</div>
        )}
      </div>

      <div className={styles.content}>
        <h2 className={styles.title}>{item.title}</h2>

        <p className={styles.category}>{item.categoryName}</p>

        {/*
          Prix volontairement masqué en V1.

          <p className={styles.price}>
            {(item.priceCents / 100).toFixed(2)} €
          </p>
        */}

        <Link
          className={styles.button}
          to={`/articles/${item.slug}`}
          draggable={false}
          onDragStart={(event) => event.preventDefault()}
        >
          Voir le produit
        </Link>
      </div>
    </article>
  );
}
