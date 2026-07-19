import 'package:flutter/material.dart';
import '../models/exercise_model.dart';
import '../services/api_service.dart';

class ExerciseProvider extends ChangeNotifier {
  final ApiService apiService;

  List<Exercise> _exercises = [];
  bool _isLoading = false;
  String? _error;
  String? _selectedCategory;
  String _searchQuery = '';

  ExerciseProvider({required this.apiService});

  List<Exercise> get exercises => _filteredExercises();
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;

  List<Exercise> _filteredExercises() {
    return _exercises.where((exercise) {
      final matchesSearch =
          _searchQuery.isEmpty ||
          exercise.name.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesSearch;
    }).toList();
  }

  Future<void> loadExercises({String? category, String? difficulty}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final query = <String>[];
      if (category != null && category != 'Tous')
        query.add('category=$category');
      if (difficulty != null) query.add('difficulty=$difficulty');
      final endpoint = query.isEmpty
          ? '/exercises'
          : '/exercises?${query.join('&')}';

      final response = await apiService.get(endpoint);
      final data = response['data']['data'] as List<dynamic>;

      _exercises = data
          .map((json) => Exercise.fromJson(json as Map<String, dynamic>))
          .toList();
      _selectedCategory = category;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setCategory(String? category) {
    loadExercises(category: category);
  }
}
