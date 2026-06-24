import 'package:nociblack/features/items/domain/entities/catalog_item.dart';

CatalogItem buildCatalogItem({
  String id = 'item-id',
  String title = 'Article test',
  ItemStatus status = ItemStatus.draft,
  int priceCents = 1299,
  int stockQuantity = 4,
}) {
  return CatalogItem(
    id: id,
    categoryId: 'category-id',
    categoryName: 'Catégorie test',
    title: title,
    description: 'Description test',
    priceCents: priceCents,
    stockQuantity: stockQuantity,
    sku: 'SKU-TEST',
    status: status,
    displayOrder: 0,
    createdAt: DateTime.utc(2026, 6, 24, 8),
    updatedAt: DateTime.utc(2026, 6, 24, 9),
    primaryImagePath:
        'item-images/items/item-id/00000000-0000-4000-8000-000000000001.jpg',
  );
}
