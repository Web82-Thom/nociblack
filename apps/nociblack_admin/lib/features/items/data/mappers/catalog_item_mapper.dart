import '../../domain/entities/catalog_item.dart';

/// Convertit une ligne PostgREST enrichie en entité métier.
abstract final class CatalogItemMapper {
  static CatalogItem fromJson(Map<String, dynamic> json) {
    final category = json['categories'] as Map<String, dynamic>?;
    final images = (json['item_images'] as List<dynamic>? ?? const [])
        .cast<Map<String, dynamic>>();
    final primaryImage = images.where((image) => image['is_primary'] == true);

    return CatalogItem(
      id: json['id'] as String,
      categoryId: json['category_id'] as String,
      categoryName: category?['name'] as String? ?? 'Catégorie inconnue',
      title: json['title'] as String,
      description: json['description'] as String?,
      priceCents: json['price_cents'] as int,
      stockQuantity: json['stock_quantity'] as int,
      sku: json['sku'] as String,
      status: ItemStatus.fromDatabase(json['status'] as String),
      displayOrder: json['display_order'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      primaryImagePath: primaryImage.isEmpty
          ? null
          : primaryImage.first['image_url'] as String?,
    );
  }
}
