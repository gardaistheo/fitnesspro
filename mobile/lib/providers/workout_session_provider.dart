import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/workout_session_model.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

class WorkoutSessionProvider extends ChangeNotifier {
  final ApiService apiService;
  final StorageService storageService;

  List<WorkoutSession> _sessions = [];
  bool _isLoading = false;
  String? _error;

  WorkoutSessionProvider({required this.apiService, required this.storageService});

  List<WorkoutSession> get sessions => _sessions;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Loads the locally cached planning immediately (so it survives an app
  /// restart even offline), then refreshes it from the API in the background.
  Future<void> loadSessions() async {
    _error = null;
    final cached = _readCache();
    if (cached != null) {
      _sessions = cached;
      notifyListeners();
    } else {
      _isLoading = true;
      notifyListeners();
    }

    try {
      final response = await apiService.get('/workout-sessions');
      final data = response['data']['data'] as List<dynamic>;

      _sessions = data.map((json) => WorkoutSession.fromJson(json as Map<String, dynamic>)).toList()
        ..sort((a, b) => a.scheduledDate.compareTo(b.scheduledDate));

      _isLoading = false;
      notifyListeners();
      await _writeCache();
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
      await _writeCache();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  List<WorkoutSession>? _readCache() {
    final raw = storageService.getWorkoutSessions();
    if (raw == null) return null;
    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded.map((json) => WorkoutSession.fromJson(json as Map<String, dynamic>)).toList()
        ..sort((a, b) => a.scheduledDate.compareTo(b.scheduledDate));
    } catch (_) {
      return null;
    }
  }

  Future<void> _writeCache() async {
    final encoded = jsonEncode(_sessions.map((s) => s.toJson()).toList());
    await storageService.saveWorkoutSessions(encoded);
  }

  /// The next upcoming planned session (today or later), if any.
  /// [_sessions] is kept sorted by scheduledDate ascending, so the first
  /// match is the soonest one.
  WorkoutSession? get nextSession {
    final today = DateTime.now();
    final todayDay = DateTime(today.year, today.month, today.day);
    for (final session in _sessions) {
      if (session.status != 'planned') continue;
      final day = DateTime(session.scheduledDate.year, session.scheduledDate.month, session.scheduledDate.day);
      if (!day.isBefore(todayDay)) return session;
    }
    return null;
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
