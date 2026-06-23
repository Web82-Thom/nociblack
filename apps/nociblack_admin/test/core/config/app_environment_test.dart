import 'package:flutter_test/flutter_test.dart';
import 'package:nociblack/core/config/app_environment.dart';

void main() {
  group('AppEnvironment', () {
    test('creates a normalized valid environment', () {
      final environment = AppEnvironment.fromValues(
        supabaseUrl: '  https://example.supabase.co  ',
        supabasePublishableKey: '  sb_publishable_test  ',
      );

      expect(environment.supabaseUrl, Uri.parse('https://example.supabase.co'));
      expect(environment.supabasePublishableKey, 'sb_publishable_test');
    });

    test('rejects an empty Supabase URL', () {
      expect(
        () => AppEnvironment.fromValues(
          supabaseUrl: '',
          supabasePublishableKey: 'sb_publishable_test',
        ),
        throwsA(isA<StateError>()),
      );
    });

    test('rejects a non-HTTPS Supabase URL', () {
      expect(
        () => AppEnvironment.fromValues(
          supabaseUrl: 'http://example.supabase.co',
          supabasePublishableKey: 'sb_publishable_test',
        ),
        throwsA(isA<StateError>()),
      );
    });

    test('rejects a Dashboard URL instead of the project API root', () {
      expect(
        () => AppEnvironment.fromValues(
          supabaseUrl: 'https://supabase.com/dashboard/project/project-ref',
          supabasePublishableKey: 'sb_publishable_test',
        ),
        throwsA(isA<StateError>()),
      );
    });

    test('rejects an empty publishable key', () {
      expect(
        () => AppEnvironment.fromValues(
          supabaseUrl: 'https://example.supabase.co',
          supabasePublishableKey: '',
        ),
        throwsA(isA<StateError>()),
      );
    });
  });
}
