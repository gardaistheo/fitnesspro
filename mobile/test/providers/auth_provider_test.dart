import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobile/providers/auth_provider.dart';
import 'package:mobile/services/api_service.dart';
import 'package:mobile/services/storage_service.dart';

class MockApiService extends Mock implements ApiService {}

class FakeMap extends Fake implements Map<String, dynamic> {}

Map<String, dynamic> userJson({int id = 1, String name = 'Jane Doe', String email = 'jane@example.com'}) => {
      'id': id,
      'name': name,
      'email': email,
      'created_at': DateTime.now().toIso8601String(),
    };

void main() {
  setUpAll(() {
    registerFallbackValue(FakeMap());
  });

  late MockApiService mockApiService;
  late StorageService storageService;
  late AuthProvider provider;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    mockApiService = MockApiService();
    storageService = StorageService();
    await storageService.init();
    provider = AuthProvider(apiService: mockApiService, storageService: storageService);
  });

  group('register', () {
    test('stores the token and user, and returns true on success', () async {
      when(() => mockApiService.post('/auth/register', any())).thenAnswer((_) async => {
            'data': {'user': userJson(), 'token': 'reg-token'},
          });

      final result = await provider.register('Jane Doe', 'jane@example.com', 'password123');

      expect(result, isTrue);
      expect(provider.isAuthenticated, isTrue);
      expect(provider.user?.email, 'jane@example.com');
      expect(storageService.getToken(), 'reg-token');
    });

    test('returns false and sets an error on failure', () async {
      when(() => mockApiService.post('/auth/register', any())).thenThrow(Exception('email taken'));

      final result = await provider.register('Jane Doe', 'jane@example.com', 'password123');

      expect(result, isFalse);
      expect(provider.isAuthenticated, isFalse);
      expect(provider.error, isNotNull);
    });
  });

  group('login', () {
    test('stores the token and user, and returns true on success', () async {
      when(() => mockApiService.post('/auth/login', any())).thenAnswer((_) async => {
            'data': {'user': userJson(id: 7), 'token': 'login-token'},
          });

      final result = await provider.login('jane@example.com', 'password123');

      expect(result, isTrue);
      expect(provider.user?.id, 7);
      expect(storageService.getToken(), 'login-token');
    });

    test('returns false and sets an error on invalid credentials', () async {
      when(() => mockApiService.post('/auth/login', any())).thenThrow(Exception('invalid credentials'));

      final result = await provider.login('jane@example.com', 'wrong-password');

      expect(result, isFalse);
      expect(provider.isAuthenticated, isFalse);
      expect(provider.error, isNotNull);
    });
  });

  group('restoreSession', () {
    test('returns false when no token/user was ever persisted', () async {
      final result = await provider.restoreSession();

      expect(result, isFalse);
      expect(provider.isAuthenticated, isFalse);
    });

    test('returns true and restores the user from a previously persisted session', () async {
      await storageService.saveToken('persisted-token');
      await storageService.saveUserData(jsonEncode(userJson(id: 3, name: 'Restored User')));

      final result = await provider.restoreSession();

      expect(result, isTrue);
      expect(provider.isAuthenticated, isTrue);
      expect(provider.user?.id, 3);
      expect(provider.user?.name, 'Restored User');
    });

    test('a fresh AuthProvider instance can restore a session saved by another instance', () async {
      // Mirrors the real app-restart scenario: one AuthProvider (this
      // session) logs in, a new process starts a brand new AuthProvider
      // against the same StorageService and must recover the same user.
      when(() => mockApiService.post('/auth/login', any())).thenAnswer((_) async => {
            'data': {'user': userJson(id: 9), 'token': 'shared-token'},
          });
      await provider.login('jane@example.com', 'password123');

      final freshProvider = AuthProvider(apiService: mockApiService, storageService: storageService);
      final result = await freshProvider.restoreSession();

      expect(result, isTrue);
      expect(freshProvider.user?.id, 9);
    });
  });

  group('logout', () {
    test('clears the user, token, and persisted data', () async {
      when(() => mockApiService.post('/auth/login', any())).thenAnswer((_) async => {
            'data': {'user': userJson(), 'token': 'login-token'},
          });
      when(() => mockApiService.post('/auth/logout', any())).thenAnswer((_) async => {'data': null});
      await provider.login('jane@example.com', 'password123');
      expect(provider.isAuthenticated, isTrue);

      await provider.logout();

      expect(provider.isAuthenticated, isFalse);
      expect(storageService.getToken(), isNull);
      expect(storageService.getUserData(), isNull);
    });

    test('still clears local state even if the logout API call fails', () async {
      when(() => mockApiService.post('/auth/login', any())).thenAnswer((_) async => {
            'data': {'user': userJson(), 'token': 'login-token'},
          });
      when(() => mockApiService.post('/auth/logout', any())).thenThrow(Exception('network error'));
      await provider.login('jane@example.com', 'password123');

      await provider.logout();

      expect(provider.isAuthenticated, isFalse);
      expect(storageService.getToken(), isNull);
    });
  });
}
