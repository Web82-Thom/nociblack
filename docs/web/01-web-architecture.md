# NociBlacK Web — Architecture V1

## 1. Objet

Ce document définit l'architecture officielle du site public NociBlacK V1.
Il constitue la référence avant toute installation de dépendances supplémentaires
ou création de fonctionnalités React.

## 2. Contexte et contraintes

- Le site est une application React avec TypeScript et Vite.
- Le déploiement cible est un hébergement statique IONOS Web Plus.
- Supabase fournit PostgreSQL, l'API de données et le stockage des médias.
- Le site est public et ne possède aucun droit administratif.
- Le catalogue repose uniquement sur des catégories dynamiques.
- Aucun univers métier n'est codé en dur dans l'application.
- Les composants React sont fonctionnels.
- La POO est réservée aux éléments pour lesquels elle apporte une responsabilité
  claire : entités, repositories, services, cas d'usage et mappers.
- Aucun fichier ne doit dépasser 500 lignes. La cible habituelle reste comprise
  entre 150 et 300 lignes.

## 3. Routes publiques

| Route | Responsabilité |
|---|---|
| `/` | Accueil et mise en avant du catalogue |
| `/catalogue` | Catalogue public complet |
| `/categories/:slug` | Articles publiés d'une catégorie active |
| `/articles/:slug` | Fiche publique d'un article publié |
| `/contact` | Informations et moyens de contact |
| `*` | Page 404 |

Les slugs proviennent de Supabase. Aucune route `restauration`, `market` ou autre
univers commercial ne doit être ajoutée en dur.

## 4. Arborescence cible

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

Cette arborescence est créée progressivement. Aucun dossier vide ou abstraction
sans usage réel ne doit être ajouté uniquement pour reproduire le schéma.

## 5. Structure interne d'une fonctionnalité

Une fonctionnalité complexe peut utiliser les couches suivantes :

```text
feature/
├── domain/
│   ├── entities/
│   └── repositories/
├── application/
│   └── use-cases/
├── infrastructure/
│   ├── mappers/
│   └── repositories/
└── presentation/
    ├── components/
    ├── hooks/
    └── pages/
```

Une fonctionnalité simple n'est pas obligée de créer toutes les couches. La
structure doit suivre la complexité réelle et éviter les abstractions artificielles.

## 6. Responsabilités des couches

### `app`

- configure les providers globaux ;
- configure le routeur ;
- assemble les implémentations et leurs contrats ;
- ne contient aucune règle métier.

### `core`

- charge et valide la configuration ;
- initialise le client Supabase public ;
- définit les erreurs techniques partagées ;
- ne dépend d'aucune fonctionnalité.

### `domain`

- contient les entités et contrats métier ;
- ne dépend ni de React, ni de Supabase, ni du navigateur ;
- exprime les invariants utiles au site public.

### `application`

- orchestre les cas d'usage ;
- dépend des contrats du domaine ;
- ne connaît pas l'interface Supabase concrète.

### `infrastructure`

- implémente les repositories avec Supabase ;
- transforme les données Supabase grâce aux mappers ;
- ne transmet pas de lignes brutes de base de données à la présentation.

### `presentation`

- contient les pages, composants et hooks React ;
- gère les interactions et les états visuels ;
- n'exécute jamais directement une requête Supabase.

### `shared`

- contient uniquement les éléments véritablement réutilisables ;
- ne contient aucune règle métier propre à une fonctionnalité ;
- ne doit pas devenir un dossier générique sans responsabilité claire.

## 7. Flux de données

```text
Route
  → Page
  → Hook de présentation
  → TanStack Query
  → Cas d'usage
  → Contrat de repository
  → Repository Supabase
  → Mapper
  → Entité métier
```

Les données redescendent vers les composants sous forme d'entités ou de modèles de
présentation maîtrisés. Les composants ne manipulent pas directement la structure
des tables Supabase.

## 8. Dépendances validées

- React Router pour la navigation ;
- client JavaScript Supabase pour l'accès public aux données et médias ;
- TanStack Query pour le cache, le chargement et la synchronisation des données
  serveur ;
- CSS Modules pour les styles des composants ;
- variables CSS globales pour les couleurs, espacements et autres tokens visuels.

