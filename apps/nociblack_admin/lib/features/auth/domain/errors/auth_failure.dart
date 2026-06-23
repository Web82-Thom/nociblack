/// Erreur d'authentification exploitable par la couche de présentation.
///
/// Le repository transforme les exceptions techniques Supabase en erreurs
/// métier stables afin que les widgets n'aient jamais à interpréter le SDK.
sealed class AuthFailure implements Exception {
  const AuthFailure(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Les identifiants fournis ne permettent pas d'ouvrir une session.
final class InvalidCredentialsFailure extends AuthFailure {
  const InvalidCredentialsFailure()
    : super('Adresse e-mail ou mot de passe incorrect.');
}

/// La session existe, mais aucun profil administratif actif n'est autorisé.
final class UnauthorizedAdminFailure extends AuthFailure {
  const UnauthorizedAdminFailure()
    : super('Ce compte ne possède pas un accès administrateur actif.');
}

/// Supabase ou le réseau n'a pas permis de terminer l'opération.
final class AuthTechnicalFailure extends AuthFailure {
  const AuthTechnicalFailure()
    : super('La connexion est momentanément indisponible.');
}
