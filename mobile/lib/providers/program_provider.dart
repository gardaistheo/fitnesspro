import 'package:flutter/material.dart';
import '../models/program_model.dart';
import '../services/api_service.dart';

class ProgramProvider extends ChangeNotifier {
  final ApiService apiService;

  List<Program> _programs = [];
  bool _isLoading = false;
  String? _error;

  ProgramProvider({required this.apiService});

  List<Program> get programs => _programs;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadPrograms({String? difficulty}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final endpoint = (difficulty == null || difficulty == 'Tous')
          ? '/programs'
          : '/programs?difficulty=$difficulty';

      final response = await apiService.get(endpoint);
      final data = response['data']['data'] as List<dynamic>;

      _programs = data.map((json) => Program.fromJson(json as Map<String, dynamic>)).toList();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addToPlanning({
    required int programId,
    required String scheduledDate,
    String? scheduledTime,
  }) async {
    try {
      await apiService.post('/workout-sessions', {
        'program_id': programId,
        'scheduled_date': scheduledDate,
        if (scheduledTime != null) 'scheduled_time': scheduledTime,
      });
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }
}
