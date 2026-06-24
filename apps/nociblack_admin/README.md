# NociBlacK

Application Android développée avec Flutter permettant la gestion du catalogue NociBlacK.

## Présentation

NociBlacK Admin est le back-office officiel de la plateforme NociBlacK.

L'application permet aux administrateurs de gérer :

* Les catégories
* Les articles
* Les images des articles
* La publication du catalogue

Le schéma de données, les politiques RLS et Storage sont déployés sur Supabase.
Le SDK Supabase, l'authentification administrative, la lecture des articles et
la gestion complète des catégories sont intégrés et validés sur Android. La
création, la modification, l'archivage, la restauration en brouillon et la
suppression définitive sécurisée des articles sont opérationnelles. La création
d'un brouillon avec une à trois images JPEG est également intégrée et validée sur
Android avec le projet Supabase hébergé. La gestion des images en modification et
la publication constituent les prochaines étapes.

---

## Fonctionnalités V1

### Gestion des catégories

* Création de catégories
* Modification de catégories
* Archivage de catégories
* Ordre d'affichage configurable

### Gestion des articles

* Création d'articles
* Modification d'articles
* Archivage d'articles
* Restauration des articles archivés en brouillon
* Suppression définitive des articles et de leurs images
* Gestion du stock
* Gestion du prix
* Gestion du SKU
* Publication et dépublication

### Gestion des médias

* Jusqu'à 3 images par article
* Image principale
* Compression avant upload
* Stockage Supabase Storage

### Gestion des rôles

#### SUPER_ADMIN

* Gestion des administrateurs
* Gestion des rôles
* Accès complet à la plateforme

#### ADMIN

* Gestion du catalogue
* Gestion des catégories
* Gestion des médias

---

## Architecture

Le projet suit une architecture orientée objet et une séparation stricte des responsabilités.

```text
lib/
├── app/
│   ├── app.dart
│   └── theme/
│       └── app_theme.dart
├── core/
│   ├── config/
│   │   └── app_environment.dart
│   └── supabase/
│       └── supabase_initializer.dart
├── features/
│   ├── auth/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   ├── categories/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   ├── home/
│   │   └── presentation/
│   │       ├── pages/
│   │       │   └── admin_dashboard_page.dart
│   │       └── widgets/
│   │           └── dashboard_action_card.dart
│   └── items/
│       ├── data/
│       ├── domain/
│       └── presentation/
│           ├── controllers/
│           ├── pages/
│           └── widgets/
└── main.dart
```

Principes :

* Objets dédiés à la configuration, aux services et au domaine
* Features créées uniquement lorsqu'un besoin réel apparaît
* Séparation entre présentation, domaine et données pour les features métier
* Widgets courts, composables et réutilisables
* Dépendances externes isolées dans `core` ou dans la couche data concernée

La limite de 500 lignes reste un indicateur de découpage, pas une contrainte
artificielle. Un fichier est séparé dès que plusieurs responsabilités peuvent
être isolées clairement.

---

## Technologies

### Frontend

* Flutter
* Dart

### Backend

* Supabase
* PostgreSQL

### Authentification

* Supabase Auth

### Stockage

* Supabase Storage

---

## Statuts des articles

```text
DRAFT
PUBLISHED
ARCHIVED
```

### DRAFT

Visible uniquement aux administrateurs.

### PUBLISHED

Visible sur le site public.

### ARCHIVED

Conservé en base mais non visible publiquement.

---

## Structure des données

Tables principales :

```text
profiles
categories
items
item_images
```

---

## Storage

Buckets utilisés :

```text
item-images
brand-assets
```

Formats sources acceptés par l'application avant traitement :

```text
webp
jpg
jpeg
png
heic
heif
```

Les images d'articles sont converties et envoyées dans `item-images` au format
JPEG, avec une largeur maximale de 1200 pixels et une qualité de 80 %. Les assets
de marque acceptent PNG et WebP.

Limites :

```text
3 images maximum par article
5 Mo maximum par image JPEG traitée
```

---

## Sécurité

La sécurité repose principalement sur les politiques Supabase RLS dédiées et
testées pour les rôles `ADMIN` et `SUPER_ADMIN`.

Le client Flutter n'est jamais considéré comme une source de confiance.

Les contraintes métier critiques et les autorisations sont validées côté base de
données. Un administrateur désactivé perd immédiatement ses droits privés.

---

## Environnement de développement

Création du projet :

```bash
flutter create --platforms=android --org fr.thomasorta --project-name nociblack .
```

Installation des dépendances :

```bash
flutter pub get
```

Créer la configuration locale à partir du modèle :

```powershell
Copy-Item .\config\development.example.json .\config\development.json
```

Renseigner l'URL Supabase et la clé publique dans `development.json`. Ce fichier
est ignoré par Git. Une clé `service_role` ne doit jamais être utilisée dans
l'application.

Lancement :

```powershell
flutter run --dart-define-from-file=config/development.json
```

Validation locale :

```powershell
dart format lib test
flutter analyze
flutter test
```

Le socle actuel compte 72 tests couvrant la configuration, les domaines Auth,
Articles et Catégories, les contrôleurs, le workflow de création des images et les
transitions de widgets. Le démarrage Android et les échanges Supabase ont également
été validés.

---

## État actuel

Terminé :

* Initialisation typée de l'environnement Supabase
* Initialisation du SDK avant le lancement de l'application
* Configuration Android de l'accès réseau
* Extraction de l'application racine, du thème et de la page d'accueil
* Validation manuelle du démarrage Android
* Authentification par e-mail et mot de passe
* Validation du profil actif `ADMIN` ou `SUPER_ADMIN`
* Restauration de session et déconnexion
* Intégration de l'autoremplissage Android
* Tableau de bord Admin et navigation vers les écrans provisoires du catalogue
* Lecture des articles courants et archivés depuis Supabase
* Lecture des catégories actives depuis Supabase
* Sélecteur de catégorie dans le formulaire Article
* Consultation et création des catégories
* Modification, archivage et réactivation des catégories
* Génération des slugs et gestion des conflits d'unicité
* Création des articles brouillons
* Gestion du prix en centimes et de la REF
* Gestion des états chargement, vide, erreur et actualisation
* Modification des articles
* Archivage des articles depuis la liste courante
* Consultation des articles dans la page Archives
* Restauration des articles archivés vers le statut `DRAFT`
* Validation réelle des transitions `DRAFT` → `ARCHIVED` → `DRAFT` avec Supabase
* Suppression définitive depuis les listes Articles et Archives
* File durable et reprise automatique du nettoyage des images Storage
* Sélection, aperçu et limite de trois nouvelles images
* Compression et conversion JPEG avant upload
* Création coordonnée du brouillon, des objets Storage et des lignes `item_images`
* Compensation automatique du brouillon si l'enregistrement d'une image échoue
* Validation réelle de créations avec une et deux images sur Supabase
* Analyse statique et 72 tests automatisés

À venir :

* Chargement et ajout d'images lors de la modification d'un article
* Suppression et renumérotation des images existantes
* Publication des articles
* Validation réelle de la suppression avec images sur le projet Supabase hébergé
* Tests des suppressions et remplacements via l'API Supabase Storage

---

## Méthodologie de développement

Chaque fonctionnalité suit le cycle suivant :

1. Analyse
2. Validation
3. Développement
4. Test manuel
5. Test automatisé
6. Commit Git

Aucune fonctionnalité n'est développée sans validation préalable.

---

## Auteur

Thomas ORTA

NociBlacK © 2026
