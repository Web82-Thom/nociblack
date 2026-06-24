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
L'application Flutter Admin est connectée et opérationnelle.
L'application React Web est connectée et validée pour la lecture publique.

---

## Architecture

```text
supabase/
├── .gitignore
├── config.toml
├── migrations/
│   ├── 20260623112454_create_initial_schema.sql
│   ├── 20260623124112_create_rls_policies.sql
│   └── 20260623130453_create_storage_configuration.sql
├── tests/
│   └── database/
│       ├── initial_schema_test.sql
│       ├── public_rls_test.sql
│       ├── admin_rls_test.sql
│       └── storage_rls_test.sql
├── seed.sql           # Futur : uniquement après validation d'un jeu de données
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

Commandes de contrôle et de déploiement depuis la racine du dépôt :

```powershell
supabase migration list --linked
supabase db push --dry-run --linked
supabase db push
supabase db lint --linked --level warning
```

Le `dry-run` doit toujours précéder un `db push`. L'avertissement relatif à Docker
et au cache `pg-delta` n'empêche pas l'application d'une migration sur le projet
hébergé.

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

La RLS est activée sur les quatre tables publiques. Les politiques déployées
séparent les accès `anon`, `ADMIN` et `SUPER_ADMIN`. Un administrateur désactivé
perd immédiatement tous ses droits privés.

Les inscriptions Auth publiques sont désactivées. Les comptes administratifs sont
créés manuellement depuis le tableau de bord Supabase.

Principe fondamental :

```text
Aucune opération sensible ne repose uniquement sur Flutter ou le site web.
```

Toutes les autorisations sont vérifiées directement par PostgreSQL.

---

## Politiques RLS

Les droits ci-dessous sont déployés et validés sur le projet Supabase hébergé.

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

Les buckets et leurs politiques sont déployés et validés sur le projet Supabase hébergé.

### Bucket `item-images`

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
Format autorisé : WebP
```

---

### Bucket `brand-assets`

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
Contraintes :

```text
Maximum 2 Mo par fichier
Formats autorisés : PNG et WebP
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

### Tests de la base de données

Les tests de régression se trouvent dans :

```text
supabase/tests/database/
├── initial_schema_test.sql
├── public_rls_test.sql
├── admin_rls_test.sql
└── storage_rls_test.sql
```

Sans environnement Docker local, ils sont exécutés intégralement depuis le SQL Editor Supabase. Chaque test ouvre une transaction et termine par `rollback;` afin de ne conserver aucune donnée de test.

Le test administrateur nécessite au moins un profil `SUPER_ADMIN` actif et un
profil `ADMIN` actif. Aucun UUID ni mot de passe n'est enregistré dans Git.

Résultat attendu :

```text
Success. No rows returned
```

---

## État actuel

Phase :

```text
Backend V1 validé et authentification Flutter Admin intégrée
```

Terminé :

```text
Création du projet Supabase
Installation de la CLI Supabase
Initialisation de la configuration du dépôt
Liaison avec le projet Supabase hébergé
Création et application de la migration initiale du schéma
Création et application de la migration RLS
Création des profils SUPER_ADMIN et ADMIN
Création des buckets et politiques Storage
Validation des accès Storage public, ADMIN et SUPER_ADMIN
Désactivation des inscriptions Auth publiques
Validation du schéma avec Supabase DB lint
Validation du test SQL de régression transactionnel
Validation des accès public, ADMIN, SUPER_ADMIN et administrateur désactivé
Initialisation du SDK Supabase dans l'application Flutter Admin
Validation du démarrage Android et des tests Flutter
Authentification des profils ADMIN et SUPER_ADMIN actifs
Validation de la restauration de session et de la déconnexion
Lecture des articles courants et archivés depuis l'application Flutter Admin
Lecture des catégories actives depuis l'application Flutter Admin
Création des catégories depuis l'application Flutter Admin
Modification, archivage et réactivation des catégories depuis Flutter Admin
Création des articles brouillons depuis l'application Flutter Admin
Connexion de l'application React à Supabase
Lecture publique des catégories depuis React
Validation des variables d'environnement Vite
Validation du SDK Supabase JS
```

À venir :

```text
Modification des articles depuis Flutter Admin
Gestion des images des articles
Publication des articles
Catalogue public React
Fiches produits
Recherche et filtrage
```

---

## Auteur

Thomas ORTA

NociBlacK © 2026
