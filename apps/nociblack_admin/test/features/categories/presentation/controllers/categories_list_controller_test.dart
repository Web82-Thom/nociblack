import 'package:flutter_test/flutter_test.dart';
import 'package:nociblack/features/categories/domain/errors/category_failure.dart';
import 'package:nociblack/features/categories/presentation/controllers/categories_list_controller.dart';

import '../../../../helpers/catalog_category_fixture.dart';
import '../../../../helpers/fake_category_repository.dart';

void main() {
  test('loads every category for administration', () async {
    final category = buildCatalogCategory();
    final repository = FakeCategoryRepository(allCategories: [category]);
    final controller = CategoriesListController(repository);
    addTearDown(controller.dispose);

    await controller.load();

    expect(controller.status, CategoriesListStatus.success);
    expect(controller.categories, [category]);
    expect(repository.calls, 1);
  });

  test('exposes a stable error when loading fails', () async {
    final repository = FakeCategoryRepository(
      failure: const CategoriesLoadFailure(),
    );
    final controller = CategoriesListController(repository);
    addTearDown(controller.dispose);

    await controller.load();

    expect(controller.status, CategoriesListStatus.failure);
    expect(controller.categories, isEmpty);
    expect(
      controller.errorMessage,
      'Impossible de charger les catégories pour le moment.',
    );
  });
}
