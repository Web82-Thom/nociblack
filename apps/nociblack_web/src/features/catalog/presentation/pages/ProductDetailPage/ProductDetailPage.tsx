import { Link, useParams, useNavigate } from "react-router";

import styles from "./ProductDetailPage.module.css";
import { useProductDetail } from "../../../hooks/useProductDetail";
import { ProductImageCarousel } from "../../components/ProductImageCarousel";

export function ProductDetailPage() {
  const navigate = useNavigate();
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
        <button
          type="button"
          className={styles.backLink}
          draggable={false}
          onDragStart={(event) => event.preventDefault()}
          onClick={() => {
            navigate("/", {
              state: {
                scrollToCatalog: true,
              },
            });
          }}
        >
          ← Retour au catalogue
        </button>

        <p>{errorMessage ?? "Article introuvable."}</p>
      </main>
    );
  }
  return (
    <main className={styles.page}>
      <button
        type="button"
        className={styles.backLink}
        draggable={false}
        onDragStart={(event) => event.preventDefault()}
        onClick={() => {
          navigate("/", {
            state: {
              scrollToCatalog: true,
            },
          });
        }}
      >
        ← Retour au catalogue
      </button>

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
