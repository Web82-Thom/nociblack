import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nociblack/features/categories/domain/errors/category_failure.dart';
import 'package:nociblack/features/items/domain/errors/item_failure.dart';
import 'package:nociblack/features/items/presentation/pages/item_form_page.dart';

import '../../../../helpers/catalog_category_fixture.dart';
import '../../../../helpers/fake_category_repository.dart';
import '../../../../helpers/fake_item_repository.dart';

void main() {
  testWidgets('renders active categories in the selector', (tester) async {
    final category = buildCatalogCategory();

    await tester.pumpWidget(
      MaterialApp(
        home: ItemFormPage(
          categoryRepository: FakeCategoryRepository(categories: [category]),
          itemRepository: FakeItemRepository(),
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
          itemRepository: FakeItemRepository(),
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
      MaterialApp(
        home: ItemFormPage(
          categoryRepository: repository,
          itemRepository: FakeItemRepository(),
        ),
      ),
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

  testWidgets('creates a draft with normalized business values', (tester) async {
    final category = buildCatalogCategory();
    final itemRepository = FakeItemRepository();

    await tester.pumpWidget(
      MaterialApp(
        home: ItemFormPage(
          categoryRepository: FakeCategoryRepository(categories: [category]),
          itemRepository: itemRepository,
        ),
      ),
    );
    await tester.pumpAndSettle();
    await _fillRequiredFields(tester);
    await _tapSubmitButton(tester);
    await tester.pumpAndSettle();

    final draft = itemRepository.lastCreatedDraft!;
    expect(draft.categoryId, category.id);
    expect(draft.title, 'Article été');
    expect(draft.slug, 'article-ete');
    expect(draft.priceCents, 1999);
    expect(draft.stockQuantity, 4);
    expect(draft.sku, 'REF-001');
  });

  testWidgets('returns the cursor to REF after a business conflict', (
    tester,
  ) async {
    final category = buildCatalogCategory();
    final itemRepository = FakeItemRepository(
      saveFailure: const ItemConflictFailure(),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: ItemFormPage(
          categoryRepository: FakeCategoryRepository(categories: [category]),
          itemRepository: itemRepository,
        ),
      ),
    );
    await tester.pumpAndSettle();
    await _fillRequiredFields(tester);
    await _tapSubmitButton(tester);
    await tester.pumpAndSettle();

    final referenceField = tester.widget<EditableText>(
      find.descendant(
        of: find.byKey(const Key('item_sku_field')),
        matching: find.byType(EditableText),
      ),
    );

    expect(find.byKey(const Key('item_form_error')), findsOneWidget);
    expect(referenceField.focusNode.hasFocus, isTrue);
    expect(referenceField.controller.selection.isCollapsed, isTrue);
    expect(referenceField.controller.selection.baseOffset, 'REF-001'.length);
  });
}

Future<void> _fillRequiredFields(WidgetTester tester) async {
  await tester.tap(find.byKey(const Key('item_category_field')));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Catégorie test').last);
  await tester.pumpAndSettle();
  await tester.enterText(
    find.byKey(const Key('item_title_field')),
    'Article été',
  );
  await tester.enterText(find.byKey(const Key('item_price_field')), '19,99');
  await tester.enterText(find.byKey(const Key('item_stock_field')), '4');
  await tester.enterText(find.byKey(const Key('item_sku_field')), 'ref-001');
}

Future<void> _tapSubmitButton(WidgetTester tester) async {
  final submitButton = find.byKey(const Key('item_submit_button'));
  await tester.ensureVisible(submitButton);
  await tester.pumpAndSettle();
  await tester.tap(submitButton);
}
