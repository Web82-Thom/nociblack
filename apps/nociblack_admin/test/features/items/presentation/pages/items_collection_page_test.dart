import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nociblack/features/categories/domain/repositories/category_repository.dart';
import 'package:nociblack/features/items/domain/errors/item_failure.dart';
import 'package:nociblack/features/items/domain/entities/catalog_item.dart';
import 'package:nociblack/features/items/domain/entities/item_deletion_result.dart';
import 'package:nociblack/features/items/presentation/pages/item_archive_page.dart';
import 'package:nociblack/features/items/presentation/pages/items_list_page.dart';

import '../../../../helpers/catalog_item_fixture.dart';
import '../../../../helpers/fake_item_repository.dart';
import '../../../../helpers/fake_item_image_creation_service.dart';

// Simple fake to satisfy the CategoryRepository dependency in tests.
class FakeCategoryRepository implements CategoryRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  testWidgets('renders the items returned by the repository', (tester) async {
    final repository = FakeItemRepository(currentItems: [buildCatalogItem()]);

    await tester.pumpWidget(
      MaterialApp(
        home: ItemsListPage(
          itemRepository: repository,
          categoryRepository: FakeCategoryRepository(),
          itemImageCreationService: FakeItemImageCreationService(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Article test'), findsOneWidget);
    expect(find.text('Catégorie test • REF SKU-TEST'), findsOneWidget);
    expect(find.text('12,99 €'), findsOneWidget);
    expect(find.text('Stock : 4'), findsOneWidget);
    expect(find.text('Brouillon'), findsOneWidget);
  });

  testWidgets('renders an empty state when no item exists', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: ItemsListPage(
          itemRepository: FakeItemRepository(),
          categoryRepository: FakeCategoryRepository(),
          itemImageCreationService: FakeItemImageCreationService(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Aucun article à afficher.'), findsOneWidget);
  });

  testWidgets('renders an error and retries the request', (tester) async {
    final repository = FakeItemRepository(
      currentFailure: const ItemsLoadFailure(),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: ItemsListPage(
          itemRepository: repository,
          categoryRepository: FakeCategoryRepository(),
          itemImageCreationService: FakeItemImageCreationService(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.text('Impossible de charger les articles pour le moment.'),
      findsOneWidget,
    );

    repository.currentFailure = null;
    await tester.tap(find.text('Réessayer'));
    await tester.pumpAndSettle();

    expect(repository.currentCalls, 2);
    expect(find.text('Aucun article à afficher.'), findsOneWidget);
  });

  testWidgets('confirms the archive and removes the item from the list', (
    tester,
  ) async {
    final item = buildCatalogItem();
    final repository = FakeItemRepository(currentItems: [item]);

    await tester.pumpWidget(
      MaterialApp(
        home: ItemsListPage(
          itemRepository: repository,
          categoryRepository: FakeCategoryRepository(),
          itemImageCreationService: FakeItemImageCreationService(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.drag(find.byType(Dismissible), const Offset(500, 0));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Oui'));
    await tester.pumpAndSettle();

    expect(repository.lastArchivedItemId, item.id);
    expect(find.text('Article test'), findsNothing);
    expect(find.text('Article archivé.'), findsOneWidget);
  });

  testWidgets('keeps the item and displays the archive failure', (
    tester,
  ) async {
    final repository = FakeItemRepository(
      currentItems: [buildCatalogItem()],
      archiveFailure: const ItemSaveFailure(),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: ItemsListPage(
          itemRepository: repository,
          categoryRepository: FakeCategoryRepository(),
          itemImageCreationService: FakeItemImageCreationService(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.drag(find.byType(Dismissible), const Offset(500, 0));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Oui'));
    await tester.pumpAndSettle();

    expect(find.text('Article test'), findsOneWidget);
    expect(
      find.text('Impossible d’enregistrer l’article pour le moment.'),
      findsOneWidget,
    );
  });

  testWidgets('restores an archived item as a draft', (tester) async {
    final item = buildCatalogItem(status: ItemStatus.archived);
    final repository = FakeItemRepository(archivedItems: [item]);

    await tester.pumpWidget(
      MaterialApp(
        home: ItemArchivePage(
          itemRepository: repository,
          categoryRepository: FakeCategoryRepository(),
          itemImageCreationService: FakeItemImageCreationService(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.drag(find.byType(Dismissible), const Offset(500, 0));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Restaurer'));
    await tester.pumpAndSettle();

    expect(repository.lastRestoredItemId, item.id);
    expect(find.text('Article test'), findsNothing);
    expect(find.text('Article restauré en brouillon.'), findsOneWidget);
  });

  testWidgets('keeps the archived item when restoration fails', (tester) async {
    final repository = FakeItemRepository(
      archivedItems: [buildCatalogItem(status: ItemStatus.archived)],
      restoreFailure: const ItemRestoreFailure(),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: ItemArchivePage(
          itemRepository: repository,
          categoryRepository: FakeCategoryRepository(),
          itemImageCreationService: FakeItemImageCreationService(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.drag(find.byType(Dismissible), const Offset(500, 0));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Restaurer'));
    await tester.pumpAndSettle();

    expect(find.text('Article test'), findsOneWidget);
    expect(
      find.text('Impossible de restaurer l’article pour le moment.'),
      findsOneWidget,
    );
  });

  testWidgets('permanently deletes an item from the current collection', (
    tester,
  ) async {
    final item = buildCatalogItem();
    final repository = FakeItemRepository(currentItems: [item]);

    await tester.pumpWidget(
      MaterialApp(
        home: ItemsListPage(
          itemRepository: repository,
          categoryRepository: FakeCategoryRepository(),
          itemImageCreationService: FakeItemImageCreationService(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.drag(find.byType(Dismissible), const Offset(-500, 0));
    await tester.pumpAndSettle();

    final deleteButton = find.byKey(const Key('permanent_delete_button'));
    expect(tester.widget<FilledButton>(deleteButton).onPressed, isNull);

    await tester.enterText(
      find.byKey(const Key('permanent_delete_confirmation_field')),
      'SUPPRIMER',
    );
    await tester.pump();
    await tester.tap(deleteButton);
    await tester.pumpAndSettle();

    expect(repository.lastDeletedItemId, item.id);
    expect(find.text('Article test'), findsNothing);
    expect(find.text('Article supprimé définitivement.'), findsOneWidget);
  });

  testWidgets('permanently deletes an item from the archive collection', (
    tester,
  ) async {
    final item = buildCatalogItem(status: ItemStatus.archived);
    final repository = FakeItemRepository(
      archivedItems: [item],
      deletionResult: const ItemDeletionResult(pendingStorageObjectCount: 1),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: ItemArchivePage(
          itemRepository: repository,
          categoryRepository: FakeCategoryRepository(),
          itemImageCreationService: FakeItemImageCreationService(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.drag(find.byType(Dismissible), const Offset(-500, 0));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('permanent_delete_confirmation_field')),
      'supprimer',
    );
    await tester.pump();
    await tester.tap(find.byKey(const Key('permanent_delete_button')));
    await tester.pumpAndSettle();

    expect(repository.lastDeletedItemId, item.id);
    expect(find.text('Article test'), findsNothing);
    expect(
      find.text(
        'Article supprimé. Le nettoyage des images sera repris automatiquement.',
      ),
      findsOneWidget,
    );
  });
}
