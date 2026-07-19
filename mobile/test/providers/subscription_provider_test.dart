import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/config/revenuecat_config.dart';
import 'package:mobile/providers/subscription_provider.dart';
import '../support/revenuecat_test_mocks.dart';

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
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(() {
    clearRevenueCatMocks();
  });

  test(
    'configure loads customer info and starts with no active entitlement',
    () async {
      installRevenueCatMocks();
      final provider = SubscriptionProvider();

      await provider.configure();

      expect(provider.customerInfo, isNotNull);
      expect(provider.isPro, isFalse);
    },
  );

  test('isPro is true once the configured entitlement is active', () async {
    installRevenueCatMocks(activeEntitlements: _activeProEntitlement);
    final provider = SubscriptionProvider();

    await provider.configure();

    expect(provider.isPro, isTrue);
  });

  test(
    'login links the RevenueCat app user id and updates customer info',
    () async {
      installRevenueCatMocks();
      final provider = SubscriptionProvider();
      await provider.configure();

      await provider.login('42');

      expect(provider.customerInfo, isNotNull);
      expect(provider.isLoading, isFalse);
      expect(provider.error, isNull);
    },
  );

  test(
    'logout resets to an anonymous customer info without throwing',
    () async {
      installRevenueCatMocks();
      final provider = SubscriptionProvider();
      await provider.configure();
      await provider.login('42');

      await provider.logout();

      expect(provider.customerInfo, isNotNull);
      expect(provider.error, isNull);
    },
  );

  test(
    'restorePurchases returns true and isPro becomes true when an entitlement is active',
    () async {
      installRevenueCatMocks(activeEntitlements: _activeProEntitlement);
      final provider = SubscriptionProvider();
      await provider.configure();

      final result = await provider.restorePurchases();

      expect(result, isTrue);
      expect(provider.isPro, isTrue);
    },
  );

  test(
    'restorePurchases returns false when no entitlement is active',
    () async {
      installRevenueCatMocks();
      final provider = SubscriptionProvider();
      await provider.configure();

      final result = await provider.restorePurchases();

      expect(result, isFalse);
      expect(provider.isPro, isFalse);
    },
  );

  test(
    'refreshCustomerInfo picks up entitlement changes since configure',
    () async {
      installRevenueCatMocks();
      final provider = SubscriptionProvider();
      await provider.configure();
      expect(provider.isPro, isFalse);

      installRevenueCatMocks(activeEntitlements: _activeProEntitlement);
      await provider.refreshCustomerInfo();

      expect(provider.isPro, isTrue);
    },
  );
}
