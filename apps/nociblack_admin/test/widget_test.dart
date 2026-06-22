import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nociblack/main.dart';

void main() {
  testWidgets('displays the NociBlacK Admin landing page', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const NociBlackAdminApp());

    final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
    final appBarTitle = find.descendant(
      of: find.byType(AppBar),
      matching: find.text('NociBlacK Admin'),
    );
    final bodyTitle = find.descendant(
      of: find.byType(Center),
      matching: find.text('NociBlacK Admin'),
    );

    expect(materialApp.title, 'NociBlacK Admin');
    expect(find.byType(Scaffold), findsOneWidget);
    expect(appBarTitle, findsOneWidget);
    expect(bodyTitle, findsOneWidget);
  });
}
