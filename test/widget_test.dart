import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:byteflow/app/app.dart';

void main() {
  testWidgets('ByteFlowApp smoke test renders Dashboard and NavigationBar',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const ByteFlowApp());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Verify AppBar title
    expect(find.text('ByteFlow Dashboard'), findsOneWidget);

    // Verify NavigationBar destinations
    expect(find.text('Dashboard'), findsWidgets);
    expect(find.text('History'), findsOneWidget);
    expect(find.text('Apps'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);

    // Verify Dashboard Cards
    expect(find.text('REAL-TIME SPEED'), findsOneWidget);
    expect(find.text("TODAY'S USAGE"), findsOneWidget);
    expect(find.text('Download'), findsWidgets);
    expect(find.text('Upload'), findsWidgets);
  });
}
