import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/screens/landing/landing_screen.dart';

void main() {
  Widget buildTestable() {
    return MaterialApp(
      routes: {
        '/': (context) => const LandingScreen(),
        '/signup': (context) => const Scaffold(body: Text('SIGNUP_SCREEN')),
        '/login': (context) => const Scaffold(body: Text('LOGIN_SCREEN')),
      },
    );
  }

  testWidgets('CTA navigates to signup', (tester) async {
    await tester.pumpWidget(buildTestable());

    final ctaFinder = find.text('Commencer mon essai gratuit →');
    await tester.scrollUntilVisible(ctaFinder, 200);
    await tester.tap(ctaFinder);
    await tester.pumpAndSettle();

    expect(find.text('SIGNUP_SCREEN'), findsOneWidget);
  });

  testWidgets('"Se connecter" link navigates to login', (tester) async {
    await tester.pumpWidget(buildTestable());

    final loginLinkFinder = find.textContaining(
      'Se connecter',
      findRichText: true,
    );
    await tester.scrollUntilVisible(loginLinkFinder, 200);
    await tester.tap(find.byType(TextButton));
    await tester.pumpAndSettle();

    expect(find.text('LOGIN_SCREEN'), findsOneWidget);
  });
}
