import 'package:flutter_test/flutter_test.dart';
import 'package:nociblack/features/items/data/mappers/catalog_item_mapper.dart';
import 'package:nociblack/features/items/domain/entities/catalog_item.dart';

void main() {
  group('CatalogItemMapper', () {
    test('maps an enriched Supabase row to the domain entity', () {
      final item = CatalogItemMapper.fromJson({
        'id': 'item-id',
        'category_id': 'category-id',
        'title': 'Article test',
        'description': 'Description',
        'price_cents': 1299,
        'stock_quantity': 4,
        'sku': 'SKU-TEST',
        'status': 'PUBLISHED',
        'display_order': 2,
        'created_at': '2026-06-24T08:00:00.000Z',
        'updated_at': '2026-06-24T09:00:00.000Z',
        'categories': {'name': 'Catégorie test'},
        'item_images': [
          {
            'image_url':
                'item-images/items/item-id/00000000-0000-4000-8000-000000000002.jpg',
            'is_primary': false,
            'display_order': 2,
          },
          {
            'image_url':
                'item-images/items/item-id/00000000-0000-4000-8000-000000000001.jpg',
            'is_primary': true,
            'display_order': 1,
          },
        ],
      });

      expect(item.id, 'item-id');
      expect(item.categoryName, 'Catégorie test');
      expect(item.status, ItemStatus.published);
      expect(item.priceCents, 1299);
      expect(
        item.primaryImagePath,
        'item-images/items/item-id/00000000-0000-4000-8000-000000000001.jpg',
      );
      expect(item.createdAt, DateTime.utc(2026, 6, 24, 8));
    });

    test('supports a draft without an image', () {
      final item = CatalogItemMapper.fromJson({
        'id': 'item-id',
        'category_id': 'category-id',
        'title': 'Brouillon',
        'description': null,
        'price_cents': 0,
        'stock_quantity': 0,
        'sku': 'DRAFT-1',
        'status': 'DRAFT',
        'display_order': 0,
        'created_at': '2026-06-24T08:00:00.000Z',
        'updated_at': '2026-06-24T08:00:00.000Z',
        'categories': {'name': 'Catégorie test'},
        'item_images': <Map<String, dynamic>>[],
      });

      expect(item.status, ItemStatus.draft);
      expect(item.primaryImagePath, isNull);
    });

    test('rejects an unsupported database status', () {
      expect(
        () => ItemStatus.fromDatabase('DELETED'),
        throwsA(isA<FormatException>()),
      );
    });
  });
}
