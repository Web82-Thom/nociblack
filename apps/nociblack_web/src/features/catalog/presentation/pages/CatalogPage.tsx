import { useState } from "react";

import { CatalogGrid } from "../components/CatalogGrid";
import { useCatalog } from "../../hooks/useCatalog";
import { useCategories } from "../../hooks/useCategories";

import styles from "./CatalogPage.module.css";

export function CatalogPage() {
  const { items, isLoading, errorMessage } = useCatalog();
  const {
    categories,
    isLoading: areCategoriesLoading,
    errorMessage: categoriesErrorMessage,
  } = useCategories();
  const [searchQuery, setSearchQuery] = useState("");
  const [selectedCategoryName, setSelectedCategoryName] = useState<
    string | null
  >(null);

  const normalizedSearchQuery = searchQuery.trim().toLowerCase();

  const categoryCounts = new Map<string, number>();

  items.forEach((item) => {
    const currentCount = categoryCounts.get(item.categoryName) ?? 0;

    categoryCounts.set(item.categoryName, currentCount + 1);
  });

  const filteredItems = items.filter((item) => {
    const title = item.title.toLowerCase();
    const description = item.description?.toLowerCase() ?? "";
    const category = item.categoryName.toLowerCase();

    const matchesSearch =
      title.includes(normalizedSearchQuery) ||
      description.includes(normalizedSearchQuery) ||
      category.includes(normalizedSearchQuery);

    const matchesCategory =
      selectedCategoryName === null ||
      item.categoryName === selectedCategoryName;

    return matchesSearch && matchesCategory;
  });

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
          <input
            type="search"
            placeholder="Ex : parfum, basket..."
            value={searchQuery}
            onChange={(event) => setSearchQuery(event.target.value)}
          />
        </label>

        <div className={styles.categories}>
          <h3>Catégories</h3>

          <ul className={styles.categoryList}>
            <li
              className={
                selectedCategoryName === null
                  ? styles.activeCategory
                  : undefined
              }
              onClick={() => setSelectedCategoryName(null)}
            >
              Tous les articles ({items.length})
            </li>

            {areCategoriesLoading ? (
              <li>Chargement...</li>
            ) : categoriesErrorMessage ? (
              <li>{categoriesErrorMessage}</li>
            ) : (
              categories.map((category) => (
                <li
                  key={category.id}
                  className={
                    selectedCategoryName === category.name
                      ? styles.activeCategory
                      : undefined
                  }
                  onClick={() => setSelectedCategoryName(category.name)}
                >
                  {category.name} ({categoryCounts.get(category.name) ?? 0})
                </li>
              ))
            )}
          </ul>
        </div>
      </aside>

      <section className={styles.products} aria-label="Articles disponibles">
        {filteredItems.length === 0 ? (
          <p className={styles.emptyMessage}>Aucun article trouvé.</p>
        ) : (
          <CatalogGrid items={filteredItems} />
        )}
      </section>
    </div>
  );
}
