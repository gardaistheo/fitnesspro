import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:mobile/providers/exercise_provider.dart';
import 'package:mobile/services/api_service.dart';
import 'package:mobile/screens/exercises/exercises_screen.dart';

class MockApiService extends Mock implements ApiService {}

void main() {
  late MockApiService mockApiService;

  Map<String, dynamic> exerciseJson(int id, String name, {String category = 'Jambes'}) => {
        'id': id,
        'name': name,
        'category': category,
        'muscles': ['Quadriceps'],
        'difficulty': 'Débutant',
        'description': 'Une description.',
        'instructions': ['Étape 1', 'Étape 2'],
        'youtube_url': null,
      };

  setUp(() {
    mockApiService = MockApiService();
  });

  Widget buildTestable() {
    return ChangeNotifierProvider<ExerciseProvider>(
      create: (_) => ExerciseProvider(apiService: mockApiService),
      child: const MaterialApp(home: ExercisesScreen()),
    );
  }

  testWidgets('loads and displays exercises on init', (tester) async {
    when(() => mockApiService.get('/exercises')).thenAnswer((_) async => {
          'data': {
            'data': [exerciseJson(1, 'Squat'), exerciseJson(2, 'Fentes')],
          },
        });

    await tester.pumpWidget(buildTestable());
    await tester.pumpAndSettle();

    expect(find.text('Squat'), findsOneWidget);
    expect(find.text('Fentes'), findsOneWidget);
  });

  testWidgets('tapping a category chip reloads with that filter', (tester) async {
    when(() => mockApiService.get('/exercises')).thenAnswer((_) async => {
          'data': {
            'data': [exerciseJson(1, 'Squat'), exerciseJson(2, 'Développé couché', category: 'Poitrine')],
          },
        });
    when(() => mockApiService.get('/exercises?category=Poitrine')).thenAnswer((_) async => {
          'data': {
            'data': [exerciseJson(2, 'Développé couché', category: 'Poitrine')],
          },
        });

    await tester.pumpWidget(buildTestable());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Poitrine'));
    await tester.pumpAndSettle();

    verify(() => mockApiService.get('/exercises?category=Poitrine')).called(1);
    expect(find.text('Développé couché'), findsOneWidget);
    expect(find.text('Squat'), findsNothing);
  });

  testWidgets('tapping an exercise navigates to its detail screen', (tester) async {
    when(() => mockApiService.get('/exercises')).thenAnswer((_) async => {
          'data': {
            'data': [exerciseJson(1, 'Squat')],
          },
        });

    await tester.pumpWidget(buildTestable());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Squat'));
    await tester.pumpAndSettle();

    expect(find.text('MUSCLES TRAVAILLÉS'), findsOneWidget);
    expect(find.text('Une description.'), findsOneWidget);
    expect(find.text('Étape 1'), findsOneWidget);
  });
}
