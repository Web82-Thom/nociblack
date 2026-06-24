# NociBlacK — Rôles et permissions

## 1. Objet

Ce document définit les rôles administratifs de NociBlacK V1 et leurs permissions.
Il constitue la référence fonctionnelle pour les futures politiques PostgreSQL RLS,
l'application Flutter Android et les opérations réalisées dans Supabase.

La sécurité devra être appliquée côté Supabase. Masquer une action dans l'interface
Flutter ne constitue jamais une protection suffisante.

## 2. Acteurs

### Visiteur public

Utilisateur non authentifié qui consulte le site public.

Il peut uniquement lire :

- les catégories actives ;
- les articles publiés appartenant à une catégorie active ;
- les images associées aux articles visibles publiquement ;
- les ressources publiques de la marque.

### ADMIN

Administrateur chargé de gérer le catalogue.

Il peut :

- consulter son propre profil ;
- créer et modifier les catégories ;
- activer ou archiver logiquement les catégories ;
- créer et modifier les articles ;
- changer le statut des articles ;
- gérer les images des articles ;
- supprimer définitivement un article et ses images ;
- consulter les brouillons et les éléments archivés dans l'application Admin.

Il ne peut jamais :

- créer un administrateur ;
- consulter la liste complète des profils ;
- modifier un rôle ;
- activer ou désactiver un autre compte ;
- modifier le profil d'un autre administrateur ;
- gérer les ressources de marque réservées au `SUPER_ADMIN`.

### SUPER_ADMIN

Administrateur propriétaire de la plateforme.

Il dispose des permissions de l'`ADMIN` et peut également :

- consulter tous les profils administratifs ;
- gérer les comptes administratifs ;
- attribuer le rôle `ADMIN` ;
- activer ou désactiver un administrateur ;
- gérer les ressources de marque ;
- administrer l'ensemble du catalogue.

En V1, le compte propriétaire est le seul compte `SUPER_ADMIN` prévu.

## 3. Matrice des permissions

| Ressource / action | Public | ADMIN | SUPER_ADMIN |
|---|:---:|:---:|:---:|
| Lire les catégories actives | Oui | Oui | Oui |
| Lire toutes les catégories | Non | Oui | Oui |
| Créer ou modifier une catégorie | Non | Oui | Oui |
| Archiver une catégorie | Non | Oui | Oui |
| Lire les articles publiés visibles | Oui | Oui | Oui |
| Lire les brouillons et archives | Non | Oui | Oui |
| Créer ou modifier un article | Non | Oui | Oui |
| Publier ou archiver un article | Non | Oui | Oui |
| Supprimer définitivement un article et ses images | Non | Oui | Oui |
| Gérer les images d'article | Non | Oui | Oui |
| Lire son propre profil | Non | Oui | Oui |
| Lire tous les profils | Non | Non | Oui |
| Créer un administrateur | Non | Non | Oui |
| Modifier un rôle | Non | Non | Oui |
| Activer ou désactiver un administrateur | Non | Non | Oui |
| Lire les ressources publiques de marque | Oui | Oui | Oui |
| Modifier les ressources de marque | Non | Non | Oui |

Une catégorie reste supprimée logiquement par archivage. Un article peut être
supprimé définitivement par un `ADMIN` ou `SUPER_ADMIN` actif, exclusivement via
l'opération sécurisée qui enregistre aussi toutes ses images pour leur suppression
dans Storage. Les profils et catégories ne sont jamais supprimés physiquement en V1.

## 4. État d'un compte administratif

Un utilisateur authentifié doit posséder un profil correspondant dans `profiles`.
Le profil doit également avoir `is_active = true` pour obtenir des permissions
administratives.

Un compte désactivé :

- ne peut plus lire les données privées du catalogue ;
- ne peut plus créer ni modifier de contenu ;
- ne conserve aucun droit grâce à un ancien rôle présent dans l'application ;
- reste conservé afin de préserver l'historique et la traçabilité.

## 5. Règles de sécurité obligatoires

- Les rôles reconnus sont uniquement `SUPER_ADMIN` et `ADMIN`.
- Le rôle utilisé pour autoriser une opération provient de la base de données.
- Les informations envoyées par l'application Flutter ne déterminent jamais le rôle.
- Une session Supabase valide ne suffit pas : le profil doit être actif.
- Un `ADMIN` ne peut pas augmenter ses propres privilèges.
- Un `ADMIN` ne peut pas modifier directement ou indirectement un autre profil.
- La clé Supabase `service_role` ne doit jamais être intégrée à l'application Android
  ni au site public.

## 6. Provisionnement des administrateurs

La création d'un utilisateur Supabase Auth exige un contexte privilégié. Cette
opération ne devra pas être exécutée directement depuis Flutter avec une clé
`service_role`.

En V1, les comptes sont créés manuellement depuis le tableau de bord Supabase par
le propriétaire `SUPER_ADMIN`. Après la création dans Supabase Auth, le profil
correspondant reçoit le rôle `ADMIN` ou `SUPER_ADMIN` prévu.

L'application Flutter ne crée donc aucun compte Auth en V1 et ne contient aucune
clé privilégiée. Une fonction Supabase sécurisée pourra remplacer ce processus dans
une version future si la gestion des créations de comptes doit intégrer l'application.
