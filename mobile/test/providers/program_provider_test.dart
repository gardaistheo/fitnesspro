import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile/providers/program_provider.dart';
import 'package:mobile/services/api_service.dart';

class MockApiService extends Mock implements ApiService {}

class FakeMap extends Fake implements Map<String, dynamic> {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeMap());
  });

  late MockApiService mockApiService;
  late ProgramProvider provider;

  setUp(() {
    mockApiService = MockApiService();
    provider = ProgramProvider(apiService: mockApiService);
  });

  Map<String, dynamic> programJson(int id, String name, {String difficulty = 'Débutant'}) => {
        'id': id,
        'name': name,
        'muscles': ['Jambes'],
        'difficulty': difficulty,
        'duration': 45,
        'description': 'desc',
        'exercises': [],
      };

  test('loads programs without a filter', () async {
    when(() => mockApiService.get('/programs')).thenAnswer((_) async => {
          'data': {
            'data': [programJson(1, 'Leg Day A'), programJson(2, 'Push Day A')],
          },
        });

    await provider.loadPrograms();

    expect(provider.programs, hasLength(2));
    expect(provider.isLoading, isFalse);
  });

  test('requests the difficulty filter when not "Tous"', () async {
    when(() => mockApiService.get('/programs?difficulty=Avancé')).thenAnswer((_) async => {
          'data': {
            'data': [programJson(1, 'Leg Day A', difficulty: 'Avancé')],
          },
        });

    await provider.loadPrograms(difficulty: 'Avancé');

    verify(() => mockApiService.get('/programs?difficulty=Avancé')).called(1);
    expect(provider.programs, hasLength(1));
  });

  test('does not add a difficulty filter for "Tous"', () async {
    when(() => mockApiService.get('/programs')).thenAnswer((_) async => {
          'data': {'data': []},
        });

    await provider.loadPrograms(difficulty: 'Tous');

    verify(() => mockApiService.get('/programs')).called(1);
  });

  test('addToPlanning posts program_id and scheduled_date and returns true on success', () async {
    when(() => mockApiService.post('/workout-sessions', any())).thenAnswer((_) async => {'data': {}});

    final result = await provider.addToPlanning(programId: 3, scheduledDate: '2026-07-10');

    expect(result, isTrue);
    final captured = verify(() => mockApiService.post('/workout-sessions', captureAny())).captured;
    expect(captured.single['program_id'], 3);
    expect(captured.single['scheduled_date'], '2026-07-10');
  });

  test('addToPlanning returns false and sets error on API failure', () async {
    when(() => mockApiService.post('/workout-sessions', any())).thenThrow(Exception('boom'));

    final result = await provider.addToPlanning(programId: 3, scheduledDate: '2026-07-10');

    expect(result, isFalse);
    expect(provider.error, isNotNull);
  });

  test('addToPlanning strips the "Exception: " prefix so the message is user-presentable', () async {
    when(() => mockApiService.post('/workout-sessions', any()))
        .thenThrow(Exception('The scheduled date must be today or a future date.'));

    final result = await provider.addToPlanning(programId: 3, scheduledDate: '2026-07-01');

    expect(result, isFalse);
    expect(provider.error, 'The scheduled date must be today or a future date.');
  });
}
