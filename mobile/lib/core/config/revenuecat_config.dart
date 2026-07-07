/// RevenueCat configuration.
///
/// The API key defaults to the sandbox/test key for local development.
/// Override for staging/production builds via:
///   flutter build apk --dart-define=REVENUECAT_API_KEY=`real_key`
/// Never commit a production key as the literal default here.
class RevenueCatConfig {
  static const String apiKey = String.fromEnvironment(
    'REVENUECAT_API_KEY',
    defaultValue: 'test_EYKjaEEAedawACCckXIaPQwpYAd',
  );

  /// Entitlement identifier configured in the RevenueCat dashboard that
  /// gates access to FitnessPro's paid features.
  static const String entitlementId = 'FitnessPro Pro';

  /// Offering package identifiers configured in the RevenueCat dashboard.
  static const String monthlyPackageId = 'monthly';
  static const String yearlyPackageId = 'yearly';
}
