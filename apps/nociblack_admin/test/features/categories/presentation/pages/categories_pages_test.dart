import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nociblack/features/categories/domain/errors/category_failure.dart';
import 'package:nociblack/features/categories/presentation/pages/categories_list_page.dart';
import 'package:nociblack/features/categories/presentation/pages/category_form_page.dart';

import '../../../../helpers/fake_category_repository.dart';

void main() {
  testWidgets('creates a category and refreshes the list', (tester) async {
    final repository = FakeCategoryRepository();

    await tester.pumpWidget(
      MaterialApp(home: CategoriesListPage(repository: repository)),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('create_category_fab')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('category_name_field')),
      'Vêtements & Été',
    );

    final slugField = tester.widget<TextFormField>(
      find.byKey(const Key('category_slug_field')),
    );
    expect(slugField.controller!.text, 'vetements-ete');

    await tester.tap(find.byKey(const Key('category_submit_button')));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(AppBar, 'Catégories'), findsOneWidget);
    expect(find.text('Vêtements & Été'), findsOneWidget);
    expect(find.text('vetements-ete'), findsOneWidget);
  });

  testWidgets('shows a business conflict without leaving the form', (
    tester,
  ) async {
    final repository = FakeCategoryRepository(
      failure: const CategoryConflictFailure(),
    );

    await tester.pumpWidget(
      MaterialApp(home: CategoryFormPage(repository: repository)),
    );
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('category_name_field')),
      'Parfums',
    );
    await tester.tap(find.byKey(const Key('category_submit_button')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('category_form_error')), findsOneWidget);
    expect(
      find.text('Une catégorie possède déjà ce nom ou ce slug.'),
      findsOneWidget,
    );
  });

  testWidgets('validates a non-negative display order', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: CategoryFormPage(repository: FakeCategoryRepository()),
      ),
    );
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('category_name_field')),
      'Parfums',
    );
    await tester.enterText(
      find.byKey(const Key('category_order_field')),
      '-1',
    );
    await tester.tap(find.byKey(const Key('category_submit_button')));
    await tester.pump();

    expect(
      find.text('Saisissez un entier positif ou nul.'),
      findsOneWidget,
    );
  });
}
