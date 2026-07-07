import 'package:flutter/material.dart';
import '../models/workout_session_model.dart';
import '../services/api_service.dart';

class WorkoutSessionProvider extends ChangeNotifier {
  final ApiService apiService;

  List<WorkoutSession> _sessions = [];
  bool _isLoading = false;
  String? _error;

  WorkoutSessionProvider({required this.apiService});

  List<WorkoutSession> get sessions => _sessions;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadSessions() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await apiService.get('/workout-sessions');
      final data = response['data']['data'] as List<dynamic>;

      _sessions = data.map((json) => WorkoutSession.fromJson(json as Map<String, dynamic>)).toList()
        ..sort((a, b) => a.scheduledDate.compareTo(b.scheduledDate));

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteSession(int id) async {
    try {
      await apiService.delete('/workout-sessions/$id');
      _sessions.removeWhere((s) => s.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Groups sessions by calendar day, preserving date order.
  Map<DateTime, List<WorkoutSession>> get sessionsByDate {
    final grouped = <DateTime, List<WorkoutSession>>{};
    for (final session in _sessions) {
      final day = DateTime(session.scheduledDate.year, session.scheduledDate.month, session.scheduledDate.day);
      grouped.putIfAbsent(day, () => []).add(session);
    }
    return grouped;
  }

  /// Returns "Aujourd'hui", "Demain", "Dans Nj", or "Passé" for a given date.
  String dateLabel(DateTime date) {
    final today = DateTime.now();
    final todayDay = DateTime(today.year, today.month, today.day);
    final diff = date.difference(todayDay).inDays;

    if (diff == 0) return "Aujourd'hui";
    if (diff == 1) return 'Demain';
    if (diff > 1) return 'Dans ${diff}j';
    return 'Passé';
  }
}
