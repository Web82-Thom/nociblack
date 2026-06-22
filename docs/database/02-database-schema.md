# NociBlacK — Schéma de base de données V1

## 1. Objet

Ce document décrit le modèle PostgreSQL validé pour NociBlacK V1. Il reste
indépendant de toute migration SQL afin de permettre sa validation fonctionnelle
avant l'implémentation.

## 2. Vue relationnelle

```text
auth.users
    1
    │
    1
profiles

categories
    1
    │
    n
items
    1
    │
    n
item_images
```

Relations :

- `profiles.id` référence `auth.users.id` ;
- `items.category_id` référence `categories.id` ;
- `item_images.item_id` référence `items.id`.

## 3. Types métier

### Rôle administratif

Valeurs autorisées :

- `SUPER_ADMIN`
- `ADMIN`

### Statut d'un article

Valeurs autorisées :

- `DRAFT`
- `PUBLISHED`
- `ARCHIVED`

Ces ensembles fermés devront être représentés par des types PostgreSQL adaptés ou
par des contraintes équivalentes. Le choix technique sera réalisé lors de la
conception des migrations.

## 4. Table `profiles`

Finalité : compléter un utilisateur Supabase Auth avec son identité métier, son
rôle et son état d'activation.

| Colonne | Type attendu | Obligatoire | Règle |
|---|---|:---:|---|
| `id` | UUID | Oui | Clé primaire et référence vers `auth.users.id` |
| `email` | Texte | Oui | Minuscules, normalisée et unique sans tenir compte de la casse |
| `role` | Rôle administratif | Oui | `ADMIN` par défaut ; élévation contrôlée |
| `first_name` | Texte | Oui | Valeur non vide |
| `last_name` | Texte | Oui | Valeur non vide |
| `is_active` | Booléen | Oui | `true` par défaut |
| `created_at` | Date/heure avec fuseau | Oui | Affectée à la création |
| `updated_at` | Date/heure avec fuseau | Oui | Actualisée à chaque modification |

Contraintes fonctionnelles :

- un profil correspond exactement à un utilisateur Auth ;
- aucun profil n'est supprimé physiquement en V1 ;
- seul un `SUPER_ADMIN` peut gérer `role` et `is_active` ;
- l'adresse `email` doit rester cohérente avec Supabase Auth.

Supabase Auth reste la source de vérité de l'adresse email. Le profil en conserve
une copie normalisée en minuscules ; son mécanisme de synchronisation sera défini
lors de la conception des migrations.

## 5. Table `categories`

Finalité : organiser dynamiquement le catalogue sans notion d'univers codée en dur.

| Colonne | Type attendu | Obligatoire | Règle |
|---|---|:---:|---|
| `id` | UUID | Oui | Clé primaire |
| `name` | Texte | Oui | Unique et non vide |
| `slug` | Texte | Oui | Unique, stable et compatible avec une URL |
| `description` | Texte | Non | Description éditoriale |
| `display_order` | Entier | Oui | Positif ou nul |
| `is_active` | Booléen | Oui | `true` par défaut |
| `created_at` | Date/heure avec fuseau | Oui | Affectée à la création |
| `updated_at` | Date/heure avec fuseau | Oui | Actualisée à chaque modification |

Contraintes fonctionnelles :

- `name` conserve sa casse d'affichage, mais son unicité ignore la casse et les
  espaces superflus en début ou fin de valeur ;
- `slug` est normalisé en minuscules et unique sans tenir compte de la casse ;
- `is_active = false` représente l'archivage logique ;
- une catégorie inactive n'est jamais visible sur le site public.

## 6. Table `items`

Finalité : stocker les articles du catalogue.

| Colonne | Type attendu | Obligatoire | Règle |
|---|---|:---:|---|
| `id` | UUID | Oui | Clé primaire |
| `category_id` | UUID | Oui | Référence une catégorie existante |
| `title` | Texte | Oui | Valeur non vide |
| `slug` | Texte | Oui | Unique et compatible avec une URL |
| `description` | Texte | Non | Description éditoriale |
| `price_cents` | Entier | Oui | Supérieur ou égal à zéro |
| `stock_quantity` | Entier | Oui | Supérieur ou égal à zéro |
| `sku` | Texte | Oui | Référence métier unique |
| `status` | Statut d'article | Oui | `DRAFT` par défaut |
| `display_order` | Entier | Oui | Positif ou nul |
| `created_at` | Date/heure avec fuseau | Oui | Affectée à la création |
| `updated_at` | Date/heure avec fuseau | Oui | Actualisée à chaque modification |

Contraintes fonctionnelles :

- `slug` est normalisé en minuscules et unique sans tenir compte de la casse ;
- `sku` est normalisé en majuscules et unique sans tenir compte de la casse ;
- le prix est enregistré dans la plus petite unité monétaire, sans nombre décimal ;
- la quantité en stock ne peut jamais être négative ;
- un article est archivé avec le statut `ARCHIVED` ;
- aucune suppression physique n'est autorisée en V1.

## 7. Table `item_images`

Finalité : référencer les images Supabase Storage associées à un article.

| Colonne | Type attendu | Obligatoire | Règle |
|---|---|:---:|---|
| `id` | UUID | Oui | Clé primaire |
| `item_id` | UUID | Oui | Référence un article existant |
| `image_url` | Texte | Oui | Référence stable de l'objet Storage |
| `display_order` | Entier | Oui | Valeur comprise entre 1 et 3 |
| `is_primary` | Booléen | Oui | `false` par défaut |
| `created_at` | Date/heure avec fuseau | Oui | Affectée à la création |

Contraintes fonctionnelles :

- un article possède au maximum trois images ;
- une seule image peut être principale pour un même article ;
- une position ne peut être utilisée qu'une fois pour un même article ;
- une image appartient à un seul article.

La future migration devra faire respecter ces règles en base de données. Elles ne
doivent pas dépendre uniquement de contrôles Flutter.

Un article doit posséder au moins une image pour passer au statut `PUBLISHED`.
Cette règle porte sur plusieurs tables et devra être garantie côté base de données.

### Interprétation de `image_url`

Pour éviter de conserver une URL temporaire ou liée à un domaine, `image_url`
désigne la référence stable de l'objet dans Supabase Storage. Une URL signée
temporaire ne doit jamais être enregistrée dans cette colonne.

## 8. Index validés

Les accès suivants doivent être indexés :

- `categories.slug` ;
- `categories.is_active` ;
- `items.slug` ;
- `items.sku` ;
- `items.status` ;
- `items.category_id` ;
- `item_images.item_id`.

Les contraintes d'unicité sur `slug`, `sku` et les autres clés uniques pourront
déjà produire les index nécessaires. Les migrations devront éviter les index
redondants.

## 9. Règles de relation

- Une catégorie référencée ne peut pas être supprimée physiquement.
- Archiver une catégorie ne modifie pas automatiquement le statut de ses articles.
- Les articles de cette catégorie deviennent toutefois invisibles publiquement.
- Les images suivent la visibilité publique de leur article.
- Les règles de suppression physique des fichiers Storage sont définies dans la
  stratégie Storage.
