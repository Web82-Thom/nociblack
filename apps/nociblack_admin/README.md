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
Le SDK Supabase est initialisé dans l'application et son démarrage Android a été
validé. L'authentification et les repositories du catalogue constituent les
prochaines étapes.

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
│   └── home/
│       └── presentation/
│           └── pages/
│               └── admin_home_page.dart
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
```

Les images d'articles sont converties et envoyées dans `item-images` au format
WebP. Les assets de marque acceptent PNG et WebP.

Limites :

```text
3 images maximum par article
2 Mo maximum par image
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

Le socle actuel compte cinq tests : quatre tests de configuration et un test de
widget. Le démarrage Android avec initialisation Supabase a également été validé.

---

## État actuel

Terminé :

* Initialisation typée de l'environnement Supabase
* Initialisation du SDK avant le lancement de l'application
* Configuration Android de l'accès réseau
* Extraction de l'application racine, du thème et de la page d'accueil
* Validation manuelle du démarrage Android
* Analyse statique et tests automatisés

À venir :

* Authentification des administrateurs
* Contrôle de session et du profil `ADMIN` ou `SUPER_ADMIN`
* Repositories du catalogue
* Tests des mutations via l'API Supabase Storage

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
