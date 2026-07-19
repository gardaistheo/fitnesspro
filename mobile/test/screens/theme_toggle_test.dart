import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/providers/theme_provider.dart';
import 'package:mobile/providers/workout_session_provider.dart';
import 'package:mobile/screens/dashboard/dashboard_screen.dart';
import 'package:mobile/services/api_service.dart';
import 'package:mobile/services/storage_service.dart';

class MockApiService extends Mock implements ApiService {}

void main() {
  late StorageService storageService;
  late MockApiService mockApiService;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    storageService = StorageService();
    await storageService.init();
    mockApiService = MockApiService();
    when(() => mockApiService.get('/workout-sessions')).thenAnswer(
      (_) async => {
        'data': {'data': []},
      },
    );
  });

  Widget buildTestable(ThemeProvider themeProvider) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ThemeProvider>.value(value: themeProvider),
        ChangeNotifierProvider<WorkoutSessionProvider>(
          create: (_) => WorkoutSessionProvider(
            apiService: mockApiService,
            storageService: storageService,
          ),
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, theme, _) {
          return MaterialApp(
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: theme.themeMode,
            home: const DashboardScreen(),
          );
        },
      ),
    );
  }

  testWidgets(
    'tapping the theme toggle cycles system -> light -> dark -> system and persists it',
    (tester) async {
      final themeProvider = ThemeProvider(storageService: storageService);
      await themeProvider.init();

      await tester.pumpWidget(buildTestable(themeProvider));
      await tester.pumpAndSettle();

      expect(themeProvider.themeMode, ThemeMode.system);
      expect(find.byIcon(Icons.brightness_auto), findsOneWidget);

      await tester.tap(find.byTooltip('Changer de thème'));
      await tester.pumpAndSettle();
      expect(themeProvider.themeMode, ThemeMode.light);
      expect(find.byIcon(Icons.light_mode), findsOneWidget);
      expect(storageService.getThemeMode(), 'light');

      await tester.tap(find.byTooltip('Changer de thème'));
      await tester.pumpAndSettle();
      expect(themeProvider.themeMode, ThemeMode.dark);
      expect(find.byIcon(Icons.dark_mode), findsOneWidget);
      expect(storageService.getThemeMode(), 'dark');

      await tester.tap(find.byTooltip('Changer de thème'));
      await tester.pumpAndSettle();
      expect(themeProvider.themeMode, ThemeMode.system);
      expect(find.byIcon(Icons.brightness_auto), findsOneWidget);
    },
  );

  testWidgets(
    'the Scaffold background actually changes when toggling to dark',
    (tester) async {
      final themeProvider = ThemeProvider(storageService: storageService);
      await themeProvider.init();
      await themeProvider.setThemeMode(ThemeMode.light);

      await tester.pumpWidget(buildTestable(themeProvider));
      await tester.pumpAndSettle();
      final lightColor = tester
          .widget<Scaffold>(find.byType(Scaffold))
          .backgroundColor;

      await themeProvider.setThemeMode(ThemeMode.dark);
      await tester.pumpAndSettle();
      final darkColor = tester
          .widget<Scaffold>(find.byType(Scaffold))
          .backgroundColor;

      expect(darkColor, isNot(equals(lightColor)));
    },
  );
}
