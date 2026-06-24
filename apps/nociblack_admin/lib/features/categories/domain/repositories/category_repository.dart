import '../entities/catalog_category.dart';
import '../entities/category_draft.dart';

/// Contrat de lecture des catégories utilisables par un nouvel article.
abstract interface class CategoryRepository {
  Future<List<CatalogCategory>> getActiveCategories();

  Future<List<CatalogCategory>> getAllCategories();

  Future<CatalogCategory> createCategory(CategoryDraft draft);
}
