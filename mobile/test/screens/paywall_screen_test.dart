import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:mobile/providers/subscription_provider.dart';
import 'package:mobile/screens/paywall/paywall_screen.dart';
import '../support/revenuecat_test_mocks.dart';

void main() {
  tearDown(() {
    clearRevenueCatMocks();
  });

  Widget buildTestable({
    required VoidCallback onSubscribed,
    required VoidCallback onSkip,
  }) {
    return ChangeNotifierProvider<SubscriptionProvider>(
      create: (_) => SubscriptionProvider(),
      child: MaterialApp(
        home: PaywallScreen(onSubscribed: onSubscribed, onSkip: onSkip),
      ),
    );
  }

  testWidgets('shows a loading indicator while the paywall is presenting', (
    tester,
  ) async {
    installRevenueCatMocks(paywallResult: 'CANCELLED');

    await tester.pumpWidget(buildTestable(onSubscribed: () {}, onSkip: () {}));
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('calls onSubscribed when the paywall result is PURCHASED', (
    tester,
  ) async {
    installRevenueCatMocks(paywallResult: 'PURCHASED');
    var subscribed = false;

    await tester.pumpWidget(
      buildTestable(onSubscribed: () => subscribed = true, onSkip: () {}),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(subscribed, isTrue);
  });

  testWidgets('calls onSubscribed when the paywall result is RESTORED', (
    tester,
  ) async {
    installRevenueCatMocks(paywallResult: 'RESTORED');
    var subscribed = false;

    await tester.pumpWidget(
      buildTestable(onSubscribed: () => subscribed = true, onSkip: () {}),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(subscribed, isTrue);
  });

  testWidgets('calls onSkip when the paywall result is CANCELLED', (
    tester,
  ) async {
    installRevenueCatMocks(paywallResult: 'CANCELLED');
    var skipped = false;

    await tester.pumpWidget(
      buildTestable(onSubscribed: () {}, onSkip: () => skipped = true),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(skipped, isTrue);
  });

  testWidgets(
    'shows a retry UI and does not navigate when the paywall result is ERROR',
    (tester) async {
      installRevenueCatMocks(paywallResult: 'ERROR');
      var subscribed = false;
      var skipped = false;

      await tester.pumpWidget(
        buildTestable(
          onSubscribed: () => subscribed = true,
          onSkip: () => skipped = true,
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(subscribed, isFalse);
      expect(skipped, isFalse);
      expect(find.text('Réessayer'), findsOneWidget);
      expect(find.text('Continuer sans abonnement'), findsOneWidget);
    },
  );

  testWidgets('"Continuer sans abonnement" calls onSkip after an error', (
    tester,
  ) async {
    installRevenueCatMocks(paywallResult: 'ERROR');
    var skipped = false;

    await tester.pumpWidget(
      buildTestable(onSubscribed: () {}, onSkip: () => skipped = true),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    await tester.tap(find.text('Continuer sans abonnement'));
    await tester.pump();

    expect(skipped, isTrue);
  });
}
