# NociBlacK

Application Android développée avec Flutter permettant la gestion du catalogue NociBlacK.

## Présentation

NociBlacK Admin est le back-office officiel de la plateforme NociBlacK.

L'application permet aux administrateurs de gérer :

* Les catégories
* Les articles
* Les images des articles
* La publication du catalogue

Les données sont hébergées sur Supabase et sécurisées par des politiques RLS (Row Level Security).

---

## Fonctionnalités V1

### Gestion des catégories

* Création de catégories
* Modification de catégories
* Archivage de catégories
* Ordre d'affichage configurable

### Gestion des articles

* Création d'articles
* Modification d'articles
* Archivage d'articles
* Gestion du stock
* Gestion du prix
* Gestion du SKU
* Publication et dépublication

### Gestion des médias

* Jusqu'à 3 images par article
* Image principale
* Compression avant upload
* Stockage Supabase Storage

### Gestion des rôles

#### SUPER_ADMIN

* Gestion des administrateurs
* Gestion des rôles
* Accès complet à la plateforme

#### ADMIN

* Gestion du catalogue
* Gestion des catégories
* Gestion des médias

---

## Architecture

Le projet suit une architecture orientée objet et une séparation stricte des responsabilités.

```text
lib/
├── core/
├── shared/
├── features/
│   ├── authentication/
│   ├── categories/
│   ├── items/
│   └── media/
├── widgets/
└── main.dart
```

Principes :

* Entities
* Repositories
* Services
* Use Cases
* Controllers
* Widgets réutilisables

Aucun fichier ne doit dépasser 500 lignes.

Objectif recommandé :

* 150 à 300 lignes par fichier

---

## Technologies

### Frontend

* Flutter
* Dart

### Backend

* Supabase
* PostgreSQL

### Authentification

* Supabase Auth

### Stockage

* Supabase Storage

---

## Statuts des articles

```text
DRAFT
PUBLISHED
ARCHIVED
```

### DRAFT

Visible uniquement aux administrateurs.

### PUBLISHED

Visible sur le site public.

### ARCHIVED

Conservé en base mais non visible publiquement.

---

## Structure des données

Tables principales :

```text
profiles
categories
items
item_images
```

---

## Storage

Buckets utilisés :

```text
item-images
brand-assets
```

Formats d'import autorisés :

```text
webp
jpg
jpeg
png
```

Les images importées sont converties et stockées au format WebP.

Limites :

```text
3 images maximum par article
2 Mo maximum par image
```

---

## Sécurité

La sécurité repose principalement sur Supabase RLS.

Le client Flutter n'est jamais considéré comme une source de confiance.

Toutes les opérations sensibles sont validées côté base de données.

---

## Environnement de développement

Création du projet :

```bash
flutter create --platforms=android --org fr.thomasorta --project-name nociblack .
```

Installation des dépendances :

```bash
flutter pub get
```

Lancement :

```bash
flutter run
```

---

## Méthodologie de développement

Chaque fonctionnalité suit le cycle suivant :

1. Analyse
2. Validation
3. Développement
4. Test manuel
5. Test automatisé
6. Commit Git

Aucune fonctionnalité n'est développée sans validation préalable.

---

## Auteur

Thomas ORTA

NociBlacK © 2026
