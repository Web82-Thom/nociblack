import 'package:flutter_test/flutter_test.dart';
import 'package:nociblack/features/items/domain/entities/item_draft.dart';
import 'package:nociblack/features/items/domain/errors/item_failure.dart';
import 'package:nociblack/features/items/presentation/controllers/item_form_controller.dart';

import '../../../../helpers/fake_item_repository.dart';

void main() {
  const draft = ItemDraft(
    categoryId: 'category-id',
    title: 'Article test',
    slug: 'article-test',
    priceCents: 1999,
    stockQuantity: 4,
    sku: 'REF-001',
    displayOrder: 0,
  );

  test('creates a draft item through the repository', () async {
    final repository = FakeItemRepository();
    final controller = ItemFormController(repository);
    addTearDown(controller.dispose);

    final result = await controller.create(draft);

    expect(result, isTrue);
    expect(repository.lastCreatedDraft, draft);
    expect(repository.currentItems.single.status.name, 'draft');
  });

  test('exposes a slug or reference conflict', () async {
    final repository = FakeItemRepository(
      saveFailure: const ItemConflictFailure(),
    );
    final controller = ItemFormController(repository);
    addTearDown(controller.dispose);

    final result = await controller.create(draft);

    expect(result, isFalse);
    expect(
      controller.errorMessage,
      'Un article possède déjà ce slug ou cette REF.',
    );
  });
}
