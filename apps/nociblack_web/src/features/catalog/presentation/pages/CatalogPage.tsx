import { CatalogGrid } from "../components/CatalogGrid";
import { useCatalog } from "../../hooks/useCatalog";

import styles from "./CatalogPage.module.css";

export function CatalogPage() {
  const { items, isLoading, errorMessage } = useCatalog();

  if (isLoading) {
    return <p className={styles.message}>Chargement du catalogue...</p>;
  }

  if (errorMessage) {
    return <p className={styles.message}>{errorMessage}</p>;
  }

  return (
    <div className={styles.layout}>
      <aside className={styles.filters} aria-label="Recherche catalogue">
        <h2 className={styles.filtersTitle}>Recherche</h2>

        <label className={styles.field}>
          <span>Rechercher un article</span>
          <input type="search" placeholder="Ex : parfum, basket..." />
        </label>

        <div className={styles.categories}>
          <h3>Catégories</h3>

          <ul className={styles.categoryList}>
            <li className={styles.activeCategory}>Tous les articles</li>

            <li>Parfums</li>

            <li>Chaussures</li>

            <li>Vêtements</li>
          </ul>
        </div>
      </aside>

      <section className={styles.products} aria-label="Articles disponibles">
        <CatalogGrid items={items} />
      </section>
    </div>
  );
}
