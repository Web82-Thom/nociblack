import '../entities/admin_profile.dart';

/// Contrat d'accès à l'authentification administrative.
///
/// La couche présentation dépend de ce contrat, jamais directement du client
/// Supabase. Une implémentation factice pourra ainsi être injectée en test.
abstract interface class AuthRepository {
  /// Indique les ouvertures et fermetures de session observées par le backend.
  Stream<bool> get sessionChanges;

  /// Retourne le profil actif de la session restaurée, ou `null` sans session.
  Future<AdminProfile?> getCurrentProfile();

  /// Authentifie puis valide le profil `ADMIN` ou `SUPER_ADMIN` actif.
  Future<AdminProfile> signIn({
    required String email,
    required String password,
  });

  /// Ferme la session locale et distante.
  Future<void> signOut();
}
