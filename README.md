# NociBlacK

Plateforme de gestion de catalogue et de publication de contenu construite autour d'une architecture moderne Flutter + Supabase.

---

## Architecture du projet

```text
NOCIBLACK/
├── apps/
│   ├── nociblack_admin/
│   └── nociblack_web/
│
├── docs/
│   ├── building/
│   ├── database/
│   └── web/
│
├── supabase/
│   ├── migrations/
│   └── tests/database/
│
├── .github/
├── .agents/
├── .codex/
└── README.md
```

---

## Applications

### nociblack_admin

Application Flutter Android destinée aux administrateurs.

Fonctionnalités :

* Gestion des catégories
* Gestion des articles
* Gestion des images
* Publication du catalogue
* Administration métier

Technologies :

* Flutter
* Dart
* Supabase Auth
* Supabase Database
* Supabase Storage

---

### nociblack_web

Site public NociBlacK.

Fonctionnalités actuelles :

* Architecture React initialisée
* React Router configuré
* Variables d'environnement configurées
* Connexion Supabase validée
* Lecture des catégories validée

Fonctionnalités à venir :

* Consultation du catalogue
* Recherche par catégorie
* Fiches produits
* Affichage responsive complet
* Optimisation SEO

---

## Backend

Supabase constitue le backend principal.

Services retenus pour la V1 :

* PostgreSQL
* Authentication
* Row Level Security (RLS)
* Storage

État actuel : le schéma PostgreSQL, les politiques RLS et Storage sont appliqués sur
le projet hébergé. Les accès public, `ADMIN`, `SUPER_ADMIN` et administrateur
désactivé sont validés par des tests SQL transactionnels. L'application Flutter
Admin initialise Supabase, authentifie les administrateurs actifs, restaure leur
session et gère les catégories. Les articles peuvent être créés, modifiés,
archivés, consultés dans les archives, restaurés en brouillon ou supprimés
définitivement avec leurs images par un administrateur actif. Le backend Storage
accepte les images JPEG traitées sous `items/{itemId}/{uuid}.jpg`. React est
connecté à Supabase. Les images, la publication et le catalogue public restent à
implémenter.

---

## Documentation

La documentation fonctionnelle et technique est centralisée dans :

```text
docs/
```

Documentation base de données :

```text
docs/database/
├── 01-roles-and-permissions.md
├── 02-database-schema.md
├── 03-rls-policies.md
├── 04-storage-strategy.md
└── 05-business-rules.md
```

---

## Rôles

### SUPER_ADMIN

* Gestion des administrateurs
* Gestion des rôles
* Gestion complète de la plateforme

### ADMIN

* Gestion du catalogue
* Gestion des catégories
* Gestion des médias

---

## Statuts des articles

```text
DRAFT
PUBLISHED
ARCHIVED
```

---

## Méthodologie

Chaque évolution suit le processus :

1. Analyse
2. Validation
3. Documentation
4. Développement
5. Test manuel
6. Test automatisé
7. Commit Git

---

## Auteur

Thomas ORTA

NociBlacK © 2026
