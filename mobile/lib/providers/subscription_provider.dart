import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import '../core/config/revenuecat_config.dart';

/// Wraps the RevenueCat SDK for FitnessPro's subscription gating.
///
/// Lifecycle: call [configure] once at app startup (before any user is
/// logged in), then [login]/[logout] as the app's own auth state changes so
/// RevenueCat's app user ID stays in sync with our backend's user ID — the
/// backend's RevenueCat webhook (SubscriptionService::handleRevenueCatEvent)
/// looks up the user by `app_user_id`, so these two identities must match.
class SubscriptionProvider extends ChangeNotifier {
  CustomerInfo? _customerInfo;
  Offerings? _offerings;
  bool _isLoading = false;
  String? _error;

  CustomerInfo? get customerInfo => _customerInfo;
  Offerings? get offerings => _offerings;
  bool get isLoading => _isLoading;
  String? get error => _error;

  bool get isPro {
    final entitlement = _customerInfo?.entitlements.active[RevenueCatConfig.entitlementId];
    return entitlement != null;
  }

  /// Configures the RevenueCat SDK. Call once at app startup, before login.
  Future<void> configure() async {
    await Purchases.setLogLevel(LogLevel.warn);
    await Purchases.configure(PurchasesConfiguration(RevenueCatConfig.apiKey));

    try {
      _customerInfo = await Purchases.getCustomerInfo();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
    }
  }

  /// Links the RevenueCat app user ID to our backend's user ID so that the
  /// RevenueCat webhook can resolve purchases back to the correct account.
  Future<void> login(String appUserId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await Purchases.logIn(appUserId);
      _customerInfo = result.customerInfo;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Resets RevenueCat back to an anonymous user, e.g. on app logout.
  Future<void> logout() async {
    try {
      _customerInfo = await Purchases.logOut();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> loadOfferings() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _offerings = await Purchases.getOfferings();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> purchasePackage(Package package) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await Purchases.purchase(PurchaseParams.package(package));
      _customerInfo = result.customerInfo;
      _isLoading = false;
      notifyListeners();
      return true;
    } on PlatformException catch (e) {
      _isLoading = false;
      final errorCode = PurchasesErrorHelper.getErrorCode(e);
      if (errorCode != PurchasesErrorCode.purchaseCancelledError) {
        _error = e.message ?? e.toString();
      }
      notifyListeners();
      return false;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> restorePurchases() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _customerInfo = await Purchases.restorePurchases();
      _isLoading = false;
      notifyListeners();
      return isPro;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> refreshCustomerInfo() async {
    try {
      _customerInfo = await Purchases.getCustomerInfo();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
