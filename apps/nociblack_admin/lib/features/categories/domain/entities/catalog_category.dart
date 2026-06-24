/// Catégorie disponible dans le catalogue administratif.
final class CatalogCategory {
  const CatalogCategory({
    required this.id,
    required this.name,
    required this.slug,
    required this.displayOrder,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    this.description,
  });

  final String id;
  final String name;
  final String slug;
  final String? description;
  final int displayOrder;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
}
