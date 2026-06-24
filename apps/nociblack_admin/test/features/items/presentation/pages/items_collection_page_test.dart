import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nociblack/features/categories/domain/repositories/category_repository.dart';
import 'package:nociblack/features/items/domain/errors/item_failure.dart';
import 'package:nociblack/features/items/presentation/pages/items_list_page.dart';

import '../../../../helpers/catalog_item_fixture.dart';
import '../../../../helpers/fake_item_repository.dart';

// Simple fake to satisfy the CategoryRepository dependency in tests.
class FakeCategoryRepository implements CategoryRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  testWidgets('renders the items returned by the repository', (tester) async {
    final repository = FakeItemRepository(currentItems: [buildCatalogItem()]);

    await tester.pumpWidget(
      MaterialApp(home: ItemsListPage(itemRepository: repository, categoryRepository: FakeCategoryRepository(), )),
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
      MaterialApp(home: ItemsListPage(itemRepository: FakeItemRepository(), categoryRepository: FakeCategoryRepository(),)),
    );
    await tester.pumpAndSettle();

    expect(find.text('Aucun article à afficher.'), findsOneWidget);
  });

  testWidgets('renders an error and retries the request', (tester) async {
    final repository = FakeItemRepository(
      currentFailure: const ItemsLoadFailure(),
    );

    await tester.pumpWidget(
      MaterialApp(home: ItemsListPage(itemRepository: repository, categoryRepository: FakeCategoryRepository())),
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
}
