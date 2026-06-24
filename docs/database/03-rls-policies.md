# NociBlacK — Stratégie RLS V1

## 1. Objet

Ce document décrit les règles d'autorisation RLS implémentées pour NociBlacK V1.
Les migrations exécutables correspondantes sont
`supabase/migrations/20260623124112_create_rls_policies.sql` et
`supabase/migrations/20260624152630_enable_permanent_item_deletion.sql`.

## 2. Principes

- La RLS est activée sur toutes les tables exposées par l'API Supabase.
- Les inscriptions Auth publiques sont désactivées en V1.
- L'accès public est limité aux données explicitement publiées.
- Toute permission administrative nécessite une session authentifiée.
- Toute permission administrative nécessite également un profil actif.
- Le rôle est lu depuis `profiles`, jamais depuis une valeur fournie par Flutter.
- Le principe du moindre privilège s'applique à chaque opération.
- La clé `service_role` n'est utilisée dans aucun client public.

## 3. Fonctions de contrôle

Deux fonctions PostgreSQL centralisent les contrôles administratifs :

- `is_active_admin()` autorise un profil actif ayant le rôle `ADMIN` ou
  `SUPER_ADMIN` ;
- `is_active_super_admin()` autorise uniquement un profil `SUPER_ADMIN` actif.

Ces fonctions utilisent `security definer`, un `search_path` vide et ne sont
exécutables que par le rôle PostgreSQL `authenticated`.

## 4. Politiques de `profiles`

### Lecture

- Public : aucun accès.
- `ADMIN` actif : lecture de son propre profil uniquement.
- `SUPER_ADMIN` actif : lecture de tous les profils.

### Création

- Public : interdite.
- `ADMIN` : interdite.
- `SUPER_ADMIN` : la ligne de profil est créée dans le cadre du provisionnement
  manuel réalisé depuis le tableau de bord Supabase en V1.

### Modification

- Public : interdite.
- `ADMIN` : aucune modification directe en V1.
- `SUPER_ADMIN` : autorisée, notamment pour le rôle et l'état d'activation.

### Suppression

Interdite pour tous les rôles. Un compte est désactivé avec `is_active = false`.

## 5. Politiques de `categories`

### Lecture

- Public : catégories avec `is_active = true` uniquement.
- Administrateur actif : toutes les catégories.

### Création et modification

- Public : interdites.
- `ADMIN` actif : autorisées.
- `SUPER_ADMIN` actif : autorisées.

### Suppression

La suppression physique est interdite. L'opération métier correspond à définir
`is_active = false`.

## 6. Politiques de `items`

### Lecture

- Public : articles avec `status = PUBLISHED` dont la catégorie est active.
- Administrateur actif : tous les articles, quel que soit leur statut.

Le contrôle de la catégorie active évite qu'un article reste visible lorsqu'une
catégorie complète est archivée.

### Création et modification

- Public : interdites.
- `ADMIN` actif : autorisées.
- `SUPER_ADMIN` actif : autorisées.

Les contraintes de prix, stock, statut et relations restent appliquées par la base,
même lorsqu'un rôle possède le droit de modification.

Le passage au statut `PUBLISHED` exige entre une et trois images, exactement une
image principale et une catégorie active. Un article publié avec un stock nul reste
lisible publiquement et est présenté comme indisponible par les interfaces clientes.

### Suppression

Le `DELETE` direct reste interdit au public et aux sessions authentifiées : aucune
politique RLS de suppression n'est exposée sur la table. Un `ADMIN` ou
`SUPER_ADMIN` actif peut appeler `delete_item_permanently(uuid)`. Cette fonction
`security definer` vérifie le rôle côté base, verrouille l'article, enregistre les
objets Storage à nettoyer, puis supprime l'agrégat dans une seule transaction.

`get_pending_item_storage_deletions(integer)` et
`complete_item_storage_deletions(uuid[])` permettent à Flutter de reprendre et
d'acquitter le nettoyage Storage sans exposer la file privée.

## 7. Politiques de `item_images`

### Lecture

- Public : images dont l'article est `PUBLISHED` et dont la catégorie est active.
- Administrateur actif : images de tous les articles.

### Création et modification

- Public : interdites.
- `ADMIN` actif : autorisées.
- `SUPER_ADMIN` actif : autorisées.

Les contraintes du schéma empêchent :

- une quatrième image ;
- plusieurs images principales pour le même article ;
- deux images à la même position pour le même article ;
- une position en dehors de l'intervalle 1 à 3.

### Suppression

La suppression d'une association d'image est réservée aux administrateurs actifs.
Elle doit rester cohérente avec la suppression éventuelle du fichier Storage.

## 8. Protection contre l'élévation de privilèges

Les politiques et fonctions garantissent qu'un `ADMIN` ne peut pas :

- créer une ligne `profiles` pour obtenir un nouveau compte ;
- changer son propre rôle ;
- changer le rôle d'un autre utilisateur ;
- réactiver un compte ;
- contourner une désactivation en conservant une ancienne session ;
- appeler une opération privilégiée en forgeant des données côté client.

## 9. Scénarios validés

Les scénarios 1 à 10 ont été validés sur le projet Supabase hébergé. Les scénarios
11 à 13 sont validés localement et restent à confirmer sur le projet hébergé :

1. Un visiteur lit une catégorie active.
2. Un visiteur ne lit pas une catégorie inactive.
3. Un visiteur lit un article publié d'une catégorie active.
4. Un visiteur ne lit ni brouillon ni archive.
5. Un article publié devient invisible si sa catégorie est désactivée.
6. Un `ADMIN` actif gère le catalogue.
7. Un `ADMIN` ne lit que son propre profil.
8. Un `ADMIN` ne peut modifier aucun rôle ni compte tiers.
9. Un `SUPER_ADMIN` gère les profils administratifs.
10. Un administrateur désactivé perd immédiatement tous ses droits privés.
11. Un `ADMIN` et un `SUPER_ADMIN` actifs peuvent supprimer définitivement un
    article via la fonction dédiée.
12. Le public, un compte désactivé et un `DELETE` direct ne peuvent pas contourner
    cette fonction.
13. Les références d'images sont supprimées en cascade et leurs chemins sont
    conservés dans la file durable jusqu'à confirmation du nettoyage Storage.

Ces scénarios sont couverts par :

- `supabase/tests/database/public_rls_test.sql` ;
- `supabase/tests/database/admin_rls_test.sql` ;
- `supabase/tests/database/item_deletion_test.sql`.
