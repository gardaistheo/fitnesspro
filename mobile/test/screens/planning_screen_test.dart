import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobile/providers/program_provider.dart';
import 'package:mobile/providers/workout_session_provider.dart';
import 'package:mobile/services/api_service.dart';
import 'package:mobile/services/storage_service.dart';
import 'package:mobile/screens/planning/planning_screen.dart';

class MockApiService extends Mock implements ApiService {}

class FakeMap extends Fake implements Map<String, dynamic> {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeMap());
  });

  late MockApiService mockApiService;
  late StorageService storageService;

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

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    mockApiService = MockApiService();
    storageService = StorageService();
    await storageService.init();
  });

  Widget buildTestable() {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<WorkoutSessionProvider>(
          create: (_) => WorkoutSessionProvider(apiService: mockApiService, storageService: storageService),
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

  testWidgets('selecting a program opens the date picker before scheduling', (tester) async {
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
    when(() => mockApiService.post(any(), any())).thenAnswer((_) async => {'data': null});

    await tester.pumpWidget(buildTestable());
    await tester.pumpAndSettle();

    await tester.tap(find.text('+ Ajouter'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Leg Day A'));
    await tester.pumpAndSettle();

    // The Material date picker dialog should now be showing.
    expect(find.byType(DatePickerDialog), findsOneWidget);
  });

  testWidgets('confirming date and time schedules the session with the picked date', (tester) async {
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
    when(() => mockApiService.post(any(), any())).thenAnswer((_) async => {'data': null});

    await tester.pumpWidget(buildTestable());
    await tester.pumpAndSettle();

    await tester.tap(find.text('+ Ajouter'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Leg Day A'));
    await tester.pumpAndSettle();

    // Confirm the date picker with its default (initialDate = today).
    expect(find.byType(DatePickerDialog), findsOneWidget);
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    // The time picker opens next; dismiss it without picking a time.
    expect(find.byType(TimePickerDialog), findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    final now = DateTime.now();
    final expectedDate = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    final captured = verify(() => mockApiService.post('/workout-sessions', captureAny())).captured;
    expect(captured, hasLength(1));
    final body = captured.first as Map<String, dynamic>;
    expect(body['program_id'], 1);
    expect(body['scheduled_date'], expectedDate);
    expect(body.containsKey('scheduled_time'), isFalse);
  });

  testWidgets('the date picker does not allow selecting a date before today', (tester) async {
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

    await tester.tap(find.text('Leg Day A'));
    await tester.pumpAndSettle();

    final datePickerDialog = tester.widget<DatePickerDialog>(find.byType(DatePickerDialog));
    final today = DateTime.now();
    expect(datePickerDialog.firstDate, DateTime(today.year, today.month, today.day));
  });

  testWidgets('a backend rejection (e.g. past date) shows an error instead of failing silently', (tester) async {
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
    when(() => mockApiService.post(any(), any()))
        .thenThrow(Exception('The scheduled date must be today or a future date.'));

    await tester.pumpWidget(buildTestable());
    await tester.pumpAndSettle();

    await tester.tap(find.text('+ Ajouter'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Leg Day A'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(find.text('The scheduled date must be today or a future date.'), findsOneWidget);
  });
}
