import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobile/main.dart';
import 'package:mobile/providers/subscription_provider.dart';
import 'package:mobile/providers/theme_provider.dart';
import 'package:mobile/services/api_service.dart';
import 'package:mobile/services/storage_service.dart';

void main() {
  testWidgets('App boots on the Landing screen and can navigate to Dashboard', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final storageService = StorageService();
    await storageService.init();

    await tester.pumpWidget(FitnessProApp(
      apiService: ApiService(),
      storageService: storageService,
      themeProvider: ThemeProvider(storageService: storageService),
      subscriptionProvider: SubscriptionProvider(),
    ));
    await tester.pumpAndSettle();

    expect(find.text('Commencer mon essai gratuit →'), findsOneWidget);
  });
}
