import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:mobile/providers/program_provider.dart';
import 'package:mobile/providers/workout_session_provider.dart';
import 'package:mobile/services/api_service.dart';
import 'package:mobile/screens/planning/planning_screen.dart';

class MockApiService extends Mock implements ApiService {}

class FakeMap extends Fake implements Map<String, dynamic> {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeMap());
  });

  late MockApiService mockApiService;

  Map<String, dynamic> sessionJson(
    int id, {
    required String scheduledDate,
    String? scheduledTime,
    Map<String, dynamic>? program,
  }) =>
      {
        'id': id,
        'program_id': program?['id'],
        'scheduled_date': scheduledDate,
        'scheduled_time': scheduledTime,
        'completed_at': null,
        'status': 'planned',
        'program': program,
      };

  setUp(() {
    mockApiService = MockApiService();
  });

  Widget buildTestable() {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<WorkoutSessionProvider>(
          create: (_) => WorkoutSessionProvider(apiService: mockApiService),
        ),
        ChangeNotifierProvider<ProgramProvider>(
          create: (_) => ProgramProvider(apiService: mockApiService),
        ),
      ],
      child: const MaterialApp(home: PlanningScreen()),
    );
  }

  testWidgets('loads and groups sessions by date with the correct chip label', (tester) async {
    final today = DateTime.now();
    final todayStr =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

    when(() => mockApiService.get('/workout-sessions')).thenAnswer((_) async => {
          'data': {
            'data': [
              sessionJson(
                1,
                scheduledDate: todayStr,
                scheduledTime: '10:00',
                program: {'id': 1, 'name': 'Push Day A', 'muscles': ['Poitrine'], 'duration': 45},
              ),
            ],
          },
        });

    await tester.pumpWidget(buildTestable());
    await tester.pumpAndSettle();

    expect(find.text('Push Day A'), findsOneWidget);
    expect(find.text("Aujourd'hui"), findsOneWidget);
  });

  testWidgets('tapping delete removes the session from the list', (tester) async {
    when(() => mockApiService.get('/workout-sessions')).thenAnswer((_) async => {
          'data': {
            'data': [
              sessionJson(
                1,
                scheduledDate: '2026-07-08',
                program: {'id': 1, 'name': 'Push Day A', 'muscles': ['Poitrine'], 'duration': 45},
              ),
            ],
          },
        });
    when(() => mockApiService.delete('/workout-sessions/1')).thenAnswer((_) async => {'data': null});

    await tester.pumpWidget(buildTestable());
    await tester.pumpAndSettle();

    expect(find.text('Push Day A'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.delete_outline));
    await tester.pumpAndSettle();

    verify(() => mockApiService.delete('/workout-sessions/1')).called(1);
    expect(find.text('Push Day A'), findsNothing);
  });

  testWidgets('tapping + Ajouter opens the program picker modal', (tester) async {
    when(() => mockApiService.get('/workout-sessions')).thenAnswer((_) async => {
          'data': {'data': []},
        });
    when(() => mockApiService.get('/programs')).thenAnswer((_) async => {
          'data': {
            'data': [
              {'id': 1, 'name': 'Leg Day A', 'muscles': ['Jambes'], 'difficulty': 'Débutant', 'duration': 30, 'description': null, 'exercises': []},
            ],
          },
        });

    await tester.pumpWidget(buildTestable());
    await tester.pumpAndSettle();

    await tester.tap(find.text('+ Ajouter'));
    await tester.pumpAndSettle();

    expect(find.text('Leg Day A'), findsOneWidget);
  });
}
