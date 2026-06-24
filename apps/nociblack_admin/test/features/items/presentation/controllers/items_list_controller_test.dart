import 'package:flutter_test/flutter_test.dart';
import 'package:nociblack/features/items/domain/entities/catalog_item.dart';
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
}
