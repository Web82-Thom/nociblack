import '../entities/catalog_category.dart';

/// Contrat de lecture des catégories utilisables par un nouvel article.
abstract interface class CategoryRepository {
  Future<List<CatalogCategory>> getActiveCategories();
}
