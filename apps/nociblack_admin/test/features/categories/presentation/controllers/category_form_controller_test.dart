import 'package:flutter_test/flutter_test.dart';
import 'package:nociblack/features/categories/domain/entities/category_draft.dart';
import 'package:nociblack/features/categories/domain/errors/category_failure.dart';
import 'package:nociblack/features/categories/presentation/controllers/category_form_controller.dart';

import '../../../../helpers/fake_category_repository.dart';
import '../../../../helpers/catalog_category_fixture.dart';

void main() {
  const draft = CategoryDraft(
    name: 'Parfums',
    slug: 'parfums',
    description: 'Parfums du catalogue',
    displayOrder: 0,
  );

  test('creates a category through the repository', () async {
    final repository = FakeCategoryRepository();
    final controller = CategoryFormController(repository);
    addTearDown(controller.dispose);

    final result = await controller.save(draft: draft);

    expect(result, isTrue);
    expect(controller.errorMessage, isNull);
    expect(repository.categories.single.name, 'Parfums');
  });

  test('exposes a conflict returned by the repository', () async {
    final repository = FakeCategoryRepository(
      failure: const CategoryConflictFailure(),
    );
    final controller = CategoryFormController(repository);
    addTearDown(controller.dispose);

    final result = await controller.save(draft: draft);

    expect(result, isFalse);
    expect(
      controller.errorMessage,
      'Une catégorie possède déjà ce nom ou ce slug.',
    );
  });

  test('updates an existing category through the repository', () async {
    final existing = buildCatalogCategory(name: 'Ancien nom');
    final repository = FakeCategoryRepository(
      categories: [existing],
      allCategories: [existing],
    );
    final controller = CategoryFormController(repository);
    addTearDown(controller.dispose);

    final result = await controller.save(
      categoryId: existing.id,
      draft: const CategoryDraft(
        name: 'Nouveau nom',
        slug: 'nouveau-nom',
        displayOrder: 2,
      ),
    );

    expect(result, isTrue);
    expect(repository.allCategories!.single.name, 'Nouveau nom');
    expect(repository.allCategories!.single.displayOrder, 2);
  });
}
