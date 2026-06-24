import 'package:flutter_test/flutter_test.dart';
import 'package:nociblack/features/categories/domain/errors/category_failure.dart';
import 'package:nociblack/features/categories/presentation/controllers/active_categories_controller.dart';

import '../../../../helpers/catalog_category_fixture.dart';
import '../../../../helpers/fake_category_repository.dart';

void main() {
  test('loads active categories from the repository', () async {
    final category = buildCatalogCategory();
    final repository = FakeCategoryRepository(categories: [category]);
    final controller = ActiveCategoriesController(repository);
    addTearDown(controller.dispose);

    await controller.load();

    expect(controller.status, ActiveCategoriesStatus.success);
    expect(controller.categories, [category]);
    expect(controller.errorMessage, isNull);
    expect(repository.calls, 1);
  });

  test('exposes a stable error when loading fails', () async {
    final repository = FakeCategoryRepository(
      failure: const CategoriesLoadFailure(),
    );
    final controller = ActiveCategoriesController(repository);
    addTearDown(controller.dispose);

    await controller.load();

    expect(controller.status, ActiveCategoriesStatus.failure);
    expect(controller.categories, isEmpty);
    expect(
      controller.errorMessage,
      'Impossible de charger les catégories pour le moment.',
    );
  });
}
