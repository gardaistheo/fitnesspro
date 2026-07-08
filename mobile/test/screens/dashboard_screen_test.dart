import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobile/providers/auth_provider.dart';
import 'package:mobile/providers/subscription_provider.dart';
import 'package:mobile/providers/theme_provider.dart';
import 'package:mobile/services/api_service.dart';
import 'package:mobile/services/storage_service.dart';
import 'package:mobile/screens/dashboard/dashboard_screen.dart';
import '../support/revenuecat_test_mocks.dart';

class MockApiService extends Mock implements ApiService {}

class FakeMap extends Fake implements Map<String, dynamic> {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeMap());
  });

  late MockApiService mockApiService;
  late StorageService storageService;
  late AuthProvider authProvider;
  late SubscriptionProvider subscriptionProvider;
  late ThemeProvider themeProvider;

  setUp(() async {
    installRevenueCatMocks();
    SharedPreferences.setMockInitialValues({});
    mockApiService = MockApiService();
    storageService = StorageService();
    await storageService.init();
    authProvider = AuthProvider(apiService: mockApiService, storageService: storageService);
    subscriptionProvider = SubscriptionProvider();
    themeProvider = ThemeProvider(storageService: storageService);
    await themeProvider.init();
  });

  tearDown(() {
    clearRevenueCatMocks();
  });

  Widget buildTestable() {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
        ChangeNotifierProvider<SubscriptionProvider>.value(value: subscriptionProvider),
        ChangeNotifierProvider<ThemeProvider>.value(value: themeProvider),
      ],
      child: MaterialApp(
        routes: {
          '/': (context) => const Scaffold(body: Text('LANDING_SCREEN')),
          '/dashboard': (context) => const DashboardScreen(),
        },
        initialRoute: '/dashboard',
      ),
    );
  }

  testWidgets('account menu offers Gérer mon abonnement and Se déconnecter', (tester) async {
    await tester.pumpWidget(buildTestable());
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Mon compte'));
    await tester.pumpAndSettle();

    expect(find.text('Gérer mon abonnement'), findsOneWidget);
    expect(find.text('Se déconnecter'), findsOneWidget);
  });

  testWidgets('Se déconnecter logs out and navigates back to Landing, clearing the session', (tester) async {
    when(() => mockApiService.post('/auth/login', any())).thenAnswer((_) async => {
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
    when(() => mockApiService.post('/auth/logout', any())).thenAnswer((_) async => {'data': null});
    await authProvider.login('jane@example.com', 'password123');
    expect(authProvider.isAuthenticated, isTrue);

    await tester.pumpWidget(buildTestable());
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Mon compte'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Se déconnecter'));
    await tester.pumpAndSettle();

    expect(find.text('LANDING_SCREEN'), findsOneWidget);
    expect(authProvider.isAuthenticated, isFalse);
    expect(storageService.getToken(), isNull);
  });

  testWidgets('logging out still navigates to Landing even if the logout API call fails', (tester) async {
    when(() => mockApiService.post('/auth/login', any())).thenAnswer((_) async => {
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
    when(() => mockApiService.post('/auth/logout', any())).thenThrow(Exception('network error'));
    await authProvider.login('jane@example.com', 'password123');

    await tester.pumpWidget(buildTestable());
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Mon compte'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Se déconnecter'));
    await tester.pumpAndSettle();

    expect(find.text('LANDING_SCREEN'), findsOneWidget);
    expect(authProvider.isAuthenticated, isFalse);
  });
}
