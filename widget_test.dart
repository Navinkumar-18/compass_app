import 'package:flutter_test/flutter_test.dart';
import 'package:compass_app/main.dart'; // Adjusted package name

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that the login screen is displayed.
    expect(find.text('Login'), findsOneWidget);

    // Add more specific tests as you develop the app.
  });
}