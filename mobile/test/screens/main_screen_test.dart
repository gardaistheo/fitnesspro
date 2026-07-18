import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:mobile/providers/auth_provider.dart';
import 'package:mobile/providers/exercise_provider.dart';
import 'package:mobile/providers/meal_provider.dart';
import 'package:mobile/providers/program_provider.dart';
import 'package:mobile/providers/theme_provider.dart';
import 'package:mobile/providers/workout_session_provider.dart';
import 'package:mobile/services/api_service.dart';
import 'package:mobile/services/storage_service.dart';
import 'package:mobile/screens/main/main_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockApiService extends Mock implements ApiService {}

void main() {
  late MockApiService mockApiService;
  late StorageService storageService;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    mockApiService = MockApiService();
    storageService = StorageService();
    await storageService.init();

    when(() => mockApiService.get('/exercises')).thenAnswer((_) async => {
          'data': {'data': []},
        });
    when(() => mockApiService.get('/programs')).thenAnswer((_) async => {
          'data': {'data': []},
        });
    when(() => mockApiService.get('/workout-sessions')).thenAnswer((_) async => {
          'data': {'data': []},
        });
  });

  Widget buildTestable() {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>(
          create: (_) => AuthProvider(apiService: mockApiService, storageService: storageService),
        ),
        ChangeNotifierProvider<MealProvider>(create: (_) => MealProvider(apiService: mockApiService)),
        ChangeNotifierProvider<ExerciseProvider>(create: (_) => ExerciseProvider(apiService: mockApiService)),
        ChangeNotifierProvider<ProgramProvider>(create: (_) => ProgramProvider(apiService: mockApiService)),
        ChangeNotifierProvider<ThemeProvider>(create: (_) => ThemeProvider(storageService: storageService)),
        ChangeNotifierProvider<WorkoutSessionProvider>(
          create: (_) => WorkoutSessionProvider(apiService: mockApiService, storageService: storageService),
        ),
      ],
      child: const MaterialApp(home: MainScreen()),
    );
  }

  testWidgets('starts on the Dashboard tab', (tester) async {
    await tester.pumpWidget(buildTestable());
    await tester.pumpAndSettle();

    expect(find.text('Mon tableau de bord'), findsOneWidget);
  });

  testWidgets('switching tabs shows the correct screen for each', (tester) async {
    await tester.pumpWidget(buildTestable());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Coach IA'));
    await tester.pumpAndSettle();
    expect(find.text('Bientôt disponible'), findsOneWidget);

    await tester.tap(find.text('Scanner'));
    await tester.pumpAndSettle();
    expect(find.text('Powered by Passio AI'), findsOneWidget);

    await tester.tap(find.text('Exercices'));
    await tester.pumpAndSettle();
    expect(find.byType(TextField), findsOneWidget); // exercise search bar

    await tester.tap(find.text('Séances'));
    await tester.pumpAndSettle();
    expect(find.text('Tous'), findsOneWidget); // difficulty filter chip

    await tester.tap(find.text('Dashboard'));
    await tester.pumpAndSettle();
    expect(find.text('Mon tableau de bord'), findsOneWidget);
  });

  testWidgets('preserves Dashboard hydration state when switching away and back', (tester) async {
    await tester.pumpWidget(buildTestable());
    await tester.pumpAndSettle();

    await tester.tap(find.text('+250 ml'));
    await tester.pump();
    expect(find.text('1500 ml / 2000 ml'), findsOneWidget);

    await tester.tap(find.text('Scanner'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Dashboard'));
    await tester.pumpAndSettle();

    expect(find.text('1500 ml / 2000 ml'), findsOneWidget);
  });
}
