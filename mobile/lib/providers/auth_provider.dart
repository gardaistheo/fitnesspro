import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

class AuthProvider extends ChangeNotifier {
  final ApiService apiService;
  final StorageService storageService;

  User? _user;
  bool _isLoading = false;
  String? _error;

  AuthProvider({required this.apiService, required this.storageService});

  // Getters
  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null;

  // Register
  Future<bool> register(String firstName, String lastName, String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await apiService.post('/auth/register', {
        'name': '$firstName $lastName',
        'email': email,
        'password': password,
        'password_confirmation': password,
      });

      final token = response['data']['token'] as String;
      final userData = response['data']['user'] as Map<String, dynamic>;

      _user = User.fromJson(userData);
      apiService.setToken(token);
      await storageService.saveToken(token);
      await storageService.saveUserData(jsonEncode(userData));

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Login
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await apiService.post('/auth/login', {
        'email': email,
        'password': password,
      });

      final token = response['data']['token'] as String;
      final userData = response['data']['user'] as Map<String, dynamic>;

      _user = User.fromJson(userData);
      apiService.setToken(token);
      await storageService.saveToken(token);
      await storageService.saveUserData(jsonEncode(userData));

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Get current user
  Future<bool> getCurrentUser() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await apiService.get('/auth/me');
      final userData = response['data'] as Map<String, dynamic>;

      _user = User.fromJson(userData);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      await apiService.post('/auth/logout', {});
    } catch (e) {
      // Logout even if API call fails
      print('Logout API error: $e');
    }

    _user = null;
    apiService.clearToken();
    await storageService.clearToken();
    await storageService.clearUserData();
    _error = null;
    notifyListeners();
  }

  // Restore session from storage
  Future<bool> restoreSession() async {
    try {
      final token = storageService.getToken();
      final userData = storageService.getUserData();

      if (token == null || userData == null) {
        return false;
      }

      apiService.setToken(token);
      _user = User.fromJson(jsonDecode(userData) as Map<String, dynamic>);
      notifyListeners();
      return true;
    } catch (e) {
      print('Session restore error: $e');
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
