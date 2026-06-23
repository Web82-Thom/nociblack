# NociBlacK Supabase

Backend officiel de la plateforme NociBlacK.

Ce dossier contient toute la configuration liée à Supabase :

* Base de données PostgreSQL
* Authentification
* Politiques RLS
* Stockage des médias
* Migrations
* Fonctions SQL
* Configuration versionnée de la CLI Supabase

---

## Objectif

Supabase constitue la source de vérité de la plateforme NociBlacK.

Toutes les données métier sont stockées et sécurisées dans Supabase.

Les applications :

```text
apps/nociblack_admin
apps/nociblack_web
```

consomment les données via Supabase.

---

## Architecture

```text
supabase/
├── .gitignore
├── config.toml
├── migrations/        # Créé lors de la première migration
├── seed.sql           # Ajouté uniquement lorsqu'un jeu de données est validé
└── README.md
```

Les tables, fonctions, contraintes, politiques RLS et configurations Storage sont
versionnées dans les migrations SQL. Aucun dossier artificiel `policies/`,
`storage/` ou `functions/` n'est créé sans besoin réel.

---

## CLI et projet hébergé

Version de la CLI validée :

```text
Supabase CLI 2.107.0
```

La configuration du dépôt est initialisée et liée au projet Supabase hébergé.
La liaison locale est conservée dans `supabase/.temp/`, dossier ignoré par Git.

Commandes principales depuis la racine du dépôt :

```powershell
supabase login
supabase projects list
supabase link --project-ref <REFERENCE_ID>
```

Le token d'accès, le mot de passe PostgreSQL et la clé `service_role` ne doivent
jamais être ajoutés au dépôt, aux fichiers `.env` versionnés ou à la documentation.

---

## Pas d'environnement local Docker

La V1 utilise directement le projet Supabase hébergé.

Les commandes suivantes ne font pas partie du workflow actuel :

```text
supabase start
supabase stop
supabase db reset
```

La CLI est utilisée pour gérer la liaison, les migrations et les opérations sur le
projet distant. Toute migration doit être relue avant son exécution.

---

## Technologies

### Base de données

* PostgreSQL

### Authentification

* Supabase Auth

### Sécurité

* Row Level Security (RLS)

### Stockage

* Supabase Storage

---

## Modèle de données V1

Tables principales :

```text
profiles
categories
items
item_images
```

---

## Rôles

### SUPER_ADMIN

Accès complet :

* Gestion des administrateurs
* Gestion des rôles
* Gestion du catalogue
* Gestion des catégories
* Gestion des médias

---

### ADMIN

Accès métier :

* Gestion des catégories
* Gestion des articles
* Gestion des images

Restrictions :

* Aucun accès à la gestion des rôles
* Aucun accès à la gestion des comptes

---

## Statuts métier

Articles :

```text
DRAFT
PUBLISHED
ARCHIVED
```

---

## Relations principales

```text
profiles.id
    ↓
auth.users.id

categories.id
    ↓
items.category_id

items.id
    ↓
item_images.item_id
```

---

## Sécurité

La sécurité est assurée par les politiques RLS.

Principe fondamental :

```text
Aucune opération sensible ne repose uniquement sur Flutter ou le site web.
```

Toutes les autorisations sont vérifiées directement par PostgreSQL.

---

## Politiques RLS

### Public

Peut uniquement :

```text
Lire les catégories actives
Lire les articles publiés
Lire les images associées
```

---

### ADMIN

Peut :

```text
Créer des catégories
Modifier des catégories
Créer des articles
Modifier des articles
Gérer les images
```

Ne peut pas :

```text
Créer un administrateur
Modifier un rôle
Accéder à tous les profils
```

---

### SUPER_ADMIN

Peut :

```text
Gérer les comptes
Gérer les rôles
Gérer l'ensemble des données
```

---

## Storage

### Bucket item-images

Utilisé pour :

```text
Images des articles
```

Structure :

```text
item-images/
└── {item_id}/
    ├── image_1.webp
    ├── image_2.webp
    └── image_3.webp
```

Contraintes :

```text
Maximum 3 images
Maximum 2 Mo par image
Format recommandé : WebP
```

---

### Bucket brand-assets

Utilisé pour :

```text
Logos
Icônes
Éléments graphiques
```

Structure :

```text
brand-assets/
└── public/
```

---

## Documentation

Les décisions métier sont documentées dans :

```text
docs/database/
├── 01-roles-and-permissions.md
├── 02-database-schema.md
├── 03-rls-policies.md
├── 04-storage-strategy.md
└── 05-business-rules.md
```

Cette documentation constitue la référence officielle du projet.

---

## Workflow de développement

Toute évolution suit le processus :

```text
Analyse
→ Validation
→ Documentation
→ Migration
→ Développement
→ Test manuel
→ Test automatisé
→ Commit Git
```

---

## État actuel

Phase :

```text
Configuration Supabase initialisée et projet hébergé lié
```

Terminé :

```text
Création du projet Supabase
Installation de la CLI Supabase
Initialisation de la configuration du dépôt
Liaison avec le projet Supabase hébergé
```

À venir :

```text
Création des migrations
Création des politiques RLS
Création des buckets Storage
```

Aucune migration SQL n'est encore considérée comme définitive tant qu'elle n'a pas été validée.

---

## Auteur

Thomas ORTA

NociBlacK © 2026
