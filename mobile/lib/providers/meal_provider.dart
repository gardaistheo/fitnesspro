import 'package:flutter/material.dart';
import '../models/meal_model.dart';
import '../services/api_service.dart';

class MealProvider extends ChangeNotifier {
  final ApiService apiService;

  bool _isLoading = false;
  String? _error;
  Meal? _lastLoggedMeal;

  MealProvider({required this.apiService});

  bool get isLoading => _isLoading;
  String? get error => _error;
  Meal? get lastLoggedMeal => _lastLoggedMeal;

  Future<bool> logMeal({
    required String name,
    required int calories,
    int proteins = 0,
    int carbs = 0,
    int fats = 0,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await apiService.post('/meals', {
        'name': name,
        'calories': calories,
        'proteins': proteins,
        'carbs': carbs,
        'fats': fats,
      });

      _lastLoggedMeal = Meal.fromJson(response['data'] as Map<String, dynamic>);
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

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