Redux n'est pas utilisé en V1. Les états locaux restent dans React. Les données
serveur sont gérées par TanStack Query.

## 9. Conventions React et TypeScript

- Les composants utilisent des fonctions et des propriétés typées.
- Un composant possède une responsabilité principale.
- Les composants de page orchestrent, les composants enfants affichent.
- La logique réutilisable est extraite dans des hooks ou services dédiés.
- Les classes React historiques ne sont pas utilisées.
- Les exports nommés sont privilégiés pour les modules métier et composants.
- Les types vagues et `any` sont interdits sans justification documentée.
- Les noms techniques suivent la casse anglaise standard, tandis que les textes
  visibles respectent la marque `NociBlacK`.

## 10. Approche orientée objet

La POO s'applique aux responsabilités métier stables :

- entités lorsque des invariants doivent être protégés ;
- interfaces de repositories ;
- implémentations Supabase des repositories ;
- cas d'usage ;
- services et mappers.

Elle ne doit pas transformer les composants React en classes ni multiplier des
objets sans comportement. La composition reste le mécanisme principal de l'interface.

## 11. Gestion des données serveur

TanStack Query prend en charge :

- le cache des catégories et articles ;
- les états de chargement et d'erreur ;
- la déduplication des requêtes ;
- les nouvelles tentatives contrôlées ;
- l'invalidation éventuelle du cache.

Les clés de requêtes sont centralisées dans leur fonctionnalité. Les composants ne
construisent pas librement leurs propres clés.

## 12. États d'interface obligatoires

Chaque page alimentée par Supabase prévoit :

- un état de chargement ;
- un état vide ;
- un état d'erreur compréhensible ;
- un état de succès ;
- une page 404 lorsque la ressource publique n'existe pas.

Une erreur technique ne doit jamais afficher de données sensibles au visiteur.

## 13. Styles et composants

- Les couleurs de marque sont définies comme tokens CSS globaux.
- Le noir, le blanc et l'or constituent la palette V1.
- Les styles propres à un composant utilisent un fichier CSS Module adjacent.
- Les styles globaux restent limités au reset, aux tokens et aux règles de base.
- Les layouts structurent les pages sans contenir de logique métier.
- Les composants réutilisables sont conçus seulement après l'identification d'un
  usage commun réel.

## 14. Supabase et sécurité

- Une seule instance du client Supabase public est créée dans `core/supabase`.
- La configuration provient de variables d'environnement Vite.
- Un fichier `.env.example` documente les variables attendues sans valeur secrète.
- La clé `service_role` est interdite dans le site, le dépôt et les builds.
- Les politiques RLS restent la protection réelle des données.
- Le site ne peut lire que les catégories actives, articles publiés et médias
  autorisés.

## 15. SEO et hébergement statique

Le site V1 est une SPA statique. Cette décision permet un déploiement simple sur
IONOS et une lecture dynamique de Supabase, mais limite le référencement par rapport
à un rendu serveur.

La V1 met en place :

- des URLs lisibles basées sur les slugs ;
- un titre et une description globaux ;
- des métadonnées adaptées aux routes lorsque cela est pertinent ;
- du HTML sémantique ;
- des images optimisées et des textes alternatifs ;
- une configuration IONOS renvoyant les routes applicatives vers `index.html`.

Un besoin SEO plus avancé nécessitera une décision distincte concernant le
prérendu, le rendu serveur ou l'hébergement.

## 16. Qualité et validation

Chaque évolution Web suit le cycle :

1. analyse ;
2. validation ;
3. implémentation ;
4. test manuel ;
5. lint et build ;
6. tests automatisés après validation du comportement ;
7. commit.

Les tests couvriront en priorité :

- le domaine et les cas d'usage ;
- les mappers ;
- les repositories avec leurs dépendances simulées ;
- les composants et routes critiques ;
- les états chargement, vide, erreur et succès.

## 17. Interdictions V1

- aucune requête Supabase dans un composant React ;
- aucune clé privilégiée côté navigateur ;
- aucun état global Redux sans nouveau besoin validé ;
- aucune route métier codée en dur pour remplacer les catégories dynamiques ;
- aucune dépendance ajoutée sans responsabilité identifiée ;
- aucun fichier supérieur à 500 lignes ;
- aucune abstraction sans usage concret.
