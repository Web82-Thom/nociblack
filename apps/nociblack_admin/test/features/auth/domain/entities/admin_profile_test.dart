import 'package:flutter_test/flutter_test.dart';
import 'package:nociblack/features/auth/domain/entities/admin_profile.dart';

void main() {
  group('AdminRole.fromDatabase', () {
    test('maps the supported database roles', () {
      expect(AdminRole.fromDatabase('ADMIN'), AdminRole.admin);
      expect(AdminRole.fromDatabase('SUPER_ADMIN'), AdminRole.superAdmin);
    });

    test('rejects an unknown database role', () {
      expect(
        () => AdminRole.fromDatabase('USER'),
        throwsA(isA<FormatException>()),
      );
    });
  });
}
