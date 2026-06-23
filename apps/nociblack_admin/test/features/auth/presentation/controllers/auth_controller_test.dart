import 'package:flutter_test/flutter_test.dart';
import 'package:nociblack/features/auth/domain/errors/auth_failure.dart';
import 'package:nociblack/features/auth/presentation/controllers/auth_controller.dart';

import '../../../../helpers/fake_auth_repository.dart';

void main() {
  late FakeAuthRepository repository;
  late AuthController controller;

  setUp(() {
    repository = FakeAuthRepository();
    controller = AuthController(repository);
  });

  tearDown(() async {
    controller.dispose();
    await repository.dispose();
  });

  test('initializes as unauthenticated without a restored session', () async {
    await controller.initialize();

    expect(controller.status, AuthenticationStatus.unauthenticated);
    expect(controller.profile, isNull);
  });

  test('restores an existing active administrator session', () async {
    repository.currentProfile = FakeAuthRepository.defaultAdminProfile;

    await controller.initialize();

    expect(controller.status, AuthenticationStatus.authenticated);
    expect(controller.profile, FakeAuthRepository.defaultAdminProfile);
  });

  test('authenticates with a valid administrator account', () async {
    await controller.initialize();

    final result = await controller.signIn(
      email: 'admin@nociblack.test',
      password: 'valid-password',
    );

    expect(result, isTrue);
    expect(controller.status, AuthenticationStatus.authenticated);
    expect(controller.profile, FakeAuthRepository.defaultAdminProfile);
    expect(controller.errorMessage, isNull);
  });

  test('exposes a stable message when authentication fails', () async {
    repository.signInFailure = const InvalidCredentialsFailure();
    await controller.initialize();

    final result = await controller.signIn(
      email: 'admin@nociblack.test',
      password: 'wrong-password',
    );

    expect(result, isFalse);
    expect(controller.status, AuthenticationStatus.unauthenticated);
    expect(controller.profile, isNull);
    expect(
      controller.errorMessage,
      'Adresse e-mail ou mot de passe incorrect.',
    );
  });

  test('clears the authenticated session on sign out', () async {
    repository.currentProfile = FakeAuthRepository.defaultAdminProfile;
    await controller.initialize();

    await controller.signOut();

    expect(controller.status, AuthenticationStatus.unauthenticated);
    expect(controller.profile, isNull);
    expect(repository.currentProfile, isNull);
  });
}
