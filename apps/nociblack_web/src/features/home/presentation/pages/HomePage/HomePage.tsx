import { CatalogPage } from "../../../../catalog/presentation/pages/CatalogPage";
import styles from "./HomePage.module.css";
import { useEffect } from "react";
import { useLocation } from "react-router";

export function HomePage() {
  const location = useLocation();

  useEffect(() => {
    if (!location.state?.scrollToCatalog) {
      return;
    }

    window.requestAnimationFrame(() => {
      setTimeout(() => {
        const catalogSection = document.getElementById("catalog");

        catalogSection?.scrollIntoView({
          behavior: "smooth",
          block: "start",
        });
      }, 100);
    });
  }, [location.state]);
  return (
    <div className={styles.page}>
      <header className={styles.header}>
        <a
          className={styles.brand}
          href="/"
          draggable={false}
          onDragStart={(event) => event.preventDefault()}
        >
          NociBlacK
        </a>

        <nav
          className={styles.nav}
          aria-label="Navigation principale"
          draggable={false}
          onDragStart={(event) => event.preventDefault()}
        >
          <a href="/">Accueil</a>
          <a href="#catalog">Articles</a>
          <a href="#contact">Contact</a>
        </nav>
      </header>

      <main className={styles.shell}>
        <section className={styles.intro} aria-labelledby="home-title">
          {/* <p className={styles.eyebrow}>Boutique en ligne</p> */}

          <h1 id="home-title" className={styles.title}>
            NociBlacK
          </h1>

          <p className={styles.subtitle}>L'élégance à portée de main.</p>

          <p className={styles.description}>
            Découvrez notre sélection de vêtements, chaussures, parfums,
            accessoires soigneusement sélectionnés.
          </p>

          <a
            className={styles.heroButton}
            href="#catalog"
            draggable={false}
            onDragStart={(event) => event.preventDefault()}
          >
            Découvrir la collection
          </a>
        </section>

        <section id="catalog" className={styles.catalogSection}>
          <CatalogPage />
        </section>
      </main>

      <footer id="contact" className={styles.footer}>
        <div className={styles.footerContent}>
          <div>
            <h2 className={styles.footerBrand}>NociBlacK</h2>
            <p className={styles.footerText}>
              Catalogue public de vêtements, chaussures, parfums et accessoires.
            </p>
          </div>

          <div
            className={styles.footerLinks}
            draggable={false}
            onDragStart={(event) => event.preventDefault()}
          >
            <a href="/">Accueil</a>
            <a href="#catalog">Articles</a>
            <a href="#contact">Contact</a>
          </div>
        </div>

        <p className={styles.footerCopyright}>
          © 2026 NociBlacK. Tous droits réservés.
        </p>
      </footer>
    </div>
  );
}
