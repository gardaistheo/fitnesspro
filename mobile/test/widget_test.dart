import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobile/main.dart';
import 'package:mobile/providers/auth_provider.dart';
import 'package:mobile/providers/subscription_provider.dart';
import 'package:mobile/providers/theme_provider.dart';
import 'package:mobile/services/api_service.dart';
import 'package:mobile/services/storage_service.dart';

void main() {
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
}
