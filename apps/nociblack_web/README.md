# NociBlacK Web

Site public officiel de la plateforme NociBlacK.

## Présentation

NociBlacK Web permet aux visiteurs de consulter le catalogue publié depuis l'application NociBlacK Admin.

Le site est responsive et accessible depuis :

* Mobile
* Tablette
* Desktop

Les politiques RLS publiques sont déployées et limitent la lecture aux données du
catalogue publiées. La connexion du client Web à Supabase reste à implémenter.

---

## Fonctionnalités V1

### Catalogue public

* Affichage des articles publiés
* Affichage des catégories actives
* Consultation des fiches produits
* Navigation responsive

### Recherche

* Recherche par catégorie
* Filtrage des articles
* Tri des résultats

### Médias

* Affichage de l'image principale
* Galerie jusqu'à 3 images par article
* Optimisation des performances

---

## Architecture

Le projet suit une architecture modulaire orientée fonctionnalités et couches.
La référence complète est disponible dans
[`docs/web/01-web-architecture.md`](../../docs/web/01-web-architecture.md).

```text
src/
├── app/
│   ├── providers/
│   └── router/
├── core/
│   ├── config/
│   ├── errors/
│   └── supabase/
├── features/
│   ├── home/
│   ├── catalog/
│   ├── categories/
│   ├── items/
│   └── contact/
├── shared/
│   ├── components/
│   ├── layouts/
│   ├── hooks/
│   └── styles/
└── main.tsx
```

Principes :

* composants React fonctionnels ;
* POO pour les entités, repositories, cas d'usage, services et mappers ;
* aucune requête Supabase dans les composants ;
* composants réutilisables et styles isolés ;
* aucun fichier supérieur à 500 lignes ;
* architecture créée progressivement selon les besoins réels.

---

## Technologies

### Frontend

* React
* TypeScript
* Vite
* React Router
* TanStack Query
* CSS Modules

### Backend

* Supabase

### Base de données

* PostgreSQL

### Stockage

* Supabase Storage

### Tests

* Vitest
* Testing Library
* jsdom

---

## Visibilité des données

Le site affiche uniquement :

```text
Articles PUBLISHED
Catégories actives
Images autorisées
```

Le site ne peut jamais accéder :

```text
Brouillons
Articles archivés
Profils administrateurs
Données privées
```

Toutes ces restrictions sont appliquées par les politiques RLS Supabase avant même
la connexion du site au catalogue.

---

## SEO

Objectifs :

* URL propres via slug
* Métadonnées optimisées
* Performance mobile
* Référencement naturel

Exemples :

```text
/catalogue

/categories/parfums

/articles/dior-sauvage-edp

/articles/nike-air-max-90
```

La V1 est une SPA statique adaptée à IONOS. Cette contrainte limite le SEO par
rapport à un rendu serveur et devra être réévaluée si le référencement devient
prioritaire.

---

## Performance

Objectifs :

* Chargement rapide
* Images WebP
* Lazy Loading
* Responsive Design
* Optimisation mobile first

---

## Développement

Installation :

```bash
npm install
```

Validation du code :

```bash
npm run lint
```

Tests automatisés :

```bash
npm test
```

Tests en surveillance :

```bash
npm run test:watch
```

Lancement :

```bash
npm run dev
```

Build production :

```bash
npm run build
```

Prévisualisation :

```bash
npm run preview
```

---

## Roadmap V2

Fonctionnalités envisagées :

* Comptes utilisateurs
* Favoris
* Panier
* Paiement en ligne
* Gestion des commandes
* Livraison

---

## Auteur

Thomas ORTA

NociBlacK © 2026
