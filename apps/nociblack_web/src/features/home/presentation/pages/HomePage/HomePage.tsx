import { CatalogPage } from "../../../../catalog/presentation/pages/CatalogPage";
import styles from "./HomePage.module.css";

export function HomePage() {
  return (
    <div className={styles.page}>
      <header className={styles.header}>
        <a className={styles.brand} href="/">
          NociBlacK
        </a>

        <nav className={styles.nav} aria-label="Navigation principale">
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

          <a className={styles.heroButton} href="#catalog">
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

          <div className={styles.footerLinks}>
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
