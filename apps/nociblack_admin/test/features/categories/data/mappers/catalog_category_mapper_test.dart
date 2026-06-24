import 'package:flutter_test/flutter_test.dart';
import 'package:nociblack/features/categories/data/mappers/catalog_category_mapper.dart';

void main() {
  test('maps a Supabase category row to the domain entity', () {
    final category = CatalogCategoryMapper.fromJson({
      'id': 'category-id',
      'name': 'Catégorie test',
      'slug': 'categorie-test',
      'description': 'Description',
      'display_order': 2,
      'is_active': true,
      'created_at': '2026-06-24T08:00:00.000Z',
      'updated_at': '2026-06-24T09:00:00.000Z',
    });

    expect(category.id, 'category-id');
    expect(category.name, 'Catégorie test');
    expect(category.slug, 'categorie-test');
    expect(category.description, 'Description');
    expect(category.displayOrder, 2);
    expect(category.isActive, isTrue);
    expect(category.createdAt, DateTime.utc(2026, 6, 24, 8));
  });
}
