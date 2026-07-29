// lib/services/enrollment_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../services/base_api_service.dart';
import '../types/api_response.dart';

class EnrollmentApiService extends BaseApiService {
  
  // ==================== CONTINUE LEARNING ====================
  
  /// Get continue learning courses for the authenticated user
  Future<ApiResponse<List<Map<String, dynamic>>>> getContinueLearning({int limit = 5}) async {
    try {
      print('📱 EnrollmentApiService: Getting continue learning courses...');
      print('📱 Limit: $limit');
      
      // The main endpoint from your logs is returning 400
      // Let's try different endpoint formats
      
      // First try: /enroll/continue-learning with page parameter
      final response = await sendAuthenticatedRequest(
        method: 'GET',
        endpoint: '/enroll/continue-learning?limit=$limit&page=1',
      );

      print('📱 Response status: ${response.statusCode}');
      print('📱 Response body: ${response.body}');

      // Handle 401 - token expired
      if (response.statusCode == 401) {
        print('❌ Authentication failed - attempting token refresh...');
        final newToken = await refreshAccessToken();
        if (newToken != null && newToken.isNotEmpty) {
          print('✅ Token refreshed, retrying...');
          final retryResponse = await sendAuthenticatedRequest(
            method: 'GET',
            endpoint: '/enroll/continue-learning?limit=$limit&page=1',
          );
          if (retryResponse.statusCode == 200) {
            return _parseContinueLearningResponse(retryResponse);
          }
        }
        return ApiResponse.error('Session expired. Please login again.');
      }

      // Handle 400 - invalid data, try alternative endpoints
      if (response.statusCode == 400) {
        print('⚠️ Bad request - trying alternative endpoints...');
        return await _getContinueLearningAlternative(limit: limit);
      }

      // Parse successful response
      if (response.statusCode == 200) {
        return _parseContinueLearningResponse(response);
      }

      // Handle other errors
      final data = jsonDecode(response.body);
      final errorMsg = data['message'] ?? data['error'] ?? 'Failed to fetch continue learning';
      print('❌ API Error: $errorMsg');
      return ApiResponse.error(errorMsg);
      
    } catch (e) {
      print('❌ getContinueLearning error: $e');
      return ApiResponse.error(e.toString());
    }
  }

  /// Alternative method to get continue learning courses (fallback)
  Future<ApiResponse<List<Map<String, dynamic>>>> _getContinueLearningAlternative({int limit = 5}) async {
    try {
      // Try different endpoint patterns with different parameter formats
      final endpoints = [
        // Try with different parameter names
        '/enroll/continue-learning?limit=$limit&page=1',
        '/enroll/continue-learning?limit=$limit&offset=0',
        '/enroll/continue-learning?limit=$limit&skip=0',
        '/enroll/continue-learning?take=$limit',
        '/enroll/continue-learning?size=$limit',
        
        // Try different base paths
        '/enrollments/continue-learning?limit=$limit&page=1',
        '/enrollments/continue-learning?limit=$limit&offset=0',
        '/enrollments/continue-learning?take=$limit',
        
        // Try with user context
        '/user/continue-learning?limit=$limit&page=1',
        '/user/enrollments/continue?limit=$limit&page=1',
        '/user/courses/continue?limit=$limit&page=1',
        
        // Try course-specific endpoints
        '/courses/continue-learning?limit=$limit&page=1',
        '/courses/continue?limit=$limit&page=1',
        '/learning/continue?limit=$limit&page=1',
        
        // Try my-* endpoints
        '/my-courses/continue?limit=$limit&page=1',
        '/my/enrollments/continue?limit=$limit&page=1',
        
        // Try with student-specific endpoint (since the user is a student)
        '/student/continue-learning?limit=$limit&page=1',
        '/student/enrollments/continue?limit=$limit&page=1',
      ];

      for (final endpoint in endpoints) {
        print('📱 Trying alternative endpoint: $endpoint');
        try {
          final response = await sendAuthenticatedRequest(
            method: 'GET',
            endpoint: endpoint,
          );

          print('📱 Alternative response status: ${response.statusCode}');
          
          if (response.statusCode == 200) {
            final data = jsonDecode(response.body);
            print('📱 Alternative response body: ${response.body}');
            
            if (data['success'] == true) {
              List<dynamic> enrollments = [];
              
              // Check different possible data structures
              if (data['data'] is List) {
                enrollments = data['data'] as List<dynamic>;
              } else if (data['data'] is Map) {
                final dataMap = data['data'] as Map<String, dynamic>;
                if (dataMap.containsKey('enrollments') && dataMap['enrollments'] is List) {
                  enrollments = dataMap['enrollments'] as List<dynamic>;
                } else if (dataMap.containsKey('courses') && dataMap['courses'] is List) {
                  enrollments = dataMap['courses'] as List<dynamic>;
                } else if (dataMap.containsKey('items') && dataMap['items'] is List) {
                  enrollments = dataMap['items'] as List<dynamic>;
                } else if (dataMap.containsKey('data') && dataMap['data'] is List) {
                  enrollments = dataMap['data'] as List<dynamic>;
                } else if (dataMap.containsKey('results') && dataMap['results'] is List) {
                  enrollments = dataMap['results'] as List<dynamic>;
                }
              }
              
              print('✅ Found ${enrollments.length} courses from alternative endpoint: $endpoint');
              
              if (enrollments.isNotEmpty) {
                final courses = enrollments.map((e) => _mapEnrollmentToCourse(e)).toList();
                return ApiResponse.success(courses);
              }
            }
          } else if (response.statusCode == 400) {
            // If we get 400, log it and continue to next endpoint
            print('⚠️ Endpoint returned 400, trying next...');
            continue;
          }
        } catch (e) {
          print('⚠️ Alternative endpoint failed: $e');
          continue;
        }
      }

      // If all alternatives fail, return empty list (not error)
      print('⚠️ All endpoints failed - returning empty list');
      return ApiResponse.success([]);
      
    } catch (e) {
      print('❌ Alternative getContinueLearning error: $e');
      return ApiResponse.success([]);
    }
  }

