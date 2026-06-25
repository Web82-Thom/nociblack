import { CatalogPage } from '../../../../catalog/presentation/pages/CatalogPage';
import styles from './HomePage.module.css';

export function HomePage() {
  return (
    <main className={styles.shell}>
      <section className={styles.intro} aria-labelledby="home-title">
        <h1 id="home-title" className={styles.title}>
          NociBlacK
        </h1>

        <p className={styles.subtitle}>
          Site public en préparation.
        </p>
      </section>

      <CatalogPage />
    </main>
  );
}