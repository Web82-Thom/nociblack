class ItemImage {
  const ItemImage({
    required this.id,
    required this.itemId,
    required this.imageUrl,
    required this.displayOrder,
    required this.isPrimary,
    required this.createdAt,
  });

  final String id;
  final String itemId;
  final String imageUrl;
  final int displayOrder;
  final bool isPrimary;
  final DateTime createdAt;
}
