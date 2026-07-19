import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobile/providers/workout_session_provider.dart';
import 'package:mobile/services/api_service.dart';
import 'package:mobile/services/storage_service.dart';

class MockApiService extends Mock implements ApiService {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockApiService mockApiService;
  late StorageService storageService;
  late WorkoutSessionProvider provider;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    mockApiService = MockApiService();
    storageService = StorageService();
    await storageService.init();
    provider = WorkoutSessionProvider(
      apiService: mockApiService,
      storageService: storageService,
    );
  });

  Map<String, dynamic> sessionJson(
    int id, {
    required String scheduledDate,
    String? scheduledTime,
    String status = 'planned',
    Map<String, dynamic>? program,
  }) => {
    'id': id,
    'program_id': program?['id'],
    'scheduled_date': scheduledDate,
    'scheduled_time': scheduledTime,
    'completed_at': null,
    'status': status,
    'program': program,
  };

  test(
    'normalizes a HH:mm:ss scheduled_time from the backend to HH:mm',
    () async {
      when(() => mockApiService.get('/workout-sessions')).thenAnswer(
        (_) async => {
          'data': {
            'data': [
              sessionJson(
                1,
                scheduledDate: '2026-07-15',
                scheduledTime: '16:31:00',
              ),
            ],
          },
        },
      );

      await provider.loadSessions();

      expect(provider.sessions.single.scheduledTime, '16:31');
    },
  );

  test('loads sessions sorted by scheduled_date ascending', () async {
    when(() => mockApiService.get('/workout-sessions')).thenAnswer(
      (_) async => {
        'data': {
          'data': [
            sessionJson(1, scheduledDate: '2026-07-15'),
            sessionJson(2, scheduledDate: '2026-07-08'),
          ],
        },
      },
    );

    await provider.loadSessions();

    expect(provider.sessions.first.id, 2);
    expect(provider.sessions.last.id, 1);
  });

  test('groups sessions by calendar day', () async {
    when(() => mockApiService.get('/workout-sessions')).thenAnswer(
      (_) async => {
        'data': {
          'data': [
            sessionJson(1, scheduledDate: '2026-07-08'),
            sessionJson(2, scheduledDate: '2026-07-08'),
            sessionJson(3, scheduledDate: '2026-07-09'),
          ],
        },
      },
    );

    await provider.loadSessions();

    expect(provider.sessionsByDate.keys, hasLength(2));
    expect(provider.sessionsByDate[DateTime(2026, 7, 8)], hasLength(2));
    expect(provider.sessionsByDate[DateTime(2026, 7, 9)], hasLength(1));
  });

  test('deleteSession removes it from the in-memory list on success', () async {
    when(() => mockApiService.get('/workout-sessions')).thenAnswer(
      (_) async => {
        'data': {
          'data': [
            sessionJson(1, scheduledDate: '2026-07-08'),
            sessionJson(2, scheduledDate: '2026-07-09'),
          ],
        },
      },
    );
    when(
      () => mockApiService.delete('/workout-sessions/1'),
    ).thenAnswer((_) async => {'data': null});

    await provider.loadSessions();
    final result = await provider.deleteSession(1);

    expect(result, isTrue);
    expect(provider.sessions, hasLength(1));
    expect(provider.sessions.first.id, 2);
  });

  test(
    'deleteSession keeps the session and sets an error on API failure',
    () async {
      when(() => mockApiService.get('/workout-sessions')).thenAnswer(
        (_) async => {
          'data': {
            'data': [sessionJson(1, scheduledDate: '2026-07-08')],
          },
        },
      );
      when(
        () => mockApiService.delete('/workout-sessions/1'),
      ).thenThrow(Exception('boom'));

      await provider.loadSessions();
      final result = await provider.deleteSession(1);

      expect(result, isFalse);
      expect(provider.sessions, hasLength(1));
      expect(provider.error, isNotNull);
    },
  );

  group('nextSession', () {
    String isoDate(DateTime date) =>
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

    test('returns the soonest planned session today or later', () async {
      final today = DateTime.now();
      final tomorrow = today.add(const Duration(days: 1));
      final nextWeek = today.add(const Duration(days: 7));

      when(() => mockApiService.get('/workout-sessions')).thenAnswer(
        (_) async => {
          'data': {
            'data': [
              sessionJson(
                1,
                scheduledDate: isoDate(nextWeek),
                program: {'id': 1, 'name': 'Later'},
              ),
              sessionJson(
                2,
                scheduledDate: isoDate(tomorrow),
                program: {'id': 2, 'name': 'Soonest'},
              ),
            ],
          },
        },
      );

      await provider.loadSessions();

      expect(provider.nextSession?.program?.name, 'Soonest');
    });

    test('ignores past sessions and non-planned statuses', () async {
      final today = DateTime.now();
      final yesterday = today.subtract(const Duration(days: 1));
      final tomorrow = today.add(const Duration(days: 1));

      when(() => mockApiService.get('/workout-sessions')).thenAnswer(
        (_) async => {
          'data': {
            'data': [
              sessionJson(
                1,
                scheduledDate: isoDate(yesterday),
                status: 'planned',
              ),
              sessionJson(
                2,
                scheduledDate: isoDate(today),
                status: 'completed',
              ),
              sessionJson(
                3,
                scheduledDate: isoDate(tomorrow),
                status: 'planned',
                program: {'id': 3, 'name': 'Upcoming'},
              ),
            ],
          },
        },
      );

      await provider.loadSessions();

      expect(provider.nextSession?.program?.name, 'Upcoming');
    });

    test('is null when there is no upcoming planned session', () async {
      when(() => mockApiService.get('/workout-sessions')).thenAnswer(
        (_) async => {
          'data': {'data': []},
        },
      );

      await provider.loadSessions();

      expect(provider.nextSession, isNull);
    });
  });

  group('dateLabel', () {
    test('labels today correctly', () {
      final today = DateTime.now();
      expect(
        provider.dateLabel(DateTime(today.year, today.month, today.day)),
        "Aujourd'hui",
      );
    });

    test('labels tomorrow correctly', () {
      final tomorrow = DateTime.now().add(const Duration(days: 1));
      expect(
        provider.dateLabel(
          DateTime(tomorrow.year, tomorrow.month, tomorrow.day),
        ),
        'Demain',
      );
    });

    test('labels a date several days out with "Dans Nj"', () {
      final future = DateTime.now().add(const Duration(days: 5));
      expect(
        provider.dateLabel(DateTime(future.year, future.month, future.day)),
        'Dans 5j',
      );
    });

    test('labels a past date as "Passé"', () {
      final past = DateTime.now().subtract(const Duration(days: 3));
      expect(
        provider.dateLabel(DateTime(past.year, past.month, past.day)),
        'Passé',
      );
    });
  });
}
