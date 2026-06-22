# NociBlacK — Stratégie Supabase Storage V1

## 1. Objet

Ce document définit l'organisation, les formats et les permissions des médias dans
Supabase Storage. Les politiques Storage exécutables seront écrites après validation
de l'architecture documentaire.

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
└── {item_id}/
    ├── image_1.webp
    ├── image_2.webp
    └── image_3.webp
```

`item_id` correspond obligatoirement à un article existant.

### Contraintes

- maximum trois images par article ;
- format cible : WebP ;
- taille maximale : 2 Mo par fichier ;
- positions autorisées : 1, 2 et 3 ;
- une seule image principale définie dans `item_images` ;
- nom de fichier déterministe après validation et traitement de l'image.

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

## 4. Cohérence entre Storage et base de données

Une image d'article comporte deux éléments liés :

1. l'objet binaire dans `item-images` ;
2. la ligne correspondante dans `item_images`.

Le service média devra traiter l'opération comme un workflow cohérent :

- valider le fichier avant l'upload ;
- uploader l'objet ;
- créer la référence en base ;
- nettoyer l'objet si la création de la référence échoue ;
- ne jamais laisser une ligne pointer vers un objet inexistant.

La base de données reste la source de vérité pour l'ordre et l'image principale.
La colonne `item_images.image_url` conserve uniquement une référence Storage stable ;
elle ne contient jamais d'URL signée temporaire.

## 5. Remplacement et suppression des images

L'interdiction de suppression physique validée concerne les profils, catégories et
articles. Les fichiers médias doivent pouvoir être supprimés lors d'un remplacement
ou du retrait explicite d'une image, car `item_images` ne possède pas de mécanisme
d'archivage et chaque article est limité à trois images.

Le retrait d'une image devra :

1. vérifier les permissions administratives ;
2. retirer la référence `item_images` ;
3. supprimer l'objet Storage correspondant ;
4. recalculer si nécessaire l'ordre et l'image principale.

L'ordre précis des opérations et la stratégie de compensation seront définis dans le
service média avant son implémentation.

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
- contrôler le type et la taille ;
- redimensionner l'image si nécessaire ;
- convertir ou compresser vers WebP ;
- afficher un aperçu ;
- demander une confirmation avant remplacement.

Ces contrôles améliorent l'expérience utilisateur, mais ne remplacent jamais les
contraintes Supabase.
