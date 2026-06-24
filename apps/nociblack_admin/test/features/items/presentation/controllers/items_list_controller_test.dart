import 'package:flutter_test/flutter_test.dart';
import 'package:nociblack/features/items/domain/entities/catalog_item.dart';
import 'package:nociblack/features/items/domain/entities/item_deletion_result.dart';
import 'package:nociblack/features/items/domain/errors/item_failure.dart';
import 'package:nociblack/features/items/presentation/controllers/items_list_controller.dart';

import '../../../../helpers/catalog_item_fixture.dart';
import '../../../../helpers/fake_item_repository.dart';

void main() {
  test('loads current items from the matching repository method', () async {
    final item = buildCatalogItem();
    final repository = FakeItemRepository(currentItems: [item]);
    final controller = ItemsListController(
      repository: repository,
      collection: ItemsCollection.current,
    );
    addTearDown(controller.dispose);

    await controller.load();

    expect(controller.status, ItemsListStatus.success);
    expect(controller.items, [item]);
    expect(repository.currentCalls, 1);
    expect(repository.archivedCalls, 0);
    expect(repository.retryCleanupCalls, 1);
  });

  test('loads archived items from the matching repository method', () async {
    final item = buildCatalogItem(status: ItemStatus.archived);
    final repository = FakeItemRepository(archivedItems: [item]);
    final controller = ItemsListController(
      repository: repository,
      collection: ItemsCollection.archived,
    );
    addTearDown(controller.dispose);

    await controller.load();

    expect(controller.status, ItemsListStatus.success);
    expect(controller.items, [item]);
    expect(repository.currentCalls, 0);
    expect(repository.archivedCalls, 1);
  });

  test('exposes a stable error when loading fails', () async {
    final repository = FakeItemRepository(
      currentFailure: const ItemsLoadFailure(),
    );
    final controller = ItemsListController(
      repository: repository,
      collection: ItemsCollection.current,
    );
    addTearDown(controller.dispose);

    await controller.load();

    expect(controller.status, ItemsListStatus.failure);
    expect(controller.items, isEmpty);
    expect(
      controller.errorMessage,
      'Impossible de charger les articles pour le moment.',
    );
  });

  test('archives an item and refreshes the current collection', () async {
    final item = buildCatalogItem();
    final repository = FakeItemRepository(currentItems: [item]);
    final controller = ItemsListController(
      repository: repository,
      collection: ItemsCollection.current,
    );
    addTearDown(controller.dispose);

    await controller.load();
    final wasArchived = await controller.archiveItem(item.id);

    expect(wasArchived, isTrue);
    expect(repository.archiveCalls, 1);
    expect(repository.lastArchivedItemId, item.id);
    expect(repository.currentCalls, 2);
    expect(controller.items, isEmpty);
  });

  test('exposes the business error when archiving fails', () async {
    final item = buildCatalogItem();
    final repository = FakeItemRepository(
      currentItems: [item],
      archiveFailure: const ItemSaveFailure(),
    );
    final controller = ItemsListController(
      repository: repository,
      collection: ItemsCollection.current,
    );
    addTearDown(controller.dispose);

    await controller.load();
    final wasArchived = await controller.archiveItem(item.id);

    expect(wasArchived, isFalse);
    expect(controller.items, [item]);
    expect(
      controller.errorMessage,
      'Impossible d’enregistrer l’article pour le moment.',
    );
  });

  test('restores an item and refreshes the archived collection', () async {
    final item = buildCatalogItem(status: ItemStatus.archived);
    final repository = FakeItemRepository(archivedItems: [item]);
    final controller = ItemsListController(
      repository: repository,
      collection: ItemsCollection.archived,
    );
    addTearDown(controller.dispose);

    await controller.load();
    final wasRestored = await controller.restoreItem(item.id);

    expect(wasRestored, isTrue);
    expect(repository.restoreCalls, 1);
    expect(repository.lastRestoredItemId, item.id);
    expect(repository.archivedCalls, 2);
    expect(controller.items, isEmpty);
    expect(repository.currentItems.single.status, ItemStatus.draft);
  });

  test('exposes the business error when restoring fails', () async {
    final item = buildCatalogItem(status: ItemStatus.archived);
    final repository = FakeItemRepository(
      archivedItems: [item],
      restoreFailure: const ItemRestoreFailure(),
    );
    final controller = ItemsListController(
      repository: repository,
      collection: ItemsCollection.archived,
    );
    addTearDown(controller.dispose);

    await controller.load();
    final wasRestored = await controller.restoreItem(item.id);

    expect(wasRestored, isFalse);
    expect(controller.items, [item]);
    expect(
      controller.errorMessage,
      'Impossible de restaurer l’article pour le moment.',
    );
  });

  test('deletes an item and refreshes the current collection', () async {
    final item = buildCatalogItem();
    final repository = FakeItemRepository(currentItems: [item]);
    final controller = ItemsListController(
      repository: repository,
      collection: ItemsCollection.current,
    );
    addTearDown(controller.dispose);

    await controller.load();
    final result = await controller.deleteItem(item.id);

    expect(result?.hasPendingStorageCleanup, isFalse);
    expect(repository.deleteCalls, 1);
    expect(repository.lastDeletedItemId, item.id);
    expect(repository.currentCalls, 2);
    expect(controller.items, isEmpty);
  });

  test('returns pending storage cleanup information after deletion', () async {
    final item = buildCatalogItem();
    final repository = FakeItemRepository(
      currentItems: [item],
      deletionResult: const ItemDeletionResult(
        pendingStorageObjectCount: 2,
      ),
    );
    final controller = ItemsListController(
      repository: repository,
      collection: ItemsCollection.current,
    );
    addTearDown(controller.dispose);

    await controller.load();
    final result = await controller.deleteItem(item.id);

    expect(result?.pendingStorageObjectCount, 2);
    expect(controller.items, isEmpty);
  });

  test('keeps the item and exposes the business error when deletion fails', () async {
    final item = buildCatalogItem();
    final repository = FakeItemRepository(
      currentItems: [item],
      deleteFailure: const ItemDeleteFailure(),
    );
    final controller = ItemsListController(
      repository: repository,
      collection: ItemsCollection.current,
    );
    addTearDown(controller.dispose);

    await controller.load();
    final result = await controller.deleteItem(item.id);

    expect(result, isNull);
    expect(controller.items, [item]);
    expect(
      controller.errorMessage,
      'Impossible de supprimer définitivement l’article pour le moment.',
    );
  });
}
