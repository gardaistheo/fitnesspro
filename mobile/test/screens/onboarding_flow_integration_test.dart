import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/providers/auth_provider.dart';
import 'package:mobile/providers/subscription_provider.dart';
import 'package:mobile/providers/theme_provider.dart';
import 'package:mobile/services/api_service.dart';
import 'package:mobile/services/storage_service.dart';
import 'package:mobile/main.dart';
import '../support/revenuecat_test_mocks.dart';

class MockApiService extends Mock implements ApiService {}

class FakeMap extends Fake implements Map<String, dynamic> {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeMap());
  });

  setUp(() {
    installRevenueCatMocks(paywallResult: 'CANCELLED');
  });

  tearDown(() {
    clearRevenueCatMocks();
  });

  testWidgets('full flow: Landing -> Signup -> Quiz -> Onboarding -> Dashboard', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final storageService = StorageService();
    await storageService.init();
    final mockApiService = MockApiService();

    when(() => mockApiService.post('/auth/register', any())).thenAnswer((_) async => {
          'data': {
            'user': {
              'id': 1,
              'name': 'Jane Doe',
              'email': 'jane@example.com',
              'created_at': DateTime.now().toIso8601String(),
            },
            'token': 'fake-token',
          },
        });
    when(() => mockApiService.get('/exercises')).thenAnswer((_) async => {'data': {'data': []}});
    when(() => mockApiService.get('/programs')).thenAnswer((_) async => {'data': {'data': []}});

    final themeProvider = ThemeProvider(storageService: storageService);
    await themeProvider.init();
    final subscriptionProvider = SubscriptionProvider();
    await subscriptionProvider.configure();

    await tester.pumpWidget(FitnessProApp(
      apiService: mockApiService,
      storageService: storageService,
      themeProvider: themeProvider,
      subscriptionProvider: subscriptionProvider,
      authProvider: AuthProvider(apiService: mockApiService, storageService: storageService),
    ));
    await tester.pumpAndSettle();

    // Landing -> Signup
    final ctaFinder = find.text('Commencer mon essai gratuit →');
    await tester.scrollUntilVisible(ctaFinder, 200);
    await tester.tap(ctaFinder);
    await tester.pumpAndSettle();
    expect(find.text('Créer un compte'), findsOneWidget);

    // Fill the signup form -> paywall (mocked as CANCELLED) -> Quiz
    await tester.enterText(find.widgetWithText(TextField, 'Prénom et nom'), 'Jane Doe');
    await tester.enterText(find.widgetWithText(TextField, 'Adresse e-mail'), 'jane@example.com');
    await tester.enterText(find.widgetWithText(TextField, 'Mot de passe'), 'password123');
    await tester.pump();
    await tester.tap(find.text('Continuer →'));
    await tester.pumpAndSettle();
    expect(find.text('Quel est ton niveau ?'), findsOneWidget);

    // Race through the quiz (Salle path, 6 steps) -> Onboarding
    await tester.tap(find.text('Débutant'));
    await tester.pump();
    await tester.tap(find.widgetWithText(ElevatedButton, 'Continuer →'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Maintenir'));
    await tester.pump();
    await tester.tap(find.widgetWithText(ElevatedButton, 'Continuer →'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Lun'));
    await tester.pump();
    await tester.tap(find.widgetWithText(ElevatedButton, 'Continuer →'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Salle'));
    await tester.pump();
    await tester.tap(find.widgetWithText(ElevatedButton, 'Continuer →'));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(ElevatedButton, 'Continuer →'));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(ElevatedButton, 'Créer mon programme →'));
    await tester.pumpAndSettle();

    expect(find.text('Ton programme est prêt !'), findsOneWidget);
    expect(find.textContaining('Basé sur ton profil Débutant'), findsOneWidget);

    // Skip onboarding slides -> Dashboard
    await tester.tap(find.text('Passer'));
    await tester.pumpAndSettle();

    expect(find.text('Mon tableau de bord'), findsOneWidget);
  });

  testWidgets('AppTheme is applied consistently across the full flow', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final storageService = StorageService();
    await storageService.init();
    final apiService = ApiService();
    final themeProvider = ThemeProvider(storageService: storageService);
    await themeProvider.init();
    await themeProvider.setThemeMode(ThemeMode.dark);
    final subscriptionProvider = SubscriptionProvider();
    await subscriptionProvider.configure();

    await tester.pumpWidget(FitnessProApp(
      apiService: apiService,
      storageService: storageService,
      themeProvider: themeProvider,
      subscriptionProvider: subscriptionProvider,
      authProvider: AuthProvider(apiService: apiService, storageService: storageService),
    ));
    await tester.pumpAndSettle();

    final ctaFinder = find.text('Commencer mon essai gratuit →');
    await tester.scrollUntilVisible(ctaFinder, 200);
    await tester.tap(ctaFinder);
    await tester.pumpAndSettle();

    final scaffold = tester.widget<Scaffold>(find.byType(Scaffold).first);
    expect(scaffold.backgroundColor, AppTheme.dark.scaffoldBackgroundColor);
  });
}
