import 'package:flutter/material.dart';
import '../services/storage_service.dart';

class ThemeProvider extends ChangeNotifier {
  final StorageService storageService;

  ThemeMode _themeMode = ThemeMode.system;

  ThemeProvider({required this.storageService});

  ThemeMode get themeMode => _themeMode;

  Future<void> init() async {
    final savedTheme = storageService.getThemeMode();
    _themeMode = _parseThemeMode(savedTheme);
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    await storageService.saveThemeMode(_themeModeToString(mode));
    notifyListeners();
  }

  ThemeMode _parseThemeMode(String? value) {
    switch (value) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  String _themeModeToString(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
        return 'system';
    }
  }
}
