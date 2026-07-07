import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// A minimal, valid CustomerInfo JSON payload with no active entitlements —
/// the shape purchases_flutter's native side would normally return.
Map<String, dynamic> fakeCustomerInfoJson({Map<String, dynamic>? activeEntitlements}) {
  return {
    'entitlements': {
      'all': activeEntitlements ?? {},
      'active': activeEntitlements ?? {},
      'verification': 'NOT_REQUESTED',
    },
    'allPurchaseDates': <String, String?>{},
    'activeSubscriptions': <String>[],
    'allPurchasedProductIdentifiers': <String>[],
    'nonSubscriptionTransactions': <Map<String, dynamic>>[],
    'firstSeen': '2026-01-01T00:00:00Z',
    'originalAppUserId': 'anonymous',
    'allExpirationDates': <String, String?>{},
    'requestDate': '2026-01-01T00:00:00Z',
  };
}

/// Installs mock handlers for the native method channels the RevenueCat
/// Flutter SDKs use ('purchases_flutter' and 'purchases_ui_flutter'), so
/// widget tests can drive through SubscriptionProvider/PaywallScreen without
/// a real device/platform implementation.
///
/// [paywallResult] controls what RevenueCatUI.presentPaywall() resolves to —
/// pass one of 'PURCHASED', 'RESTORED', 'CANCELLED', 'ERROR', 'NOT_PRESENTED',
/// the exact strings purchases_ui_flutter maps to a PaywallResult.
///
/// [activeEntitlements] lets a test simulate a customer who already has an
/// active entitlement (e.g. after purchasing/restoring) — every
/// getCustomerInfo/logIn/logOut/restorePurchases call returns this same set.
void installRevenueCatMocks({
  String paywallResult = 'CANCELLED',
  Map<String, dynamic>? activeEntitlements,
}) {
  const purchasesChannel = MethodChannel('purchases_flutter');
  const purchasesUiChannel = MethodChannel('purchases_ui_flutter');

  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
    purchasesChannel,
    (call) async {
      switch (call.method) {
        case 'setupPurchases':
          return null;
        case 'getCustomerInfo':
          return fakeCustomerInfoJson(activeEntitlements: activeEntitlements);
        case 'logIn':
          return {
            'customerInfo': fakeCustomerInfoJson(activeEntitlements: activeEntitlements),
            'created': false,
          };
        case 'logOut':
          return fakeCustomerInfoJson(activeEntitlements: activeEntitlements);
        case 'restorePurchases':
          return fakeCustomerInfoJson(activeEntitlements: activeEntitlements);
        case 'setLogLevel':
          return null;
        default:
          return null;
      }
    },
  );

  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
    purchasesUiChannel,
    (call) async {
      switch (call.method) {
        case 'presentPaywall':
        case 'presentPaywallIfNeeded':
          return paywallResult;
        default:
          return null;
      }
    },
  );
}

void clearRevenueCatMocks() {
  const purchasesChannel = MethodChannel('purchases_flutter');
  const purchasesUiChannel = MethodChannel('purchases_ui_flutter');

  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
    purchasesChannel,
    null,
  );
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
    purchasesUiChannel,
    null,
  );
}
