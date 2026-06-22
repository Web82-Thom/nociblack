# NociBlacK Web

Site public officiel de la plateforme NociBlacK.

## Présentation

NociBlacK Web permet aux visiteurs de consulter le catalogue publié depuis l'application NociBlacK Admin.

Le site est responsive et accessible depuis :

* Mobile
* Tablette
* Desktop

Les données sont récupérées depuis Supabase.

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

Le projet suit une architecture modulaire orientée fonctionnalités.

```text
src/
├── core/
├── shared/
├── features/
│   ├── home/
│   ├── catalog/
│   ├── category/
│   └── product/
├── components/
├── layouts/
└── routes/
```

Principes :

* Separation of Concerns
* Composants réutilisables
* Services isolés
* Architecture évolutive

---

## Technologies

### Frontend

* React
* TypeScript
* Vite

### Backend

* Supabase

### Base de données

* PostgreSQL

### Stockage

* Supabase Storage

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

Toutes les restrictions sont appliquées par les politiques RLS Supabase.

---

## SEO

Objectifs :

* URL propres via slug
* Métadonnées optimisées
* Performance mobile
* Référencement naturel

Exemples :

```text
/categorie/parfums

/article/dior-sauvage-edp

/article/nike-air-max-90
```

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
