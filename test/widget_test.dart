import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:temphumsense/main.dart';

void main() {
  testWidgets('Dashboard renders correctly', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const TempHumSenseApp());

    // Verify that the dashboard title appears
    expect(find.text('Sensor Dashboard'), findsOneWidget);
  });
}