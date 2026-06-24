import 'package:flutter_test/flutter_test.dart';
import 'package:nociblack/core/formatters/slug_generator.dart';

void main() {
  test('generates a database-compatible slug from French text', () {
    expect(SlugGenerator.fromText('  Vêtements & Été  '), 'vetements-ete');
    expect(SlugGenerator.fromText('Parfums  Homme'), 'parfums-homme');
    expect(SlugGenerator.fromText('---NociBlacK---'), 'nociblack');
  });
}
