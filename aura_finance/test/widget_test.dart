import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:aura_finance/main.dart';

void main() {
  testWidgets('App structural test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ProviderScope(child: AuraFinanceApp()));

    // Verify that the Dashboard screen is present
    expect(find.byIcon(Icons.dashboard_outlined), findsOneWidget);
  });
}
