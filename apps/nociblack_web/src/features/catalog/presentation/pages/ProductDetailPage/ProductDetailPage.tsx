import { Link, useParams } from "react-router";

import styles from "./ProductDetailPage.module.css";
import { useProductDetail } from "../../../hooks/useProductDetail";
import { ProductImageCarousel } from "../../components/ProductImageCarousel";

export function ProductDetailPage() {
  const { slug } = useParams();
  const { item, isLoading, errorMessage } = useProductDetail(slug);
  console.log("Product detail item:", item);
  if (isLoading) {
    return (
      <main className={styles.page}>
        <p>Chargement...</p>
      </main>
    );
  }

  if (errorMessage || !item) {
    return (
      <main className={styles.page}>
        <Link className={styles.backLink} to="/">
          ← Retour au catalogue
        </Link>

        <p>{errorMessage ?? "Article introuvable."}</p>
      </main>
    );
  }
  return (
    <main className={styles.page}>
      <Link className={styles.backLink} to="/">
        ← Retour au catalogue
      </Link>

      <section className={styles.product}>
        <div className={styles.imageWrapper}>
          <ProductImageCarousel imageUrls={item.imageUrls} title={item.title} />
        </div>

        <div className={styles.content}>
          <p className={styles.category}>{item.categoryName}</p>

          <h1 className={styles.title}>{item.title}</h1>

          <p className={styles.description}>
            {item.description ?? "Aucune description"}{" "}
          </p>

          <div className={styles.infoBox}>
            <span>Slug produit</span>
            <strong>{slug}</strong>
          </div>
        </div>
      </section>
    </main>
  );
}
