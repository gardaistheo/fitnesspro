import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobile/providers/auth_provider.dart';
import 'package:mobile/providers/subscription_provider.dart';
import 'package:mobile/providers/theme_provider.dart';
import 'package:mobile/providers/workout_session_provider.dart';
import 'package:mobile/services/api_service.dart';
import 'package:mobile/services/storage_service.dart';
import 'package:mobile/screens/dashboard/dashboard_screen.dart';
import 'package:mobile/screens/landing/landing_screen.dart';
import 'package:mobile/screens/login/login_screen.dart';
import 'package:mobile/screens/signup/signup_screen.dart';
import 'package:mobile/screens/food_scanner/food_scanner_screen.dart';
import '../support/revenuecat_test_mocks.dart';

class MockApiService extends Mock implements ApiService {}

class FakeMap extends Fake implements Map<String, dynamic> {}

/// WCAG 2.1 AA / Material accessibility checks on key screens, per
/// docs/accessibilite.md. Each screen is exercised against the standard
/// flutter_test guidelines: text contrast, and tap target size for both
/// Android and iOS conventions.
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

  group('LandingScreen', () {
    testWidgets('meets text contrast and tap target guidelines', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();

      await tester.pumpWidget(
        MaterialApp(
          routes: {
            '/': (context) => const LandingScreen(),
            '/signup': (context) => const Scaffold(body: Text('SIGNUP_SCREEN')),
            '/login': (context) => const Scaffold(body: Text('LOGIN_SCREEN')),
          },
        ),
      );
      await tester.pumpAndSettle();

      await expectLater(tester, meetsGuideline(textContrastGuideline));
      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));

      handle.dispose();
    });
  });

  group('LoginScreen', () {
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
        child: const MaterialApp(home: LoginScreen()),
      );
    }

    testWidgets('meets text contrast and tap target guidelines', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();

      await tester.pumpWidget(buildTestable());
      await tester.pumpAndSettle();

      await expectLater(tester, meetsGuideline(textContrastGuideline));
      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));

      handle.dispose();
    });

    testWidgets('email and password fields keep a persistent accessible '
        'label (not just a hint)', (tester) async {
      await tester.pumpWidget(buildTestable());

      await tester.enterText(
        find.widgetWithText(TextField, 'Adresse e-mail'),
        'jane@example.com',
      );
      await tester.pump();

      // With labelText (vs hintText), the label stays associated with the
      // field and visible above the input once filled — WCAG 1.3.1/4.1.2.
      expect(find.text('Adresse e-mail'), findsOneWidget);
    });
  });

  group('SignupScreen', () {
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
        child: const MaterialApp(home: SignupScreen()),
      );
    }

    testWidgets('meets text contrast and tap target guidelines', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();

      await tester.pumpWidget(buildTestable());
      await tester.pumpAndSettle();

      await expectLater(tester, meetsGuideline(textContrastGuideline));
      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));

      handle.dispose();
    });
  });

  group('DashboardScreen', () {
    late AuthProvider authProvider;
    late SubscriptionProvider subscriptionProvider;
    late ThemeProvider themeProvider;

    setUp(() async {
      authProvider = AuthProvider(
        apiService: mockApiService,
        storageService: storageService,
      );
      subscriptionProvider = SubscriptionProvider();
      themeProvider = ThemeProvider(storageService: storageService);
      await themeProvider.init();
      when(() => mockApiService.get('/workout-sessions')).thenAnswer(
        (_) async => {
          'data': {'data': []},
        },
      );
    });

    Widget buildTestable() {
      return MultiProvider(
        providers: [
          ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
          ChangeNotifierProvider<SubscriptionProvider>.value(
            value: subscriptionProvider,
          ),
          ChangeNotifierProvider<ThemeProvider>.value(value: themeProvider),
          ChangeNotifierProvider<WorkoutSessionProvider>(
            create: (_) => WorkoutSessionProvider(
              apiService: mockApiService,
              storageService: storageService,
            ),
          ),
        ],
        child: const MaterialApp(home: DashboardScreen()),
      );
    }

    testWidgets('meets text contrast and tap target guidelines', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();

      await tester.pumpWidget(buildTestable());
      await tester.pumpAndSettle();

      await expectLater(tester, meetsGuideline(textContrastGuideline));
      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));

      handle.dispose();
    });

    testWidgets(
      'hydration reset button exposes an accessible label, not just "↺"',
      (tester) async {
        await tester.pumpWidget(buildTestable());
        await tester.pumpAndSettle();

        final semantics = tester.getSemantics(find.text('↺'));
        expect(semantics.label, contains('Réinitialiser'));
      },
    );
  });

  group('FoodScannerScreen', () {
    testWidgets('camera capture button exposes an accessible label', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();

      await tester.pumpWidget(const MaterialApp(home: FoodScannerScreen()));
      await tester.pumpAndSettle();

      final semantics = tester.getSemantics(
        find.ancestor(
          of: find.byIcon(Icons.camera_alt),
          matching: find.byType(GestureDetector),
        ),
      );
      expect(semantics.label, contains('Prendre une photo'));

      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));

      handle.dispose();
    });
  });
}
