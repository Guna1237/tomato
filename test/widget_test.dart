// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:tomato/app.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const TomatoApp());

    // Basic smoke test: verify the app starts (e.g. check for a specific text or widget)
    // Since it's a complex app with a splash screen, we just check it doesn't crash.
    expect(find.byType(TomatoApp), findsOneWidget);
  });
}