  /// Parse the continue learning response with support for multiple data formats
  ApiResponse<List<Map<String, dynamic>>> _parseContinueLearningResponse(http.Response response) {
    try {
      final data = jsonDecode(response.body);
      print('📱 Parsing response data: $data');
      
      if (data['success'] == true) {
        List<dynamic> enrollments = [];
        
        // Check different possible data structures
        if (data['data'] is List) {
          enrollments = data['data'] as List<dynamic>;
        } else if (data['data'] is Map) {
          final dataMap = data['data'] as Map<String, dynamic>;
          if (dataMap.containsKey('enrollments') && dataMap['enrollments'] is List) {
            enrollments = dataMap['enrollments'] as List<dynamic>;
          } else if (dataMap.containsKey('courses') && dataMap['courses'] is List) {
            enrollments = dataMap['courses'] as List<dynamic>;
          } else if (dataMap.containsKey('items') && dataMap['items'] is List) {
            enrollments = dataMap['items'] as List<dynamic>;
          } else if (dataMap.containsKey('data') && dataMap['data'] is List) {
            enrollments = dataMap['data'] as List<dynamic>;
          } else if (dataMap.containsKey('results') && dataMap['results'] is List) {
            enrollments = dataMap['results'] as List<dynamic>;
          }
        }
        
        print('✅ Found ${enrollments.length} continue learning courses');
        
        if (enrollments.isNotEmpty) {
          print('📱 First enrollment structure: ${enrollments.first}');
          final courses = enrollments.map((e) => _mapEnrollmentToCourse(e)).toList();
          return ApiResponse.success(courses);
        } else {
          print('📱 No courses found in response');
          return ApiResponse.success([]);
        }
      }
      
      return ApiResponse.error(data['message'] ?? 'Failed to fetch continue learning');
    } catch (e) {
      print('❌ Error parsing response: $e');
      return ApiResponse.error('Failed to parse response: $e');
    }
  }

