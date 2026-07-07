import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile/providers/workout_session_provider.dart';
import 'package:mobile/services/api_service.dart';

class MockApiService extends Mock implements ApiService {}

void main() {
  late MockApiService mockApiService;
  late WorkoutSessionProvider provider;

  setUp(() {
    mockApiService = MockApiService();
    provider = WorkoutSessionProvider(apiService: mockApiService);
  });

  Map<String, dynamic> sessionJson(
    int id, {
    required String scheduledDate,
    String? scheduledTime,
    String status = 'planned',
    Map<String, dynamic>? program,
  }) =>
      {
        'id': id,
        'program_id': program?['id'],
        'scheduled_date': scheduledDate,
        'scheduled_time': scheduledTime,
        'completed_at': null,
        'status': status,
        'program': program,
      };

  test('loads sessions sorted by scheduled_date ascending', () async {
    when(() => mockApiService.get('/workout-sessions')).thenAnswer((_) async => {
          'data': {
            'data': [
              sessionJson(1, scheduledDate: '2026-07-15'),
              sessionJson(2, scheduledDate: '2026-07-08'),
            ],
          },
        });

    await provider.loadSessions();

    expect(provider.sessions.first.id, 2);
    expect(provider.sessions.last.id, 1);
  });

  test('groups sessions by calendar day', () async {
    when(() => mockApiService.get('/workout-sessions')).thenAnswer((_) async => {
          'data': {
            'data': [
              sessionJson(1, scheduledDate: '2026-07-08'),
              sessionJson(2, scheduledDate: '2026-07-08'),
              sessionJson(3, scheduledDate: '2026-07-09'),
            ],
          },
        });

    await provider.loadSessions();

    expect(provider.sessionsByDate.keys, hasLength(2));
    expect(provider.sessionsByDate[DateTime(2026, 7, 8)], hasLength(2));
    expect(provider.sessionsByDate[DateTime(2026, 7, 9)], hasLength(1));
  });

  test('deleteSession removes it from the in-memory list on success', () async {
    when(() => mockApiService.get('/workout-sessions')).thenAnswer((_) async => {
          'data': {
            'data': [sessionJson(1, scheduledDate: '2026-07-08'), sessionJson(2, scheduledDate: '2026-07-09')],
          },
        });
    when(() => mockApiService.delete('/workout-sessions/1')).thenAnswer((_) async => {'data': null});

    await provider.loadSessions();
    final result = await provider.deleteSession(1);

    expect(result, isTrue);
    expect(provider.sessions, hasLength(1));
    expect(provider.sessions.first.id, 2);
  });

  test('deleteSession keeps the session and sets an error on API failure', () async {
    when(() => mockApiService.get('/workout-sessions')).thenAnswer((_) async => {
          'data': {
            'data': [sessionJson(1, scheduledDate: '2026-07-08')],
          },
        });
    when(() => mockApiService.delete('/workout-sessions/1')).thenThrow(Exception('boom'));

    await provider.loadSessions();
    final result = await provider.deleteSession(1);

    expect(result, isFalse);
    expect(provider.sessions, hasLength(1));
    expect(provider.error, isNotNull);
  });

  group('dateLabel', () {
    test('labels today correctly', () {
      final today = DateTime.now();
      expect(provider.dateLabel(DateTime(today.year, today.month, today.day)), "Aujourd'hui");
    });

    test('labels tomorrow correctly', () {
      final tomorrow = DateTime.now().add(const Duration(days: 1));
      expect(provider.dateLabel(DateTime(tomorrow.year, tomorrow.month, tomorrow.day)), 'Demain');
    });

    test('labels a date several days out with "Dans Nj"', () {
      final future = DateTime.now().add(const Duration(days: 5));
      expect(provider.dateLabel(DateTime(future.year, future.month, future.day)), 'Dans 5j');
    });

    test('labels a past date as "Passé"', () {
      final past = DateTime.now().subtract(const Duration(days: 3));
      expect(provider.dateLabel(DateTime(past.year, past.month, past.day)), 'Passé');
    });
  });
}
