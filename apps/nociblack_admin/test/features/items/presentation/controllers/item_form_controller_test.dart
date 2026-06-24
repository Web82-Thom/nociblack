import 'package:flutter_test/flutter_test.dart';
import 'package:nociblack/features/items/domain/entities/item_draft.dart';
import 'package:nociblack/features/items/domain/errors/item_failure.dart';
import 'package:nociblack/features/items/presentation/controllers/item_form_controller.dart';

import '../../../../helpers/fake_item_repository.dart';
import '../../../../helpers/fake_item_image_creation_service.dart';

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
    final imageCreationService = FakeItemImageCreationService();
    final controller = ItemFormController(
      repository: repository,
      imageCreationService: imageCreationService,
    );
    addTearDown(controller.dispose);

    final result = await controller.create(draft);

    expect(result, isTrue);
    expect(repository.lastCreatedDraft, draft);
    expect(repository.currentItems.single.status.name, 'draft');
    expect(imageCreationService.lastItemId, 'created-item-id');
    expect(imageCreationService.lastSourcePaths, isEmpty);
  });

  test('exposes a slug or reference conflict', () async {
    final repository = FakeItemRepository(
      saveFailure: const ItemConflictFailure(),
    );
    final imageCreationService = FakeItemImageCreationService();
    final controller = ItemFormController(
      repository: repository,
      imageCreationService: imageCreationService,
    );
    addTearDown(controller.dispose);

    final result = await controller.create(draft);

    expect(result, isFalse);
    expect(
      controller.errorMessage,
      'Un article possède déjà ce slug ou cette REF.',
    );
    expect(imageCreationService.calls, 0);
  });

  test('creates the selected images with the generated item id', () async {
    final repository = FakeItemRepository();
    final imageCreationService = FakeItemImageCreationService();
    final controller = ItemFormController(
      repository: repository,
      imageCreationService: imageCreationService,
    );
    addTearDown(controller.dispose);

    final result = await controller.create(
      draft,
      imageSourcePaths: const ['first.png', 'second.heic'],
    );

    expect(result, isTrue);
    expect(imageCreationService.lastItemId, 'created-item-id');
    expect(imageCreationService.lastSourcePaths, const [
      'first.png',
      'second.heic',
    ]);
  });

  test('rolls back the created draft when image creation fails', () async {
    final repository = FakeItemRepository();
    final controller = ItemFormController(
      repository: repository,
      imageCreationService: FakeItemImageCreationService(
        failure: const ItemImageUploadFailure(),
      ),
    );
    addTearDown(controller.dispose);

    final result = await controller.create(
      draft,
      imageSourcePaths: const ['first.png'],
    );

    expect(result, isFalse);
    expect(repository.lastDeletedItemId, 'created-item-id');
    expect(repository.currentItems, isEmpty);
    expect(
      controller.errorMessage,
      'Impossible d’envoyer cette image pour le moment.',
    );
  });

  test('reports a rollback failure without hiding the partial draft', () async {
    final repository = FakeItemRepository(
      deleteFailure: const ItemDeleteFailure(),
    );
    final controller = ItemFormController(
      repository: repository,
      imageCreationService: FakeItemImageCreationService(
        failure: const ItemImageSaveFailure(),
      ),
    );
    addTearDown(controller.dispose);

    final result = await controller.create(
      draft,
      imageSourcePaths: const ['first.png'],
    );

    expect(result, isFalse);
    expect(repository.currentItems.single.id, 'created-item-id');
    expect(
      controller.errorMessage,
      'L’enregistrement des images a échoué et le brouillon créé n’a pas pu '
      'être annulé automatiquement.',
    );
  });
}