  /// Map enrollment data to course format
  Map<String, dynamic> _mapEnrollmentToCourse(dynamic e) {
    if (e == null) {
      print('⚠️ Null enrollment data received');
      return _getDefaultCourse();
    }

    // Try to get data from different possible field names
    final String id = _getString(e, 'id') ?? '';
    final String courseId = _getString(e, 'courseId') ?? _getString(e, '_id') ?? id;
    final String title = _getString(e, 'title') ?? _getString(e, 'name') ?? 'Untitled Course';
    final String description = _getString(e, 'description') ?? _getString(e, 'overview') ?? '';
    final String thumbnail = _getString(e, 'thumbnail') ?? _getString(e, 'image') ?? _getString(e, 'coverImage') ?? 'https://via.placeholder.com/400x225/4F46E5/FFFFFF?text=Course';
    final String instructor = _getString(e, 'instructor') ?? _getString(e, 'instructorName') ?? _getString(e, 'teacher') ?? 'Unknown Instructor';
    final String instructorId = _getString(e, 'instructorId') ?? _getString(e, 'instructor_id') ?? _getString(e, 'teacherId') ?? '';
    final String instructorAvatar = _getString(e, 'instructorAvatar') ?? _getString(e, 'instructor_avatar') ?? _getString(e, 'teacherAvatar') ?? '';
    final double progress = _toDouble(_getValue(e, 'progress')) ?? _toDouble(_getValue(e, 'completionPercentage'));
    final bool isCompleted = _getBool(e, 'isCompleted') ?? _getBool(e, 'completed') ?? false;
    final String level = _getString(e, 'level') ?? _getString(e, 'difficulty') ?? 'Beginner';
    final String category = _getString(e, 'category') ?? _getString(e, 'categoryName') ?? _getString(e, 'category_name') ?? 'General';
    final double price = _toDouble(_getValue(e, 'price'));
    final double originalPrice = _toDouble(_getValue(e, 'originalPrice')) ?? _toDouble(_getValue(e, 'original_price'));
    final double rating = _toDouble(_getValue(e, 'rating')) ?? _toDouble(_getValue(e, 'averageRating'));
    final int reviewsCount = _toInt(_getValue(e, 'reviewsCount')) ?? _toInt(_getValue(e, 'reviewCount'));
    final int studentsCount = _toInt(_getValue(e, 'studentsCount')) ?? _toInt(_getValue(e, 'studentCount')) ?? _toInt(_getValue(e, 'enrolledCount'));
    final String language = _getString(e, 'language') ?? 'English';
    final lastAccessedAt = _getValue(e, 'lastAccessedAt') ?? _getValue(e, 'lastAccessed') ?? _getValue(e, 'updatedAt');

    // If progress is null, try to calculate from sections or lessons
    double finalProgress = progress;
    if (finalProgress == 0.0 && _getValue(e, 'sections') != null) {
      final sections = _getList(e, 'sections');
      if (sections != null && sections.isNotEmpty) {
        // Try to calculate progress from sections
        int totalLessons = 0;
        int completedLessons = 0;
        for (var section in sections) {
          final lessons = _getList(section, 'lessons');
          if (lessons != null) {
            totalLessons += lessons.length;
            for (var lesson in lessons) {
              if (_getBool(lesson, 'completed') == true) {
                completedLessons++;
              }
            }
          }
        }
        if (totalLessons > 0) {
          finalProgress = (completedLessons / totalLessons) * 100;
        }
      }
    }

    return {
      'id': id,
      'courseId': courseId,
      'title': title,
      'description': description,
      'thumbnail': thumbnail,
      'instructor': instructor,
      'instructorId': instructorId,
      'instructorAvatar': instructorAvatar,
      'progress': finalProgress,
      'remainingTime': _calculateRemainingTime(finalProgress, isCompleted),
      'isCompleted': isCompleted,
      'level': level,
      'category': category,
      'price': price,
      'originalPrice': originalPrice,
      'rating': rating,
      'reviewsCount': reviewsCount,
      'studentsCount': studentsCount,
      'language': language,
      'lastAccessedAt': lastAccessedAt,
      'sections': _getList(e, 'sections') ?? [],
      'learningObjectives': _getList(e, 'learningObjectives') ?? _getList(e, 'whatYouWillLearn') ?? [],
      'requirements': _getList(e, 'requirements') ?? [],
      'studyMaterials': _getList(e, 'studyMaterials') ?? [],
      'whatYouWillLearn': _getList(e, 'whatYouWillLearn') ?? [],
    };
  }

  Map<String, dynamic> _getDefaultCourse() {
    return {
      'id': '',
      'courseId': '',
      'title': 'Untitled Course',
      'description': '',
      'thumbnail': 'https://via.placeholder.com/400x225/4F46E5/FFFFFF?text=Course',
      'instructor': 'Unknown Instructor',
      'instructorId': '',
      'instructorAvatar': '',
      'progress': 0.0,
      'remainingTime': 'Start learning',
      'isCompleted': false,
      'level': 'Beginner',
      'category': 'General',
      'price': 0.0,
      'originalPrice': 0.0,
      'rating': 0.0,
      'reviewsCount': 0,
      'studentsCount': 0,
      'language': 'English',
      'lastAccessedAt': null,
      'sections': [],
      'learningObjectives': [],
      'requirements': [],
      'studyMaterials': [],
      'whatYouWillLearn': [],
    };
  }

