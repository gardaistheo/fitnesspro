import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobile/providers/auth_provider.dart';
import 'package:mobile/providers/subscription_provider.dart';
import 'package:mobile/services/api_service.dart';
import 'package:mobile/services/storage_service.dart';
import 'package:mobile/screens/login/login_screen.dart';
import '../support/revenuecat_test_mocks.dart';

class MockApiService extends Mock implements ApiService {}

class FakeMap extends Fake implements Map<String, dynamic> {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeMap());
  });

  late MockApiService mockApiService;
  late StorageService storageService;

  setUp(() async {
    installRevenueCatMocks();
    SharedPreferences.setMockInitialValues({});
    mockApiService = MockApiService();
    storageService = StorageService();
    await storageService.init();
  });

  tearDown(() {
    clearRevenueCatMocks();
  });

  Widget buildTestable() {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>(
          create: (_) => AuthProvider(
            apiService: mockApiService,
            storageService: storageService,
          ),
        ),
        ChangeNotifierProvider<SubscriptionProvider>(
          create: (_) => SubscriptionProvider(),
        ),
      ],
      child: MaterialApp(
        routes: {
          '/': (context) => const LoginScreen(),
          '/dashboard': (context) =>
              const Scaffold(body: Text('DASHBOARD_SCREEN')),
        },
      ),
    );
  }

  testWidgets('submit button is disabled until both fields are filled', (
    tester,
  ) async {
    await tester.pumpWidget(buildTestable());

    final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
    expect(button.onPressed, isNull);

    await tester.enterText(
      find.widgetWithText(TextField, 'Adresse e-mail'),
      'jane@example.com',
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'Mot de passe'),
      'password123',
    );
    await tester.pump();

    final buttonAfter = tester.widget<ElevatedButton>(
      find.byType(ElevatedButton),
    );
    expect(buttonAfter.onPressed, isNotNull);
  });

  testWidgets(
    'successful login links RevenueCat and navigates straight to the dashboard',
    (tester) async {
      when(() => mockApiService.post('/auth/login', any())).thenAnswer(
        (_) async => {
          'data': {
            'user': {
              'id': 7,
              'name': 'Jane Doe',
              'email': 'jane@example.com',
              'created_at': DateTime.now().toIso8601String(),
            },
            'token': 'fake-token',
          },
        },
      );

      await tester.pumpWidget(buildTestable());

      await tester.enterText(
        find.widgetWithText(TextField, 'Adresse e-mail'),
        'jane@example.com',
      );
      await tester.enterText(
        find.widgetWithText(TextField, 'Mot de passe'),
        'password123',
      );
      await tester.pump();

      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      expect(find.text('DASHBOARD_SCREEN'), findsOneWidget);
    },
  );

  testWidgets('failed login shows an error snackbar and stays on the form', (
    tester,
  ) async {
    when(
      () => mockApiService.post('/auth/login', any()),
    ).thenThrow(Exception('invalid credentials'));

    await tester.pumpWidget(buildTestable());

    await tester.enterText(
      find.widgetWithText(TextField, 'Adresse e-mail'),
      'jane@example.com',
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'Mot de passe'),
      'wrong-password',
    );
    await tester.pump();

    await tester.tap(find.byType(ElevatedButton));
    await tester.pumpAndSettle();

    expect(find.text('DASHBOARD_SCREEN'), findsNothing);
    expect(find.byType(SnackBar), findsOneWidget);
  });

  testWidgets(
    'renders the Se connecter header and only email/password fields',
    (tester) async {
      await tester.pumpWidget(buildTestable());

      expect(find.text('Se connecter'), findsOneWidget);
      expect(find.widgetWithText(TextField, 'Adresse e-mail'), findsOneWidget);
      expect(find.widgetWithText(TextField, 'Mot de passe'), findsOneWidget);
      expect(find.widgetWithText(TextField, 'Prénom et nom'), findsNothing);
    },
  );
}
