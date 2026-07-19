import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobile/providers/theme_provider.dart';
import 'package:mobile/services/storage_service.dart';

void main() {
  late StorageService storageService;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    storageService = StorageService();
    await storageService.init();
  });

  test('defaults to ThemeMode.system when nothing is persisted', () async {
    final provider = ThemeProvider(storageService: storageService);
    await provider.init();

    expect(provider.themeMode, ThemeMode.system);
  });

  test('restores a previously persisted theme mode on init', () async {
    await storageService.saveThemeMode('dark');

    final provider = ThemeProvider(storageService: storageService);
    await provider.init();

    expect(provider.themeMode, ThemeMode.dark);
  });

  test('setThemeMode updates state and persists the new value', () async {
    final provider = ThemeProvider(storageService: storageService);
    await provider.init();

    await provider.setThemeMode(ThemeMode.light);

    expect(provider.themeMode, ThemeMode.light);
    expect(storageService.getThemeMode(), 'light');
  });

  test('setThemeMode notifies listeners', () async {
    final provider = ThemeProvider(storageService: storageService);
    await provider.init();

    var notified = false;
    provider.addListener(() => notified = true);

    await provider.setThemeMode(ThemeMode.dark);

    expect(notified, isTrue);
  });

  test(
    'a second ThemeProvider instance picks up the persisted mode from a prior session',
    () async {
      final first = ThemeProvider(storageService: storageService);
      await first.init();
      await first.setThemeMode(ThemeMode.dark);

      final second = ThemeProvider(storageService: storageService);
      await second.init();

      expect(second.themeMode, ThemeMode.dark);
    },
  );
}
