import 'package:nociblack/features/categories/domain/entities/catalog_category.dart';
import 'package:nociblack/features/categories/domain/errors/category_failure.dart';
import 'package:nociblack/features/categories/domain/repositories/category_repository.dart';

final class FakeCategoryRepository implements CategoryRepository {
  FakeCategoryRepository({this.categories = const [], this.failure});

  List<CatalogCategory> categories;
  CategoryFailure? failure;
  int calls = 0;

  @override
  Future<List<CatalogCategory>> getActiveCategories() async {
    calls++;
    if (failure case final loadFailure?) throw loadFailure;
    return categories;
  }
}
