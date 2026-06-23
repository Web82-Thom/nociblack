import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/admin_profile.dart';
import '../../domain/errors/auth_failure.dart';
import '../../domain/repositories/auth_repository.dart';

/// Implémentation Supabase du contrat d'authentification.
final class SupabaseAuthRepository implements AuthRepository {
  const SupabaseAuthRepository(this._client);

  final SupabaseClient _client;

  @override
  Stream<bool> get sessionChanges => _client.auth.onAuthStateChange
      .map((state) => state.session != null)
      .distinct();

  @override
  Future<AdminProfile?> getCurrentProfile() async {
    final user = _client.auth.currentUser;

    if (user == null) {
      return null;
    }

    return _loadActiveProfile(user.id);
  }

  @override
  Future<AdminProfile> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );
      final user = response.user;

      if (user == null) {
        throw const InvalidCredentialsFailure();
      }

      return await _loadActiveProfile(user.id);
    } on AuthFailure {
      rethrow;
    } on AuthException {
      throw const InvalidCredentialsFailure();
    } catch (_) {
      throw const AuthTechnicalFailure();
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } catch (_) {
      throw const AuthTechnicalFailure();
    }
  }

  Future<AdminProfile> _loadActiveProfile(String userId) async {
    try {
      final data = await _client
          .from('profiles')
          .select('id, email, role, first_name, last_name, is_active')
          .eq('id', userId)
          .maybeSingle();

      // Les RLS masquent déjà les profils inactifs ou non administratifs. Ce
      // contrôle défensif protège aussi le client si les politiques évoluent.
      if (data == null || data['is_active'] != true) {
        await _client.auth.signOut();
        throw const UnauthorizedAdminFailure();
      }

      final role = AdminRole.fromDatabase(data['role'] as String);

      return AdminProfile(
        id: data['id'] as String,
        email: data['email'] as String,
        role: role,
        isActive: data['is_active'] as bool,
        firstName: data['first_name'] as String?,
        lastName: data['last_name'] as String?,
      );
    } on AuthFailure {
      rethrow;
    } on PostgrestException {
      throw const AuthTechnicalFailure();
    } on FormatException {
      await _client.auth.signOut();
      throw const UnauthorizedAdminFailure();
    }
  }
}
