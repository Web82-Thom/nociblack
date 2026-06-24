import 'package:flutter_test/flutter_test.dart';
import 'package:nociblack/features/categories/domain/entities/category_draft.dart';
import 'package:nociblack/features/categories/domain/errors/category_failure.dart';
import 'package:nociblack/features/categories/presentation/controllers/category_form_controller.dart';

import '../../../../helpers/fake_category_repository.dart';

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

    final result = await controller.create(draft);

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

    final result = await controller.create(draft);

    expect(result, isFalse);
    expect(
      controller.errorMessage,
      'Une catégorie possède déjà ce nom ou ce slug.',
    );
  });
}
