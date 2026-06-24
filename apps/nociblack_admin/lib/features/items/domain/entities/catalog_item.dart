/// États métier possibles d'un article du catalogue.
enum ItemStatus {
  draft,
  published,
  archived;

  factory ItemStatus.fromDatabase(String value) {
    return switch (value) {
      'DRAFT' => ItemStatus.draft,
      'PUBLISHED' => ItemStatus.published,
      'ARCHIVED' => ItemStatus.archived,
      _ => throw FormatException('Statut d’article inconnu : $value'),
    };
  }
}

/// Article du catalogue indépendant de Supabase et de Flutter.
final class CatalogItem {
  const CatalogItem({
    required this.id,
    required this.categoryId,
    required this.categoryName,
    required this.title,
    required this.priceCents,
    required this.stockQuantity,
    required this.sku,
    required this.status,
    required this.displayOrder,
    required this.createdAt,
    required this.updatedAt,
    this.description,
    this.primaryImagePath,
  });

  final String id;
  final String categoryId;
  final String categoryName;
  final String title;
  final String? description;
  final int priceCents;
  final int stockQuantity;
  final String sku;
  final ItemStatus status;
  final int displayOrder;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? primaryImagePath;
}
