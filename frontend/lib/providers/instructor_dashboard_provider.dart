import 'package:flutter/material.dart';
import '../services/api_service.dart';

class InstructorDashboardProvider extends ChangeNotifier {
  final ApiService _api = ApiService();

  bool _isLoading = false;
  String? _error;

  Map<String, dynamic>? _stats;
  Map<String, dynamic>? _analytics;
  Map<String, dynamic>? _students;
  Map<String, dynamic>? _earnings;
  int _unreadNotifications = 0;

  bool get isLoading => _isLoading;
  String? get error => _error;
  Map<String, dynamic>? get stats => _stats;
  Map<String, dynamic>? get analytics => _analytics;
  Map<String, dynamic>? get students => _students;
  Map<String, dynamic>? get earnings => _earnings;
  int get unreadNotifications => _unreadNotifications;

  int get totalStudents => (_stats?['totalStudents'] as num?)?.toInt() ?? 0;
  int get totalCourses => (_stats?['totalCourses'] as num?)?.toInt() ?? 0;
  double get totalRevenue => (_stats?['totalRevenue'] as num?)?.toDouble() ?? 0.0;
  double get averageRating => (_stats?['averageRating'] as num?)?.toDouble() ?? 0.0;
  int get totalReviews => (_stats?['totalReviews'] as num?)?.toInt() ?? 0;
  double get totalEarnings => (_stats?['totalEarnings'] as num?)?.toDouble() ?? 0.0;

  Future<void> loadAll() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        _api.getInstructorStats(),
        _api.getInstructorAnalytics(),
        _api.getInstructorStudents(limit: 20),
        _api.getInstructorEarnings(timeRange: 'all'),
        _api.getUnreadCount(),
      ]);

      if (results[0].success) _stats = (results[0] as ApiResponse).data;
      if (results[1].success) _analytics = (results[1] as ApiResponse).data;
      if (results[2].success) _students = (results[2] as ApiResponse).data;
      if (results[3].success) _earnings = (results[3] as ApiResponse).data;
      if (results[4].success && results[4].data != null) {
        _unreadNotifications = (results[4].data is Map) ? ((results[4].data! as Map)['count'] as num?)?.toInt() ?? 0 : 0;
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadStats() async {
    final r = await _api.getInstructorStats();
    if (r.success) _stats = r.data;
    notifyListeners();
  }

  Future<void> loadAnalytics({String? courseId}) async {
    final r = await _api.getInstructorAnalytics(courseId: courseId);
    if (r.success) _analytics = r.data;
    notifyListeners();
  }

  Future<void> loadStudents({int page = 1, String? search}) async {
    final r = await _api.getInstructorStudents(page: page, search: search);
    if (r.success) _students = r.data;
    notifyListeners();
  }

  Future<void> loadEarnings({String? timeRange, String? startDate, String? endDate}) async {
    final r = await _api.getInstructorEarnings(
      timeRange: timeRange,
      startDate: startDate,
      endDate: endDate,
    );
    if (r.success) _earnings = r.data;
    notifyListeners();
  }

  Future<void> loadUnreadCount() async {
    final r = await _api.getUnreadCount();
    if (r.success && r.data != null) {
      _unreadNotifications = (r.data is Map) ? ((r.data as Map)['count'] as num?)?.toInt() ?? 0 : 0;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
