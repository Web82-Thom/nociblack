import { Link } from 'react-router'
import styles from './NotFoundPage.module.css'

export function NotFoundPage() {
  return (
    <main className={styles.shell}>
      <section className={styles.content} aria-labelledby="not-found-title">
        <p className={styles.code}>404</p>

        <h1 id="not-found-title" className={styles.title}>
          Page introuvable
        </h1>

        <p className={styles.description}>
          La page demandée n’existe pas ou n’est plus disponible.
        </p>

        <Link className={styles.link} to="/">
          Retour à l’accueil
        </Link>
      </section>
    </main>
  )
}