# NociBlacK — Règles métier V1

## 1. Objet

Ce document rassemble les règles métier transversales de NociBlacK V1. Il complète
le schéma de données, la matrice des permissions et les stratégies RLS et Storage.

## 2. Principes généraux

- Le catalogue repose uniquement sur des catégories dynamiques.
- Aucun univers commercial n'est codé en dur.
- Aucun profil ni catégorie n'est supprimé physiquement en V1. Un article peut
  être supprimé définitivement par un administrateur actif via l'opération dédiée.
- Les contrôles critiques sont garantis par Supabase, pas uniquement par Flutter.
- Les données monétaires sont stockées en centimes.
- Toutes les dates techniques utilisent une date/heure avec fuseau.
- Les slugs sont stables, uniques et compatibles avec des URL.

## 3. Administrateurs

- Deux rôles existent : `SUPER_ADMIN` et `ADMIN`.
- Un seul `SUPER_ADMIN` est prévu au lancement.
- Un administrateur doit être authentifié et actif pour accéder au catalogue privé.
- Un `ADMIN` ne gère jamais les comptes ni les rôles.
- Un compte désactivé reste conservé mais perd tous ses droits administratifs.
- Aucun utilisateur ne peut s'inscrire librement comme administrateur.

## 4. Catégories

- Une catégorie possède un nom et un slug uniques.
- Une catégorie active peut apparaître sur le site public.
- Une catégorie inactive est considérée comme archivée.
- Archiver une catégorie ne supprime ni ne modifie automatiquement ses articles.
- Tous les articles d'une catégorie inactive sont masqués du site public.
- Une catégorie archivée reste visible dans l'application Admin.
- L'ordre d'affichage est piloté par `display_order`.

## 5. Articles

### Création

- Un article appartient obligatoirement à une catégorie existante.
- Un nouvel article commence avec le statut `DRAFT`.
- Le titre, le slug, le SKU, le prix et la quantité en stock sont obligatoires.
- Le prix et la quantité en stock ne peuvent pas être négatifs.
- Le slug est normalisé en minuscules et unique sans tenir compte de la casse.
- Le SKU est normalisé en majuscules et unique sans tenir compte de la casse.

### Publication

Un article est visible sur le site public uniquement lorsque :

- son statut est `PUBLISHED` ;
- sa catégorie est active.

Le passage au statut `PUBLISHED` est refusé si les données obligatoires sont
invalides, si la catégorie est inactive ou si aucune image n'est associée à l'article.

### Stock

- `stock_quantity` représente la quantité disponible.
- Une quantité nulle signifie que l'article est indisponible.
- Un article publié avec un stock nul reste visible et affiche son indisponibilité.
- Aucune opération ne peut produire un stock négatif.

### Archivage

- Un article archivé possède le statut `ARCHIVED`.
- Un article archivé n'est jamais visible publiquement.
- Il reste consultable dans l'application Admin.
- La restauration d'une archive repasse obligatoirement par `DRAFT` avant publication.

### Suppression définitive

- Un `ADMIN` ou `SUPER_ADMIN` actif peut supprimer un article courant ou archivé.
- L'action est irréversible et exige une confirmation renforcée dans Flutter.
- La suppression retire l'article et toutes ses références `item_images`.
- Chaque objet Storage associé est enregistré dans une file durable avant la
  suppression en base, puis supprimé via l'API Storage.
- Un échec du nettoyage Storage ne restaure pas l'article : le job reste en attente
  et sera repris automatiquement.

## 6. Images d'article

- Un article possède entre zéro et trois images lorsqu'il est en brouillon.
- Un article publié possède obligatoirement entre une et trois images.
- Les positions autorisées vont de 1 à 3.
- Une position est unique dans un même article.
- Une seule image peut être principale.
- Un article publié possède exactement une image principale.
- L'image en position 1 est toujours l'image principale.
- Une image ne peut appartenir qu'à un seul article.
- Les images publiques suivent les règles de visibilité de leur article.
- Les sources JPG, JPEG, PNG, WebP, HEIC et HEIF sont converties en JPEG.
- La largeur maximale est de 1200 pixels, la qualité JPEG de 80 % et la taille
  maximale du résultat stocké de 5 Mo.
- Le chemin stable suit `item-images/items/{item_id}/{image_id}.jpg` et ne dépend
  jamais de l'ordre d'affichage.
- Dans l'Admin, une modification peut conserver des images existantes, en retirer
  une ou plusieurs et ajouter de nouvelles images jusqu'à la limite de trois.
- Les images retirées sont marquées dans le formulaire et peuvent être restaurées
  avant sauvegarde.
- Après sauvegarde, les positions sont renumérotées à partir de 1 et la position 1
  redevient automatiquement l'image principale.

La base de données doit empêcher la publication d'un article sans image. Ce contrôle
ne doit pas dépendre uniquement de l'application Flutter.

## 7. Prix

- `price_cents` contient un entier représentant les centimes.
- Aucun nombre flottant n'est utilisé pour stocker un prix.
- La mise en forme en euros appartient aux interfaces clientes.
- Un prix égal à zéro est autorisé par le modèle validé.
- La devise V1 est l'euro ; aucune gestion multidevise n'est prévue.

## 8. Slugs

- Les catégories et articles possèdent chacun leur propre slug unique.
- Un slug est généré à partir du nom ou du titre, normalisé en minuscules, puis
  validé avant sauvegarde.
- Il contient uniquement des caractères compatibles avec une URL.
- Une modification du titre ne modifie pas automatiquement un slug déjà publié.
- Les collisions doivent être signalées explicitement à l'administrateur.

## 9. Ordre d'affichage

- `display_order` détermine l'ordre principal dans une liste.
- Une valeur faible apparaît avant une valeur élevée.
- En cas d'égalité, un second critère stable devra être utilisé, par exemple la date
  de création puis l'identifiant.
- Le réordonnancement ne modifie pas les identifiants ni les slugs.

## 10. Traçabilité

- `created_at` est défini lors de la création et ne change jamais.
- `updated_at` est actualisé lors de chaque modification métier.
- Les dates sont produites par la base de données afin de ne pas dépendre de l'heure
  du téléphone Android.
- L'archivage préserve l'historique fonctionnel minimal ; la suppression définitive
  d'un article le retire volontairement avec ses images.

## 11. Décisions validées avant les migrations

Les décisions suivantes sont définitives pour la V1 :

1. la colonne `image_url` est conservée et contient une référence Storage stable,
   jamais une URL signée temporaire ;
2. un article publié avec un stock nul reste visible et apparaît comme indisponible ;
3. entre une et trois images, dont exactement une image principale, sont
   obligatoires avant la publication d'un article ;
4. les noms conservent leur casse d'affichage, mais leur unicité ignore la casse ;
5. les slugs et emails sont normalisés en minuscules, les SKU en majuscules, et leur
   unicité ignore la casse ;
6. les comptes administratifs sont créés manuellement depuis le tableau de bord
   Supabase en V1, sans clé privilégiée dans l'application Flutter ;
7. le retrait d'une image supprime physiquement le fichier Storage correspondant.
8. la suppression définitive d'un article est réservée aux administrateurs actifs et
   utilise une file durable pour garantir la reprise du nettoyage Storage.
9. les images d'articles sont stockées exclusivement en JPEG sous un nom UUID,
   après redimensionnement et compression obligatoires côté Flutter.

Ces décisions servent de référence à la conception et au contrôle des migrations
SQL.
