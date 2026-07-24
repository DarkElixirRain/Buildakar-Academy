// lib/providers/live_class_provider.dart

import 'package:flutter/material.dart';
import '../models/live_class_model.dart';
import '../services/api_service.dart';
import '../providers/auth_provider.dart';

class LiveClassProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  final AuthProvider _authProvider;

  List<LiveClass> _liveClasses = [];
  List<LiveClass> _upcomingClasses = [];
  List<LiveClass> _endedClasses = [];
  List<LiveClass> _cancelledClasses = [];
  List<LiveClass> _allClasses = [];
  Map<String, int> _classSummary = {};
  final Map<String, bool> _followedClasses = {};

  bool _isLoading = false;
  bool _isFirstLoad = true;
  bool _hasError = false;
  String _errorMessage = '';

  LiveClassProvider({required AuthProvider authProvider})
      : _authProvider = authProvider;

  // Getters
  List<LiveClass> get liveClasses => _liveClasses;
  List<LiveClass> get upcomingClasses => _upcomingClasses;
  List<LiveClass> get endedClasses => _endedClasses;
  List<LiveClass> get cancelledClasses => _cancelledClasses;
  List<LiveClass> get allClasses => _allClasses;
  Map<String, int> get classSummary => _classSummary;
  bool get isLoading => _isLoading;
  bool get isFirstLoad => _isFirstLoad;
  bool get hasError => _hasError;
  String get errorMessage => _errorMessage;

  // Check if user is following a class (local implementation)
  bool isFollowingClass(String classId) {
    return _followedClasses[classId] ?? false;
  }

  // Get current user role
  Future<String?> getUserRole() async {
    // Try to refresh user data first to ensure we have current info
    await _authProvider.refreshUser();
    return _authProvider.role;
  }
  
  // ==================== NEW: Load ALL student classes (categorized) ====================
  // This uses the new /student/all endpoint
  Future<void> loadAllStudentClasses() async {
    _isLoading = true;
    _hasError = false;
    _errorMessage = '';
    notifyListeners();

    try {
      // Get current user role
      final userRole = await getUserRole();

      if (userRole == null) {
        _hasError = true;
        _errorMessage = 'Unable to determine user role';
        _isFirstLoad = false;
        _isLoading = false;
        notifyListeners();
        return;
      }

      if (userRole == 'INSTRUCTOR' || userRole == 'ADMIN') {
        // For instructors and admins, get their own classes
        final result = await _apiService.getInstructorLiveClasses();

        if (result.success && result.data != null) {
          _allClasses = result.data!;
          _categorizeClasses(result.data!);
          _updateSummary();
          _isFirstLoad = false;
          _hasError = false;
          _errorMessage = '';
        } else {
          _hasError = true;
          _errorMessage = result.error ?? 'Failed to load instructor live classes';
          _isFirstLoad = false;
        }
      } else {
        // For students, use the new /student/all endpoint
        final result = await _apiService.getAllStudentLiveClasses();

        if (result.success && result.data != null) {
          final data = result.data!;
          
          // Update categorized lists from the response
          _liveClasses = data['live'] as List<LiveClass>? ?? [];
          _upcomingClasses = data['upcoming'] as List<LiveClass>? ?? [];
          _endedClasses = data['ended'] as List<LiveClass>? ?? [];
          _cancelledClasses = data['cancelled'] as List<LiveClass>? ?? [];
          _allClasses = data['all'] as List<LiveClass>? ?? [];
          _classSummary = data['summary'] as Map<String, int>? ?? {};
          
          // Restore following status for all classes
          for (var classItem in _allClasses) {
            final classId = classItem.id;
            if (_followedClasses.containsKey(classId)) {
              _updateClassFollowingStatus(classId, _followedClasses[classId]!);
            }
          }
          
          _isFirstLoad = false;
          _hasError = false;
          _errorMessage = '';
        } else {
          _hasError = true;
          _errorMessage = result.error ?? 'Failed to load student live classes';
          _isFirstLoad = false;
          // Clear data on error
          _liveClasses = [];
          _upcomingClasses = [];
          _endedClasses = [];
          _cancelledClasses = [];
          _allClasses = [];
          _classSummary = {};
        }
      }
    } catch (e) {
      _hasError = true;
      _errorMessage = e.toString();
      _isFirstLoad = false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ==================== Load all classes based on user role (legacy) ====================
  Future<void> loadAllClasses() async {
    _isLoading = true;
    _hasError = false;
    _errorMessage = '';
    notifyListeners();

    try {
      // Get current user role
      final userRole = await getUserRole();

      if (userRole == null) {
        _hasError = true;
        _errorMessage = 'Unable to determine user role';
        _isFirstLoad = false;
        notifyListeners();
        return;
      }

      if (userRole == 'INSTRUCTOR' || userRole == 'ADMIN') {
        // For instructors and admins, get their own classes
        final result = await _apiService.getInstructorLiveClasses();

        if (result.success && result.data != null) {
          _allClasses = result.data!;
          _categorizeClasses(result.data!);
          _updateSummary();
          _isFirstLoad = false;
          _hasError = false;
          _errorMessage = '';
          notifyListeners();
          return;
        } else {
          _hasError = true;
          _errorMessage = result.error ?? 'Failed to load instructor live classes';
          _isFirstLoad = false;
          notifyListeners();
          return;
        }
      } else {
        // For students, get classes from enrolled courses
        await _loadStudentClasses();
      }

    } catch (e) {
      _hasError = true;
      _errorMessage = e.toString();
      _isFirstLoad = false;
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load classes for student based on enrollments
  Future<void> _loadStudentClasses() async {
    try {
      // Get user's enrollments
      final enrollmentsResult = await _apiService.getMyEnrollments();

      if (!enrollmentsResult.success || enrollmentsResult.data == null) {
        _hasError = true;
        _errorMessage = enrollmentsResult.error ?? 'Failed to load enrollments';
        _isFirstLoad = false;
        notifyListeners();
        return;
      }

      // Extract course IDs from enrollments
      final enrollments = enrollmentsResult.data!['data'] as List<dynamic>?;
      if (enrollments == null || enrollments.isEmpty) {
        // No enrollments, show empty state
        _allClasses = [];
        _liveClasses = [];
        _upcomingClasses = [];
        _endedClasses = [];
        _cancelledClasses = [];
        _classSummary = {};
        _isFirstLoad = false;
        _hasError = false;
        _errorMessage = '';
        notifyListeners();
        return;
      }

      final List<String> courseIds = [];
      for (var enrollment in enrollments) {
        final courseId = enrollment['courseId']?.toString();
        if (courseId != null && courseId.isNotEmpty) {
          courseIds.add(courseId);
        }
      }

      if (courseIds.isEmpty) {
        _allClasses = [];
        _liveClasses = [];
        _upcomingClasses = [];
        _endedClasses = [];
        _cancelledClasses = [];
        _classSummary = {};
        _isFirstLoad = false;
        _hasError = false;
        _errorMessage = '';
        notifyListeners();
        return;
      }

      // Fetch live classes for each course
      final List<LiveClass> allClasses = [];
      bool hasError = false;
      String? errorMessage;

      for (final courseId in courseIds) {
        try {
          final result = await _apiService.getCourseLiveClasses(courseId);
          if (result.success && result.data != null) {
            allClasses.addAll(result.data!);
          } else {
            // Continue with other courses even if one fails
            if (!hasError) {
              _hasError = true;
              _errorMessage = result.error ?? 'Failed to load some course classes';
              hasError = true;
            }
          }
        } catch (e) {
          // Continue with other courses even if one fails
          if (!hasError) {
            _hasError = true;
            _errorMessage = e.toString();
            hasError = true;
          }
        }
      }

      if (!hasError) {
        _allClasses = allClasses;
        _categorizeClasses(allClasses);
        _updateSummary();
        _isFirstLoad = false;
        _hasError = false;
        _errorMessage = '';
        notifyListeners();
      } else {
        // If we had errors but still got some data, show what we have
        if (allClasses.isNotEmpty) {
          _allClasses = allClasses;
          _categorizeClasses(allClasses);
          _updateSummary();
          _isFirstLoad = false;
          _hasError = true; // Keep error state to show message
          notifyListeners();
        } else {
          _isFirstLoad = false;
          notifyListeners();
        }
      }

    } catch (e) {
      _hasError = true;
      _errorMessage = e.toString();
      _isFirstLoad = false;
      notifyListeners();
    }
  }
  
  // Load classes for a specific course
  Future<void> loadCourseClasses(String courseId) async {
    _isLoading = true;
    _hasError = false;
    _errorMessage = '';
    notifyListeners();
    
    try {
      final result = await _apiService.getCourseLiveClasses(courseId);
      
      if (result.success && result.data != null) {
        _allClasses = result.data!;
        _categorizeClasses(result.data!);
        _updateSummary();
        _isFirstLoad = false;
        _hasError = false;
        _errorMessage = '';
      } else {
        _hasError = true;
        _errorMessage = result.error ?? 'Failed to load course classes';
        _isFirstLoad = false;
      }
    } catch (e) {
      _hasError = true;
      _errorMessage = e.toString();
      _isFirstLoad = false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Load instructor's classes (for instructor view)
  Future<void> loadInstructorClasses() async {
    final userRole = await getUserRole();
    if (userRole != 'INSTRUCTOR' && userRole != 'ADMIN') {
      _isLoading = false;
      _hasError = true;
      _errorMessage = 'Only instructors can load instructor classes';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _hasError = false;
    _errorMessage = '';
    notifyListeners();

    try {
      final result = await _apiService.getInstructorLiveClasses();

      if (result.success && result.data != null) {
        _allClasses = result.data!;
        _categorizeClasses(result.data!);
        _updateSummary();
        _isFirstLoad = false;
        _hasError = false;
        _errorMessage = '';
      } else {
        _hasError = true;
        _errorMessage = result.error ?? 'Failed to load instructor classes';
        _isFirstLoad = false;
      }
    } catch (e) {
      _hasError = true;
      _errorMessage = e.toString();
      _isFirstLoad = false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Create a new live class
  Future<bool> createLiveClass(Map<String, dynamic> data) async {
    final userRole = await getUserRole();
    if (userRole != 'INSTRUCTOR' && userRole != 'ADMIN') {
      _isLoading = false;
      _hasError = true;
      _errorMessage = 'Only instructors can create live classes';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _hasError = false;
    _errorMessage = '';
    notifyListeners();

    try {
      final result = await _apiService.createLiveClass(data);

      if (result.success && result.data != null) {
        // Add to all classes
        _allClasses.insert(0, result.data!);
        _categorizeClasses(_allClasses);
        _updateSummary();
        notifyListeners();
        return true;
      } else {
        _errorMessage = result.error ?? 'Failed to create live class';
        _hasError = true;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString();
      _hasError = true;
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Update a live class
  Future<bool> updateLiveClass(String id, Map<String, dynamic> data) async {
    final userRole = await getUserRole();
    if (userRole != 'INSTRUCTOR' && userRole != 'ADMIN') {
      _isLoading = false;
      _hasError = true;
      _errorMessage = 'Only instructors can update live classes';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final result = await _apiService.updateLiveClass(id, data);

      if (result.success && result.data != null) {
        _updateClassInLists(result.data!);
        _updateSummary();
        notifyListeners();
        return true;
      } else {
        _errorMessage = result.error ?? 'Failed to update live class';
        _hasError = true;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString();
      _hasError = true;
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Cancel a live class
  Future<bool> cancelLiveClass(String id) async {
    final userRole = await getUserRole();
    if (userRole != 'INSTRUCTOR' && userRole != 'ADMIN') {
      _isLoading = false;
      _hasError = true;
      _errorMessage = 'Only instructors can cancel live classes';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final result = await _apiService.cancelLiveClass(id);

      if (result.success && result.data != null) {
        _removeClassFromLists(id);
        _updateSummary();
        notifyListeners();
        return true;
      } else {
        _errorMessage = result.error ?? 'Failed to cancel live class';
        _hasError = true;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString();
      _hasError = true;
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Start a live class
  Future<bool> startLiveClass(String id) async {
    final userRole = await getUserRole();
    if (userRole != 'INSTRUCTOR' && userRole != 'ADMIN') {
      _isLoading = false;
      _hasError = true;
      _errorMessage = 'Only instructors can start live classes';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final result = await _apiService.startLiveClass(id);

      if (result.success && result.data != null) {
        _updateClassInLists(result.data!);
        _updateSummary();
        notifyListeners();
        return true;
      } else {
        _errorMessage = result.error ?? 'Failed to start live class';
        _hasError = true;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString();
      _hasError = true;
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // End a live class
  Future<bool> endLiveClass(String id) async {
    final userRole = await getUserRole();
    if (userRole != 'INSTRUCTOR' && userRole != 'ADMIN') {
      _isLoading = false;
      _hasError = true;
      _errorMessage = 'Only instructors can end live classes';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final result = await _apiService.endLiveClass(id);

      if (result.success && result.data != null) {
        _updateClassInLists(result.data!);
        _updateSummary();
        notifyListeners();
        return true;
      } else {
        _errorMessage = result.error ?? 'Failed to end live class';
        _hasError = true;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString();
      _hasError = true;
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Join a live class
  Future<Map<String, dynamic>?> joinLiveClass(String id) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      final result = await _apiService.joinLiveClass(id);
      
      if (result.success && result.data != null) {
        // Refresh the list to update counts after joining
        await loadAllStudentClasses();
        return result.data;
      } else {
        _errorMessage = result.error ?? 'Failed to join live class';
        _hasError = true;
        notifyListeners();
        return null;
      }
    } catch (e) {
      _errorMessage = e.toString();
      _hasError = true;
      notifyListeners();
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Toggle follow/reminder for a class (local implementation)
  Future<bool> toggleFollowClass(String classId) async {
    // Check if user is authenticated
    final userRole = await getUserRole();
    if (userRole == null) {
      return false;
    }

    try {
      // Since follow functionality is not implemented in backend,
      // we'll just toggle locally for UI purposes
      final currentStatus = _followedClasses[classId] ?? false;
      _followedClasses[classId] = !currentStatus;
      _updateClassFollowingStatus(classId, _followedClasses[classId]!);
      notifyListeners();
      return true;
    } catch (e) {
      print('Error toggling follow: $e');
      return false;
    }
  }
  
  // Update summary statistics
  void _updateSummary() {
    _classSummary = {
      'total': _allClasses.length,
      'live': _liveClasses.length,
      'upcoming': _upcomingClasses.length,
      'ended': _endedClasses.length,
      'cancelled': _cancelledClasses.length,
    };
  }
  
  // Categorize classes by status
  void _categorizeClasses(List<LiveClass> classes) {
    final now = DateTime.now();
    
    // Live classes
    _liveClasses = classes.where((c) => 
      c.status == 'LIVE' || c.status == 'live' || c.status == 'started'
    ).toList();
    
    // Upcoming classes
    _upcomingClasses = classes.where((c) => 
      c.status == 'SCHEDULED' || c.status == 'scheduled' || c.status == 'upcoming'
    ).toList();
    
    // Ended classes
    _endedClasses = classes.where((c) => 
      c.status == 'ENDED' || c.status == 'ended' || c.status == 'completed'
    ).toList();
    
    // Cancelled classes
    _cancelledClasses = classes.where((c) => 
      c.status == 'CANCELLED' || c.status == 'cancelled'
    ).toList();
    
    // Update summary
    _updateSummary();
  }
  
  // Update class in all lists
  void _updateClassInLists(LiveClass updatedClass) {
    _updateList(_allClasses, updatedClass);
    _updateList(_liveClasses, updatedClass);
    _updateList(_upcomingClasses, updatedClass);
    _updateList(_endedClasses, updatedClass);
    _updateList(_cancelledClasses, updatedClass);
  }
  
  void _updateList(List<LiveClass> list, LiveClass updatedClass) {
    final index = list.indexWhere((c) => c.id == updatedClass.id);
    if (index != -1) {
      list[index] = updatedClass;
    }
  }
  
  // Remove class from all lists
  void _removeClassFromLists(String id) {
    _allClasses.removeWhere((c) => c.id == id);
    _liveClasses.removeWhere((c) => c.id == id);
    _upcomingClasses.removeWhere((c) => c.id == id);
    _endedClasses.removeWhere((c) => c.id == id);
    _cancelledClasses.removeWhere((c) => c.id == id);
    _followedClasses.remove(id);
  }
  
  // Update following status in local state
  void _updateClassFollowingStatus(String classId, bool isFollowing) {
    // Update in all lists
    _updateListFollowingStatus(_allClasses, classId, isFollowing);
    _updateListFollowingStatus(_liveClasses, classId, isFollowing);
    _updateListFollowingStatus(_upcomingClasses, classId, isFollowing);
    _updateListFollowingStatus(_endedClasses, classId, isFollowing);
    _updateListFollowingStatus(_cancelledClasses, classId, isFollowing);
  }
  
  void _updateListFollowingStatus(List<LiveClass> list, String classId, bool isFollowing) {
    final index = list.indexWhere((cls) => cls.id == classId);
    if (index != -1) {
      final updatedClass = list[index].copyWith(isFollowing: isFollowing);
      list[index] = updatedClass;
    }
  }
  
  // Get a single class by ID
  LiveClass? getClassById(String classId) {
    try {
      return _allClasses.firstWhere((cls) => cls.id == classId);
    } catch (_) {
      return null;
    }
  }
  
  // Count getters
  int get liveCount => _liveClasses.length;
  int get upcomingCount => _upcomingClasses.length;
  int get endedCount => _endedClasses.length;
  int get cancelledCount => _cancelledClasses.length;
  
  // Refresh only live classes
  Future<void> refreshLiveClasses() async {
    try {
      final result = await _apiService.getInstructorLiveClasses();
      if (result.success && result.data != null) {
        _allClasses = result.data!;
        _categorizeClasses(result.data!);
        _updateSummary();
        notifyListeners();
      }
    } catch (e) {
      print('Error refreshing live classes: $e');
    }
  }
  
  // Refresh all classes
  Future<void> refresh() async {
    await loadAllStudentClasses();
  }
  
  // Clear error
  void clearError() {
    _hasError = false;
    _errorMessage = '';
    notifyListeners();
  }
  
  // Get classes by status (convenience method for compatibility)
  @Deprecated('Use specific getters instead')
  Future<List<LiveClass>?> getClassesByStatus(String status) async {
    switch (status.toLowerCase()) {
      case 'live':
        return _liveClasses;
      case 'upcoming':
        return _upcomingClasses;
      case 'ended':
        return _endedClasses;
      case 'cancelled':
        return _cancelledClasses;
      default:
        return [];
    }
  }
}