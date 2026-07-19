import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:mobile/providers/program_provider.dart';
import 'package:mobile/services/api_service.dart';
import 'package:mobile/screens/workouts/workouts_screen.dart';

class MockApiService extends Mock implements ApiService {}

class FakeMap extends Fake implements Map<String, dynamic> {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeMap());
  });

  late MockApiService mockApiService;

  Map<String, dynamic> programJson(
    int id,
    String name, {
    String difficulty = 'Débutant',
    List<Map<String, dynamic>>? exercises,
  }) => {
    'id': id,
    'name': name,
    'muscles': ['Jambes', 'Fessiers'],
    'difficulty': difficulty,
    'duration': 45,
    'description': 'desc',
    'exercises': exercises ?? [],
  };

  Map<String, dynamic> exerciseWithPivot(
    int id,
    String name, {
    int sets = 3,
    int reps = 10,
    int order = 0,
  }) => {
    'id': id,
    'name': name,
    'category': 'Jambes',
    'muscles': ['Jambes'],
    'difficulty': 'Débutant',
    'description': null,
    'instructions': [],
    'youtube_url': null,
    'pivot': {'sets': sets, 'reps': reps, 'order': order},
  };

  setUp(() {
    mockApiService = MockApiService();
  });

  Widget buildTestable() {
    return ChangeNotifierProvider<ProgramProvider>(
      create: (_) => ProgramProvider(apiService: mockApiService),
      child: const MaterialApp(home: WorkoutsScreen()),
    );
  }

  testWidgets('loads and displays programs on init', (tester) async {
    when(() => mockApiService.get('/programs')).thenAnswer(
      (_) async => {
        'data': {
          'data': [programJson(1, 'Leg Day A'), programJson(2, 'Push Day A')],
        },
      },
    );

    await tester.pumpWidget(buildTestable());
    await tester.pumpAndSettle();

    expect(find.text('Leg Day A'), findsOneWidget);
    expect(find.text('Push Day A'), findsOneWidget);
  });

  testWidgets('tapping a difficulty chip reloads with that filter', (
    tester,
  ) async {
    when(() => mockApiService.get('/programs')).thenAnswer(
      (_) async => {
        'data': {
          'data': [
            programJson(1, 'Leg Day A'),
            programJson(2, 'Full Body Avancé', difficulty: 'Avancé'),
          ],
        },
      },
    );
    when(() => mockApiService.get('/programs?difficulty=Avancé')).thenAnswer(
      (_) async => {
        'data': {
          'data': [programJson(2, 'Full Body Avancé', difficulty: 'Avancé')],
        },
      },
    );

    await tester.pumpWidget(buildTestable());
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(ChoiceChip, 'Avancé'));
    await tester.pumpAndSettle();

    verify(() => mockApiService.get('/programs?difficulty=Avancé')).called(1);
    expect(find.text('Full Body Avancé'), findsOneWidget);
    expect(find.text('Leg Day A'), findsNothing);
  });

  testWidgets('shows the first 3 exercise names joined in the footer', (
    tester,
  ) async {
    when(() => mockApiService.get('/programs')).thenAnswer(
      (_) async => {
        'data': {
          'data': [
            programJson(
              1,
              'Leg Day A',
              exercises: [
                exerciseWithPivot(1, 'Squat'),
                exerciseWithPivot(2, 'Fentes'),
                exerciseWithPivot(3, 'Soulevé de terre'),
              ],
            ),
          ],
        },
      },
    );

    await tester.pumpWidget(buildTestable());
    await tester.pumpAndSettle();

    expect(find.text('Squat · Fentes · Soulevé de terre'), findsOneWidget);
  });

  testWidgets(
    'tapping a program navigates to its detail and can add to planning',
    (tester) async {
      when(() => mockApiService.get('/programs')).thenAnswer(
        (_) async => {
          'data': {
            'data': [
              programJson(
                1,
                'Leg Day A',
                exercises: [exerciseWithPivot(1, 'Squat', sets: 2, reps: 8)],
              ),
            ],
          },
        },
      );
      when(
        () => mockApiService.post('/workout-sessions', any()),
      ).thenAnswer((_) async => {'data': {}});

      await tester.pumpWidget(buildTestable());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Leg Day A'));
      await tester.pumpAndSettle();

      expect(find.text('Squat'), findsOneWidget);
      expect(find.text('Série 1'), findsOneWidget);
      expect(find.text('Série 2'), findsOneWidget);

      await tester.tap(find.text('📅 Ajouter à mon planning'));
      await tester.pumpAndSettle();

      verify(() => mockApiService.post('/workout-sessions', any())).called(1);
      expect(find.text('✓ Leg Day A ajouté au planning'), findsOneWidget);
    },
  );
}
