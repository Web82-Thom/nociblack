import 'dart:async';

import 'package:nociblack/features/auth/domain/entities/admin_profile.dart';
import 'package:nociblack/features/auth/domain/errors/auth_failure.dart';
import 'package:nociblack/features/auth/domain/repositories/auth_repository.dart';

/// Repository Auth contrôlable utilisé par les tests sans accès réseau.
final class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository({
    this.currentProfile,
    this.profileAfterSignIn = defaultAdminProfile,
    this.signInFailure,
  });

  static const defaultAdminProfile = AdminProfile(
    id: 'admin-id',
    email: 'admin@nociblack.test',
    role: AdminRole.admin,
    isActive: true,
    firstName: 'Admin',
  );

  final StreamController<bool> _sessionController =
      StreamController<bool>.broadcast();

  AdminProfile? currentProfile;
  AdminProfile profileAfterSignIn;
  AuthFailure? signInFailure;

  @override
  Stream<bool> get sessionChanges => _sessionController.stream;

  @override
  Future<AdminProfile?> getCurrentProfile() async => currentProfile;

  @override
  Future<AdminProfile> signIn({
    required String email,
    required String password,
  }) async {
    if (signInFailure case final failure?) throw failure;

    currentProfile = profileAfterSignIn;
    _sessionController.add(true);
    return profileAfterSignIn;
  }

  @override
  Future<void> signOut() async {
    currentProfile = null;
    _sessionController.add(false);
  }

  Future<void> dispose() => _sessionController.close();
}
