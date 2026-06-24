import 'package:nociblack/features/categories/domain/entities/catalog_category.dart';
import 'package:nociblack/features/categories/domain/entities/category_draft.dart';
import 'package:nociblack/features/categories/domain/errors/category_failure.dart';
import 'package:nociblack/features/categories/domain/repositories/category_repository.dart';

final class FakeCategoryRepository implements CategoryRepository {
  FakeCategoryRepository({
    this.categories = const [],
    this.allCategories,
    this.failure,
  });

  List<CatalogCategory> categories;
  List<CatalogCategory>? allCategories;
  CategoryFailure? failure;
  int calls = 0;

  @override
  Future<List<CatalogCategory>> getActiveCategories() async {
    calls++;
    if (failure case final loadFailure?) throw loadFailure;
    return categories;
  }

  @override
  Future<List<CatalogCategory>> getAllCategories() async {
    calls++;
    if (failure case final loadFailure?) throw loadFailure;
    return allCategories ?? categories;
  }

  @override
  Future<CatalogCategory> createCategory(CategoryDraft draft) async {
    calls++;
    if (failure case final saveFailure?) throw saveFailure;

    final now = DateTime.utc(2026, 6, 24, 10);
    final existingAllCategories = allCategories ?? categories;
    final category = CatalogCategory(
      id: 'created-category-id',
      name: draft.name,
      slug: draft.slug,
      description: draft.description,
      displayOrder: draft.displayOrder,
      isActive: true,
      createdAt: now,
      updatedAt: now,
    );
    categories = [...categories, category];
    allCategories = [...existingAllCategories, category];
    return category;
  }
}
