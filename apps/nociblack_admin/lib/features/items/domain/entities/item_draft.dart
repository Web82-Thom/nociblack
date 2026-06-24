/// Données nécessaires à la création d'un article brouillon.
final class ItemDraft {
  const ItemDraft({
    required this.categoryId,
    required this.title,
    required this.slug,
    required this.priceCents,
    required this.stockQuantity,
    required this.sku,
    required this.displayOrder,
    this.description,
  });

  final String categoryId;
  final String title;
  final String slug;
  final String? description;
  final int priceCents;
  final int stockQuantity;
  final String sku;
  final int displayOrder;
}
