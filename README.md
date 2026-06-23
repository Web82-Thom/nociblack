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

Fonctionnalités prévues :

* Consultation du catalogue
* Recherche par catégorie
* Affichage responsive
* Optimisation SEO

---

## Backend

Supabase constitue le backend principal.

Services retenus pour la V1 :

* PostgreSQL
* Authentication
* Row Level Security (RLS)
* Storage

État actuel : le schéma PostgreSQL initial est appliqué sur le projet hébergé et
validé par un test SQL transactionnel. Les politiques RLS et Storage restent à
implémenter dans des migrations séparées.

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
