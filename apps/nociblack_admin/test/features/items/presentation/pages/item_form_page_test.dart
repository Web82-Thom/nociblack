import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nociblack/features/categories/domain/errors/category_failure.dart';
import 'package:nociblack/features/items/presentation/pages/item_form_page.dart';

import '../../../../helpers/catalog_category_fixture.dart';
import '../../../../helpers/fake_category_repository.dart';

void main() {
  testWidgets('renders active categories in the selector', (tester) async {
    final category = buildCatalogCategory();

    await tester.pumpWidget(
      MaterialApp(
        home: ItemFormPage(
          categoryRepository: FakeCategoryRepository(categories: [category]),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('item_category_field')));
    await tester.pumpAndSettle();

    expect(find.text('Catégorie test'), findsOneWidget);
  });

  testWidgets('renders an empty state without an active category', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: ItemFormPage(
          categoryRepository: FakeCategoryRepository(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('Aucune catégorie active'), findsOneWidget);
  });

  testWidgets('renders an error and retries category loading', (tester) async {
    final repository = FakeCategoryRepository(
      failure: const CategoriesLoadFailure(),
    );

    await tester.pumpWidget(
      MaterialApp(home: ItemFormPage(categoryRepository: repository)),
    );
    await tester.pumpAndSettle();

    expect(
      find.text('Impossible de charger les catégories pour le moment.'),
      findsOneWidget,
    );

    repository.failure = null;
    await tester.tap(find.text('Réessayer'));
    await tester.pumpAndSettle();

    expect(repository.calls, 2);
    expect(find.textContaining('Aucune catégorie active'), findsOneWidget);
  });
}
