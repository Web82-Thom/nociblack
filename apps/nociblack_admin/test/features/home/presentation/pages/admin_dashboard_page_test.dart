import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nociblack/features/auth/domain/entities/admin_profile.dart';
import 'package:nociblack/features/home/presentation/pages/admin_dashboard_page.dart';

import '../../../../helpers/fake_category_repository.dart';
import '../../../../helpers/fake_item_repository.dart';

void main() {
  const profile = AdminProfile(
    id: 'admin-id',
    email: 'admin@nociblack.test',
    role: AdminRole.admin,
    isActive: true,
    firstName: 'Admin',
  );

  Future<void> pumpDashboard(WidgetTester tester) {
    return tester.pumpWidget(
      MaterialApp(
        home: AdminDashboardPage(
          profile: profile,
          onSignOut: () async {},
          categoryRepository: FakeCategoryRepository(),
          itemRepository: FakeItemRepository(),
        ),
      ),
    );
  }

  testWidgets('opens the items list from the dashboard', (tester) async {
    await pumpDashboard(tester);

    await tester.tap(find.text('Articles'));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(AppBar, 'Articles'), findsOneWidget);
  });

  testWidgets('opens the items history from the dashboard', (tester) async {
    await pumpDashboard(tester);

    await tester.tap(find.text('Historique'));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(AppBar, 'Historique'), findsOneWidget);
  });

  testWidgets('opens categories management from the dashboard', (tester) async {
    await pumpDashboard(tester);

    await tester.tap(find.text('Catégories'));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(AppBar, 'Catégories'), findsOneWidget);
  });

  testWidgets('opens the item form from the dashboard', (tester) async {
    await pumpDashboard(tester);

    await tester.tap(find.byKey(const Key('create_item_fab')));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(AppBar, 'Nouvel article'), findsOneWidget);
  });
}
