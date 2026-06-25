import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nociblack/app/app.dart';
import 'package:nociblack/features/auth/domain/errors/auth_failure.dart';

import 'helpers/fake_auth_repository.dart';
import 'helpers/fake_category_repository.dart';
import 'helpers/fake_item_repository.dart';
import 'helpers/fake_item_image_repository.dart';
import 'helpers/fake_item_image_creation_service.dart';
import 'helpers/fake_item_image_display_service.dart';
import 'helpers/fake_item_image_update_service.dart';

void main() {
  testWidgets('displays the administrator login page without a session', (
    WidgetTester tester,
  ) async {
    final repository = FakeAuthRepository();
    addTearDown(repository.dispose);

    await tester.pumpWidget(
      NociBlackAdminApp(
        authRepository: repository,
        categoryRepository: FakeCategoryRepository(),
        itemRepository: FakeItemRepository(),
        itemImageRepository: FakeItemImageRepository(),
        itemImageCreationService: FakeItemImageCreationService(),
        itemImageUpdateService: FakeItemImageUpdateService(),
        itemImageDisplayService: FakeItemImageDisplayService(),
      ),
    );
    await tester.pumpAndSettle();

    final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));

    expect(materialApp.title, 'NociBlacK Admin');
    expect(find.byType(Scaffold), findsOneWidget);
    expect(find.text('Administration'), findsOneWidget);
    expect(find.byKey(const Key('login_email_field')), findsOneWidget);
    expect(find.byKey(const Key('login_password_field')), findsOneWidget);
    expect(find.text('Se connecter'), findsOneWidget);
  });

  testWidgets('opens Home after login and returns after logout', (
    WidgetTester tester,
  ) async {
    final repository = FakeAuthRepository();
    addTearDown(repository.dispose);

    await tester.pumpWidget(
      NociBlackAdminApp(
        authRepository: repository,
        categoryRepository: FakeCategoryRepository(),
        itemRepository: FakeItemRepository(),
        itemImageRepository: FakeItemImageRepository(),
        itemImageCreationService: FakeItemImageCreationService(),
        itemImageUpdateService: FakeItemImageUpdateService(),
        itemImageDisplayService: FakeItemImageDisplayService(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const Key('login_email_field')),
      'admin@nociblack.test',
    );
    await tester.enterText(
      find.byKey(const Key('login_password_field')),
      'valid-password',
    );
    await tester.tap(find.byKey(const Key('login_submit_button')));
    await tester.pumpAndSettle();

    expect(find.text('Bienvenue Admin'), findsOneWidget);
    expect(find.byTooltip('Se déconnecter'), findsOneWidget);

    await tester.tap(find.byTooltip('Se déconnecter'));
    await tester.pumpAndSettle();

    expect(find.text('Administration'), findsOneWidget);
  });

  testWidgets('keeps the password editable after invalid credentials', (
    WidgetTester tester,
  ) async {
    final repository = FakeAuthRepository(
      signInFailure: const InvalidCredentialsFailure(),
    );
    addTearDown(repository.dispose);

    await tester.pumpWidget(
      NociBlackAdminApp(
        authRepository: repository,
        categoryRepository: FakeCategoryRepository(),
        itemRepository: FakeItemRepository(),
        itemImageRepository: FakeItemImageRepository(),
        itemImageCreationService: FakeItemImageCreationService(),
        itemImageUpdateService: FakeItemImageUpdateService(),
        itemImageDisplayService: FakeItemImageDisplayService(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const Key('login_email_field')),
      'admin@nociblack.test',
    );
    await tester.enterText(
      find.byKey(const Key('login_password_field')),
      'wrong-password',
    );
    await tester.tap(find.byKey(const Key('login_submit_button')));
    await tester.pumpAndSettle();

    final passwordField = tester.widget<EditableText>(
      find.descendant(
        of: find.byKey(const Key('login_password_field')),
        matching: find.byType(EditableText),
      ),
    );

    expect(find.byKey(const Key('login_error_message')), findsOneWidget);
    expect(passwordField.focusNode.hasFocus, isTrue);
    expect(passwordField.controller.selection.isCollapsed, isTrue);
    expect(
      passwordField.controller.selection.baseOffset,
      'wrong-password'.length,
    );
  });
}
