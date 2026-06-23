/// Rôles administratifs reconnus par l'application.
enum AdminRole {
  admin,
  superAdmin;

  /// Convertit la valeur PostgreSQL sans laisser une chaîne métier circuler
  /// dans le reste de l'application.
  factory AdminRole.fromDatabase(String value) {
    return switch (value) {
      'ADMIN' => AdminRole.admin,
      'SUPER_ADMIN' => AdminRole.superAdmin,
      _ => throw FormatException('Rôle administrateur inconnu : $value'),
    };
  }
}

/// Profil de l'administrateur actuellement authentifié.
///
/// Cette entité ne dépend ni de Flutter ni de Supabase. Elle pourra donc être
/// utilisée par les contrôleurs et les tests sans dépendance technique.
final class AdminProfile {
  const AdminProfile({
    required this.id,
    required this.email,
    required this.role,
    required this.isActive,
    this.firstName,
    this.lastName,
  });

  final String id;
  final String email;
  final AdminRole role;
  final bool isActive;
  final String? firstName;
  final String? lastName;
}
