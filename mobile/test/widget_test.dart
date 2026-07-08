import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobile/core/config/revenuecat_config.dart';
import 'package:mobile/main.dart';
import 'package:mobile/providers/auth_provider.dart';
import 'package:mobile/providers/subscription_provider.dart';
import 'package:mobile/providers/theme_provider.dart';
import 'package:mobile/services/api_service.dart';
import 'package:mobile/services/storage_service.dart';
import 'support/revenuecat_test_mocks.dart';

final _activeProEntitlement = {
  RevenueCatConfig.entitlementId: {
    'identifier': RevenueCatConfig.entitlementId,
    'isActive': true,
    'willRenew': true,
    'latestPurchaseDate': '2026-01-01T00:00:00Z',
    'originalPurchaseDate': '2026-01-01T00:00:00Z',
    'productIdentifier': 'monthly',
    'isSandbox': true,
  },
};

void main() {
  tearDown(() {
    clearRevenueCatMocks();
  });

  testWidgets('App boots on the Landing screen and can navigate to Dashboard', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final storageService = StorageService();
    await storageService.init();
    final apiService = ApiService();

    await tester.pumpWidget(FitnessProApp(
      apiService: apiService,
      storageService: storageService,
      themeProvider: ThemeProvider(storageService: storageService),
      subscriptionProvider: SubscriptionProvider(),
      authProvider: AuthProvider(apiService: apiService, storageService: storageService),
    ));
    await tester.pumpAndSettle();

    expect(find.text('Commencer mon essai gratuit →'), findsOneWidget);
  });

  testWidgets('a restored session boots straight to the dashboard, skipping Landing', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final storageService = StorageService();
    await storageService.init();
    final apiService = ApiService();

    await tester.pumpWidget(FitnessProApp(
      apiService: apiService,
      storageService: storageService,
      themeProvider: ThemeProvider(storageService: storageService),
      subscriptionProvider: SubscriptionProvider(),
      authProvider: AuthProvider(apiService: apiService, storageService: storageService),
      initialRoute: '/dashboard',
    ));
    await tester.pumpAndSettle();

    expect(find.text('Mon tableau de bord'), findsOneWidget);
    expect(find.text('Commencer mon essai gratuit →'), findsNothing);
  });

  testWidgets('a restored session without an active entitlement boots to the paywall recheck', (tester) async {
    installRevenueCatMocks(paywallResult: 'CANCELLED');
    SharedPreferences.setMockInitialValues({});
    final storageService = StorageService();
    await storageService.init();
    final apiService = ApiService();
    final subscriptionProvider = SubscriptionProvider();
    await subscriptionProvider.configure();

    await tester.pumpWidget(FitnessProApp(
      apiService: apiService,
      storageService: storageService,
      themeProvider: ThemeProvider(storageService: storageService),
      subscriptionProvider: subscriptionProvider,
      authProvider: AuthProvider(apiService: apiService, storageService: storageService),
      initialRoute: '/paywall-recheck',
    ));
    // Single pump, before the mocked paywall's async result resolves: the
    // paywall's own loading spinner must be showing, not the dashboard.
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Mon tableau de bord'), findsNothing);
  });

  testWidgets('skipping the paywall recheck still lands on the dashboard, not the quiz', (tester) async {
    installRevenueCatMocks(paywallResult: 'CANCELLED');
    SharedPreferences.setMockInitialValues({});
    final storageService = StorageService();
    await storageService.init();
    final apiService = ApiService();
    final subscriptionProvider = SubscriptionProvider();
    await subscriptionProvider.configure();

    await tester.pumpWidget(FitnessProApp(
      apiService: apiService,
      storageService: storageService,
      themeProvider: ThemeProvider(storageService: storageService),
      subscriptionProvider: subscriptionProvider,
      authProvider: AuthProvider(apiService: apiService, storageService: storageService),
      initialRoute: '/paywall-recheck',
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Mon tableau de bord'), findsOneWidget);
    expect(find.text('Quel est ton niveau ?'), findsNothing);
  });

  test('resolveInitialRoute: hasSession + isPro decide the initial route', () {
    expect(resolveInitialRoute(hasSession: false, isPro: false), '/');
    expect(resolveInitialRoute(hasSession: false, isPro: true), '/'); // no session takes priority
    expect(resolveInitialRoute(hasSession: true, isPro: true), '/dashboard');
    expect(resolveInitialRoute(hasSession: true, isPro: false), '/paywall-recheck');
  });

  testWidgets('an active entitlement at startup goes straight to the dashboard, no paywall detour', (tester) async {
    installRevenueCatMocks(activeEntitlements: _activeProEntitlement);
    SharedPreferences.setMockInitialValues({});
    final storageService = StorageService();
    await storageService.init();
    final apiService = ApiService();
    final subscriptionProvider = SubscriptionProvider();
    await subscriptionProvider.configure();

    expect(subscriptionProvider.isPro, isTrue);

    await tester.pumpWidget(FitnessProApp(
      apiService: apiService,
      storageService: storageService,
      themeProvider: ThemeProvider(storageService: storageService),
      subscriptionProvider: subscriptionProvider,
      authProvider: AuthProvider(apiService: apiService, storageService: storageService),
      initialRoute: '/dashboard',
    ));
    await tester.pumpAndSettle();

    expect(find.text('Mon tableau de bord'), findsOneWidget);
  });
}
