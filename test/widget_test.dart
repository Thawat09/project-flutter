import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:project_flutter/screens/login_page.dart';

void main() {
  testWidgets('Login Page has Email, Password fields, and Login button',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: LoginPage()));

    expect(find.byType(TextField), findsNWidgets(2));
    expect(find.text('Login'), findsOneWidget);

    await tester.enterText(
        find.byType(TextField).first, 'test@example.com'); // Email
    await tester.enterText(find.byType(TextField).last, 'P@ssw0rd'); // Password
    await tester.tap(find.text('Login'));
    await tester.pump();
  });
}
