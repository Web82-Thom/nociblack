# NociBlacK — Stratégie Supabase Storage V1

## 1. Objet

Ce document décrit l'organisation, les formats et les permissions des médias
Supabase Storage implémentés pour NociBlacK V1. Les migrations correspondantes sont
`supabase/migrations/20260623130453_create_storage_configuration.sql` et
`supabase/migrations/20260624201028_adopt_jpeg_item_image_paths.sql`.

Les logos intégrés à l'application Flutter sont placés localement dans :

```text
assets/images/logos/
```

Ces ressources locales sont distinctes des ressources publiées dans Supabase Storage.

## 2. Bucket `item-images`

### Finalité

Stocker les images associées aux articles du catalogue.

### Organisation

```text
item-images/
└── items/
    └── {item_id}/
        └── {image_id}.jpg
```

`item_id` correspond obligatoirement à un article existant.

### Contraintes

- maximum trois images par article ;
- format stocké : JPEG exclusivement ;
- taille maximale : 5 Mo par fichier après traitement ;
- positions autorisées : 1, 2 et 3 ;
- la position 1 est toujours l'image principale dans `item_images` ;
- nom de fichier UUID immuable, indépendant de l'ordre d'affichage.

La limite de trois images doit être garantie par la base de données et pas seulement
par l'interface Flutter. La limite de taille doit aussi être configurée au niveau du
bucket lorsque Supabase le permet.

### Visibilité

Le bucket ne doit pas rendre tous ses objets publics sans contrôle, car cela exposerait
les images des brouillons et des archives.

La lecture anonyme est autorisée uniquement lorsque :

- le chemin correspond à un article existant ;
- l'article possède le statut `PUBLISHED` ;
- la catégorie de l'article est active.

Un `ADMIN` ou `SUPER_ADMIN` actif peut lire et gérer les images des articles, quel
que soit leur statut.

## 3. Bucket `brand-assets`

### Finalité

Stocker les ressources publiques de marque utilisées par le site.

### Organisation

```text
brand-assets/
└── public/
    ├── logo.png
    ├── logo_gold.png
    └── favicon.png
```

### Permissions

- lecture publique ;
- lecture administrative ;
- ajout, remplacement et suppression réservés au `SUPER_ADMIN` actif ;
- aucune modification autorisée à un `ADMIN`.

Contraintes du bucket :

- taille maximale : 2 Mo ;
- formats autorisés : PNG et WebP ;
- SVG interdit en V1.

## 4. Cohérence entre Storage et base de données

Une image d'article comporte deux éléments liés :

1. l'objet binaire dans `item-images` ;
2. la ligne correspondante dans `item_images`.

Le service média traite l'opération comme un workflow cohérent :

- valider le fichier avant l'upload ;
- uploader l'objet ;
- créer la référence en base ;
- nettoyer l'objet si la création de la référence échoue ;
- ne jamais laisser une ligne pointer vers un objet inexistant.

La base de données reste la source de vérité pour l'ordre et l'image principale.
La colonne `item_images.image_url` conserve uniquement une référence Storage stable ;
elle ne contient jamais d'URL signée temporaire. Sa forme canonique est :

```text
item-images/items/{item_id}/{image_id}.jpg
```

La contrainte PostgreSQL vérifie le bucket, le format du chemin et l'appartenance
au bon article. Les policies Storage appliquent la même convention sur le nom
interne `items/{item_id}/{image_id}.jpg`.

## 5. Remplacement et suppression des images

Les fichiers médias doivent pouvoir être supprimés lors d'un remplacement, du
retrait explicite d'une image ou de la suppression définitive de leur article.
`item_images` ne possède pas de mécanisme d'archivage et chaque article est limité
à trois images.

Le retrait d'une image devra :

1. vérifier les permissions administratives ;
2. retirer la référence `item_images` ;
3. supprimer l'objet Storage correspondant ;
4. recalculer si nécessaire l'ordre et l'image principale.

L'ordre précis des opérations et la stratégie de compensation seront définis dans le
service média avant son implémentation.

La suppression définitive d'un article utilise dès maintenant une file durable :

1. la fonction PostgreSQL enregistre tous les chemins dans
   `private.item_storage_deletion_jobs` ;
2. l'article et ses références `item_images` sont supprimés dans la même transaction ;
3. Flutter supprime les objets via l'API Supabase Storage ;
4. les jobs sont acquittés uniquement après réussite de l'API ;
5. un échec réseau laisse les jobs en attente et le nettoyage reprend à la prochaine
   ouverture d'une collection d'articles.

## 6. Sécurité des fichiers

- La clé `service_role` ne doit jamais être embarquée dans Flutter ou le site public.
- Le type MIME déclaré doit être contrôlé avec le contenu réel du fichier.
- Les extensions non autorisées doivent être rejetées.
- Le chemin d'upload doit être construit par l'application, pas accepté librement.
- Un administrateur ne peut écrire que dans les emplacements autorisés.
- Aucun nom de fichier fourni par l'utilisateur ne doit être utilisé directement.
- Les erreurs d'upload ne doivent pas exposer d'informations sensibles.

## 7. Traitement côté application

Avant l'upload, l'application Android devra :

- vérifier qu'il reste une position disponible ;
- accepter comme sources JPG, JPEG, PNG, WebP, HEIC et HEIF ;
- contrôler le type et la taille de la source ;
- redimensionner à 1200 pixels de largeur maximale ;
- convertir obligatoirement en JPEG avec une qualité de 80 % ;
- vérifier que le résultat JPEG ne dépasse pas 5 Mo ;
- afficher un aperçu ;
- demander une confirmation avant remplacement.

Ces contrôles améliorent l'expérience utilisateur, mais ne remplacent jamais les
contraintes Supabase.

Le formulaire Admin charge les images existantes depuis `item_images`, affiche les
objets privés avec des URL signées temporaires, puis transmet au service de mise à
jour l'état final voulu : images conservées, images retirées et nouvelles sources.
Les nouvelles sources sont converties en JPEG et uploadées avant l'écriture en base.
En cas d'échec d'écriture, les nouveaux objets uploadés sont nettoyés. Les anciens
objets retirés ne sont supprimés du Storage qu'après succès de la persistance afin
de ne pas perdre une image encore référencée.

## 8. Implémentation et validation

Les buckets `item-images` et `brand-assets` ainsi que leurs politiques RLS sont
déployés sur le projet Supabase hébergé. L'architecture JPEG à chemins UUID a été
validée par reset local, tests transactionnels, lint local et lint distant.

Le test transactionnel est disponible dans :

```text
supabase/tests/database/storage_rls_test.sql
```

Il valide les lectures publiques, les uploads administratifs, les chemins autorisés,
la séparation `ADMIN` / `SUPER_ADMIN` et la révocation des droits après
désactivation.

Supabase interdit les suppressions directes dans `storage.objects`. Les suppressions
unitaires d'images sont donc exécutées via l'API Storage par Flutter après mise à
jour des lignes `item_images`. Les tests Flutter couvrent l'orchestration et les
compensations ; une validation réelle Supabase reste à faire pour le flux de
modification avec ajout et suppression.
