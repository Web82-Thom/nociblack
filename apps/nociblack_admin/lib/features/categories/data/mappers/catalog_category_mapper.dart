import '../../domain/entities/catalog_category.dart';

abstract final class CatalogCategoryMapper {
  static CatalogCategory fromJson(Map<String, dynamic> json) {
    return CatalogCategory(
      id: json['id'] as String,
      name: json['name'] as String,
      slug: json['slug'] as String,
      description: json['description'] as String?,
      displayOrder: json['display_order'] as int,
      isActive: json['is_active'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }
}
