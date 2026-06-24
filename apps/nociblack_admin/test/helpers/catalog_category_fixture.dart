import 'package:nociblack/features/categories/domain/entities/catalog_category.dart';

CatalogCategory buildCatalogCategory({
  String id = 'category-id',
  String name = 'Catégorie test',
  bool isActive = true,
}) {
  return CatalogCategory(
    id: id,
    name: name,
    slug: 'categorie-test',
    description: 'Description test',
    displayOrder: 0,
    isActive: isActive,
    createdAt: DateTime.utc(2026, 6, 24, 8),
    updatedAt: DateTime.utc(2026, 6, 24, 9),
  );
}
