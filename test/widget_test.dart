import 'package:flutter_test/flutter_test.dart';
import 'package:byteflow/app/app.dart';

void main() {
  testWidgets('ByteFlowApp smoke test renders Dashboard and NavigationBar',
      (WidgetTester tester) async {
    await tester.pumpWidget(const ByteFlowApp());
    await tester.pumpAndSettle();

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
