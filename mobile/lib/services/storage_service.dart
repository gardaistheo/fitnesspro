import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';
  static const String _themeKey = 'theme_mode';

  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Token management
  Future<void> saveToken(String token) async {
    await _prefs.setString(_tokenKey, token);
  }

  String? getToken() {
    return _prefs.getString(_tokenKey);
  }

  Future<void> clearToken() async {
    await _prefs.remove(_tokenKey);
  }

  // User data
  Future<void> saveUserData(String userData) async {
    await _prefs.setString(_userKey, userData);
  }

  String? getUserData() {
    return _prefs.getString(_userKey);
  }

  Future<void> clearUserData() async {
    await _prefs.remove(_userKey);
  }

  // Theme mode
  Future<void> saveThemeMode(String themeMode) async {
    await _prefs.setString(_themeKey, themeMode);
  }

  String? getThemeMode() {
    return _prefs.getString(_themeKey) ?? 'system';
  }

  // Clear all
  Future<void> clearAll() async {
    await _prefs.clear();
  }
}
