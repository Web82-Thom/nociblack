# Étapes de construction

## Terminé

- [x] Création du monorepo
- [x] Création de la documentation
- [x] Création de l’application Flutter Android Admin
- [x] Création du dépôt GitHub
- [x] Création du projet Supabase
- [x] Initialisation React + TypeScript + Vite
- [x] Installation des dépendances Web
- [x] Suppression de la démonstration Vite
- [x] Création du socle minimal NociBlacK Web
- [x] Validation ESLint
- [x] Validation du build Vite
- [x] Validation visuelle du socle Web
- [x] Validation de l’architecture Web
- [x] Documentation de l’architecture Web
- [x] Mise en place du socle initial de l’arborescence Web
- [x] Mise en place initiale du routeur Web
- [x] Création de la page 404
- [x] Configuration de Vitest et Testing Library
- [x] Tests automatisés du routeur
- [x] Installer la CLI Supabase
- [x] Initialiser la configuration Supabase du dépôt
- [x] Lier le dépôt au projet Supabase hébergé
- [x] Créer et appliquer la migration PostgreSQL initiale
- [x] Valider le schéma distant avec Supabase DB lint
- [x] Créer et valider le test SQL du schéma initial
- [x] Créer et appliquer la migration des politiques RLS
- [x] Créer les profils SUPER_ADMIN et ADMIN
- [x] Désactiver les inscriptions Auth publiques
- [x] Valider les accès RLS public, ADMIN et SUPER_ADMIN
- [x] Valider la révocation des droits d’un administrateur désactivé

## À venir

- [ ] Configurer les buckets et politiques Storage
- [ ] Connecter Flutter à Supabase
- [ ] Connecter React à Supabase

## Commandes Supabase

Depuis la racine du dépôt :

```powershell
supabase migration list --linked
supabase db push --dry-run --linked
supabase db push
supabase db lint --linked --level warning
```

Les tests transactionnels sont exécutés dans le SQL Editor Supabase :

```text
supabase/tests/database/
├── initial_schema_test.sql
├── public_rls_test.sql
└── admin_rls_test.sql
```

## Commandes Web

```powershell
Set-Location .\apps\nociblack_web
npm install
npm run lint
npm run build
npm run dev
npm test
```