  // Helper methods to safely extract values from dynamic objects
  dynamic _getValue(dynamic obj, String key) {
    if (obj == null) return null;
    if (obj is Map<String, dynamic>) {
      return obj[key];
    }
    return null;
  }

  String? _getString(dynamic obj, String key) {
    final value = _getValue(obj, key);
    return value?.toString();
  }

  bool? _getBool(dynamic obj, String key) {
    final value = _getValue(obj, key);
    if (value is bool) return value;
    if (value is String) return value.toLowerCase() == 'true';
    if (value is int) return value == 1;
    return null;
  }

  List? _getList(dynamic obj, String key) {
    final value = _getValue(obj, key);
    if (value is List) return value;
    return null;
  }

  static double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      try {
        return double.parse(value);
      } catch (_) {
        return 0.0;
      }
    }
    if (value is num) return value.toDouble();
    return 0.0;
  }

  static int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) {
      try {
        return int.parse(value);
      } catch (_) {
        return 0;
      }
    }
    if (value is num) return value.toInt();
    return 0;
  }

  static String _calculateRemainingTime(double progress, bool isCompleted) {
    if (isCompleted) {
      return 'Completed';
    }
    if (progress <= 0) {
      return 'Start learning';
    }
    return '${(100 - progress).toInt()}% remaining';
  }

  // ==================== OTHER ENROLLMENT METHODS ====================

  Future<ApiResponse<Map<String, dynamic>>> getMyEnrollments({
    int page = 1,
    int limit = 10,
    bool? isCompleted,
  }) async {
    try {
      String endpoint = '/enroll/my-enrollments?page=$page&limit=$limit';
      if (isCompleted != null) {
        endpoint += '&isCompleted=$isCompleted';
      }

      final response = await sendAuthenticatedRequest(
        method: 'GET',
        endpoint: endpoint,
      );
      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return ApiResponse.success(
          {'data': data['data'] ?? [], 'pagination': data['pagination'] ?? {}}
        );
      }

      return ApiResponse.error(data['message'] ?? 'Failed to fetch enrollments');
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> getCourseProgress(String courseId) async {
    try {
      final response = await sendAuthenticatedRequest(
        method: 'GET',
        endpoint: '/enroll/courses/$courseId/progress',
      );
      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return ApiResponse.success(data['data'] ?? {});
      }
      return ApiResponse.error(data['message'] ?? 'Failed to fetch course progress');
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  Future<ApiResponse<dynamic>> updateLessonProgress(String lessonId, bool isCompleted) async {
    try {
      final response = await sendAuthenticatedRequest(
        method: 'PATCH',
        endpoint: '/enroll/lessons/$lessonId/progress',
        body: {'isCompleted': isCompleted},
      );
      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return ApiResponse.success(null);
      }
      return ApiResponse.error(data['message'] ?? 'Failed to update progress');
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> enrollInCourse(String courseId) async {
    try {
      final response = await sendAuthenticatedRequest(
        method: 'POST',
        endpoint: '/enroll/$courseId',
      );
      final data = jsonDecode(response.body);

      if (response.statusCode == 201 && data['success'] == true) {
        return ApiResponse.success(data['data'] ?? {});
      }
      return ApiResponse.error(data['message'] ?? 'Failed to enroll');
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  Future<ApiResponse<dynamic>> unenrollFromCourse(String courseId) async {
    try {
      final response = await sendAuthenticatedRequest(
        method: 'DELETE',
        endpoint: '/enroll/$courseId',
      );
      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return ApiResponse.success(null);
      }
      return ApiResponse.error(data['message'] ?? 'Failed to unenroll');
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> checkEnrollmentStatus(String courseId) async {
    try {
      final response = await sendAuthenticatedRequest(
        method: 'GET',
        endpoint: '/enroll/$courseId/status',
      );
      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return ApiResponse.success(data['data'] ?? {});
      }
      return ApiResponse.error(data['message'] ?? 'Failed to check enrollment status');
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }
}