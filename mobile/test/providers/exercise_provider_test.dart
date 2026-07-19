import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile/providers/exercise_provider.dart';
import 'package:mobile/services/api_service.dart';

class MockApiService extends Mock implements ApiService {}

void main() {
  late MockApiService mockApiService;
  late ExerciseProvider provider;

  setUp(() {
    mockApiService = MockApiService();
    provider = ExerciseProvider(apiService: mockApiService);
  });

  Map<String, dynamic> exerciseJson(
    int id,
    String name, {
    String category = 'Jambes',
  }) => {
    'id': id,
    'name': name,
    'category': category,
    'muscles': ['Quadriceps'],
    'difficulty': 'Débutant',
    'description': 'desc',
    'instructions': ['step 1'],
    'youtube_url': null,
  };

  test('loads exercises from the API without any filter', () async {
    when(() => mockApiService.get('/exercises')).thenAnswer(
      (_) async => {
        'data': {
          'data': [exerciseJson(1, 'Squat'), exerciseJson(2, 'Fentes')],
        },
      },
    );

    await provider.loadExercises();

    expect(provider.exercises, hasLength(2));
    expect(provider.isLoading, isFalse);
  });

  test('requests the category filter when not "Tous"', () async {
    when(() => mockApiService.get('/exercises?category=Poitrine')).thenAnswer(
      (_) async => {
        'data': {
          'data': [exerciseJson(1, 'Développé couché', category: 'Poitrine')],
        },
      },
    );

    await provider.loadExercises(category: 'Poitrine');

    verify(() => mockApiService.get('/exercises?category=Poitrine')).called(1);
    expect(provider.exercises, hasLength(1));
  });

  test('does not add a category filter for "Tous"', () async {
    when(() => mockApiService.get('/exercises')).thenAnswer(
      (_) async => {
        'data': {'data': []},
      },
    );

    await provider.loadExercises(category: 'Tous');

    verify(() => mockApiService.get('/exercises')).called(1);
  });

  test('filters loaded exercises locally by search query', () async {
    when(() => mockApiService.get('/exercises')).thenAnswer(
      (_) async => {
        'data': {
          'data': [exerciseJson(1, 'Squat'), exerciseJson(2, 'Fentes')],
        },
      },
    );

    await provider.loadExercises();
    provider.setSearchQuery('squ');

    expect(provider.exercises, hasLength(1));
    expect(provider.exercises.first.name, 'Squat');
  });

  test('sets an error and stops loading when the API call fails', () async {
    when(
      () => mockApiService.get('/exercises'),
    ).thenThrow(Exception('network error'));

    await provider.loadExercises();

    expect(provider.error, isNotNull);
    expect(provider.isLoading, isFalse);
  });
}
