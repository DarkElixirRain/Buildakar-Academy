// lib/services/api_service.dart

import 'dart:io';

export '../types/api_response.dart';

import '../models/auth_model.dart';
import '../models/live_class_model.dart';
import '../models/search_results.dart';
import '../models/search_suggestion.dart';
import '../models/trending_data.dart';
import '../models/course_model.dart';
import '../types/api_response.dart';
import 'auth_service.dart';
import 'base_api_service.dart';
import 'category_service.dart';
import 'course_service.dart';
import 'enrollment_service.dart';
import 'instructor_service.dart';
import 'learning_service.dart';
import 'live_class_service.dart';
import 'notes_material_service.dart';
import 'notification_service.dart';
import 'review_service.dart';
import 'search_service.dart';

class ApiService extends BaseApiService {
  static final ApiService _instance = ApiService._internal();

  factory ApiService() => _instance;

  ApiService._internal();

  // Use Api Services
  final AuthApiService _authService = AuthApiService();
  final CategoryApiService _categoryService = CategoryApiService();
  final CourseApiService _courseService = CourseApiService();
  final EnrollmentApiService _enrollmentService = EnrollmentApiService();
  final LearningApiService _learningService = LearningApiService();
  final ReviewApiService _reviewService = ReviewApiService();
  final NotesMaterialsApiService _notesService = NotesMaterialsApiService();
  final NotificationApiService _notificationService = NotificationApiService();
  final InstructorApiService _instructorService = InstructorApiService();
  final SearchApiServiceImpl _searchService = SearchApiServiceImpl();
  final LiveClassApiService _liveClassService = LiveClassApiService();

  // ==================== AUTH METHODS ====================
  
  Future<AuthResponse> signInWithGoogle() => _authService.signInWithGoogle();
  
  Future<AuthResponse> register(RegisterRequest request) => _authService.register(request);
  
  Future<AuthResponse> login(LoginRequest request) => _authService.login(request);

  Future<ApiResponse> verifyEmail(String email, String code) => _authService.verifyEmail(email, code);

  Future<ApiResponse> resendVerification(String email) => _authService.resendVerification(email);
  
  Future<void> logout() => _authService.logout();
  
  Future<User> getMe() => _authService.getMe();
  
  Future<User> updateRole(String role) => _authService.updateRole(role);
  
  Future<bool> isAuthenticated() => _authService.isAuthenticated();

  @override
  Future<void> clearSession() async {
    // This is handled by AuthService
  }

  // ==================== CATEGORY METHODS ====================
  
  Future<ApiResponse<List<Map<String, dynamic>>>> getCategories({
    bool includeCourses = false,
    bool? isActive,
  }) => _categoryService.getCategories(includeCourses: includeCourses, isActive: isActive);

  Future<ApiResponse<Map<String, dynamic>>> getCategoryById(String id, {bool includeCourses = false}) =>
      _categoryService.getCategoryById(id, includeCourses: includeCourses);

  Future<ApiResponse<Map<String, dynamic>>> getCategoryBySlug(
    String slug, {
    bool includeCourses = false,
    int limit = 10,
    int offset = 0,
    String sortBy = 'newest',
  }) => _categoryService.getCategoryBySlug(
        slug,
        includeCourses: includeCourses,
        limit: limit,
        offset: offset,
        sortBy: sortBy,
      );

  Future<ApiResponse<Map<String, dynamic>>> getCategoryStats(String id) =>
      _categoryService.getCategoryStats(id);

  // ==================== COURSE METHODS ====================
  
  Future<ApiResponse<List<Map<String, dynamic>>>> getFeaturedCourses({int limit = 5}) =>
      _courseService.getFeaturedCourses(limit: limit);

  Future<ApiResponse<List<Map<String, dynamic>>>> getRecommendedCourses({int limit = 10}) =>
      _courseService.getRecommendedCourses(limit: limit);

  Future<ApiResponse<Map<String, dynamic>>> getCourseById(String id) => _courseService.getCourseById(id);

  Future<ApiResponse<Map<String, dynamic>>> getPublicCourses({
    int page = 1,
    int limit = 20,
    String? categoryId,
    String? search,
    String? sortBy = 'popular',
    String? level,
  }) => _courseService.getPublicCourses(
        page: page,
        limit: limit,
        categoryId: categoryId,
        search: search,
        sortBy: sortBy,
        level: level,
      );

  Future<ApiResponse<Map<String, dynamic>>> getPopularCourses({
    int limit = 10,
    int page = 1,
    String timeRange = 'week',
  }) => _courseService.getPopularCourses(limit: limit, page: page, timeRange: timeRange);

  // RENAMED: Course Service methods (for course management)
  Future<ApiResponse<Map<String, dynamic>>> getMyInstructorCourses({
    int page = 1,
    int limit = 50,
    String? status,
    String? search,
    String? sortBy = 'newest',
  }) => _courseService.getInstructorCourses(
        page: page,
        limit: limit,
        status: status,
        search: search,
        sortBy: sortBy,
      );

  // RENAMED: Course Service stats
  Future<ApiResponse<Map<String, dynamic>>> getMyInstructorStats() => _courseService.getInstructorStats();

  Future<ApiResponse<dynamic>> deleteCourse(String courseId) => _courseService.deleteCourse(courseId);

  Future<ApiResponse<Map<String, dynamic>>> updateCourseStatus(String courseId, String status) =>
      _courseService.updateCourseStatus(courseId, status);

  Future<ApiResponse<Map<String, dynamic>>> updateCourse(String courseId, Map<String, dynamic> data) =>
      _courseService.updateCourse(courseId, data);

  Future<ApiResponse<Map<String, dynamic>>> duplicateCourse(String courseId) =>
      _courseService.duplicateCourse(courseId);

  Future<ApiResponse<Map<String, dynamic>>> getCourseAnalytics({String? courseId}) =>
      _courseService.getCourseAnalytics(courseId: courseId);

  // ==================== INSTRUCTOR METHODS ====================
  
  Future<ApiResponse<List<Map<String, dynamic>>>> getTopInstructors({int limit = 10}) =>
      _instructorService.getTopInstructors(limit: limit);

  Future<ApiResponse<Map<String, dynamic>>> getInstructors({
    String? search,
    String? expertise,
    int limit = 10,
    int offset = 0,
    String sortBy = 'popular',
    String? categoryId,
  }) => _instructorService.getInstructors(
        search: search,
        expertise: expertise,
        limit: limit,
        offset: offset,
        sortBy: sortBy,
        categoryId: categoryId,
      );

  Future<ApiResponse<Map<String, dynamic>>> getInstructorById(String id) =>
      _instructorService.getInstructorById(id);

  Future<ApiResponse<Map<String, dynamic>>> toggleFollowInstructor(String instructorId) =>
      _instructorService.toggleFollowInstructor(instructorId);

  Future<ApiResponse<Map<String, dynamic>>> getFollowers(
    String instructorId, {
    int limit = 20,
    int offset = 0,
  }) => _instructorService.getFollowers(
        instructorId,
        limit: limit,
        offset: offset,
      );

  Future<ApiResponse<List<Map<String, dynamic>>>> searchInstructors(String query, {int limit = 10}) =>
      _instructorService.searchInstructors(query, limit: limit);

  // ✅ KEPT: Instructor Service methods (for instructor profile)
  Future<ApiResponse<List<Course>>> getInstructorCourses() =>
      _instructorService.getInstructorCourses();

  // ✅ KEPT: Instructor Service stats
  Future<ApiResponse<Map<String, dynamic>>> getInstructorStats() =>
      _instructorService.getInstructorStats();

  Future<ApiResponse<Map<String, dynamic>>> getInstructorAnalytics({String? courseId}) =>
      _instructorService.getInstructorAnalytics(courseId: courseId);

  Future<ApiResponse<Map<String, dynamic>>> updateInstructorProfile(Map<String, dynamic> profileData) =>
      _instructorService.updateInstructorProfile(profileData);

  Future<ApiResponse<Map<String, dynamic>>> getInstructorStudents({
    int page = 1,
    int limit = 20,
    String? search,
    String? sortBy = 'newest',
  }) => _instructorService.getInstructorStudents(
        page: page,
        limit: limit,
        search: search,
        sortBy: sortBy,
      );

  Future<ApiResponse<Map<String, dynamic>>> getInstructorEarnings({
    String? timeRange = 'month',
    String? startDate,
    String? endDate,
  }) => _instructorService.getInstructorEarnings(
        timeRange: timeRange,
        startDate: startDate,
        endDate: endDate,
      );

  // ==================== ENROLLMENT METHODS ====================
  
  Future<ApiResponse<List<Map<String, dynamic>>>> getContinueLearning({int limit = 5}) =>
      _enrollmentService.getContinueLearning(limit: limit);

  Future<ApiResponse<Map<String, dynamic>>> getMyEnrollments({
    int page = 1,
    int limit = 10,
    bool? isCompleted,
  }) => _enrollmentService.getMyEnrollments(page: page, limit: limit, isCompleted: isCompleted);

  Future<ApiResponse<Map<String, dynamic>>> getCourseProgress(String courseId) =>
      _enrollmentService.getCourseProgress(courseId);

  Future<ApiResponse<dynamic>> updateLessonProgress(String lessonId, bool isCompleted) =>
      _enrollmentService.updateLessonProgress(lessonId, isCompleted);

  Future<ApiResponse<Map<String, dynamic>>> enrollInCourse(String courseId) =>
      _enrollmentService.enrollInCourse(courseId);

  Future<ApiResponse<dynamic>> unenrollFromCourse(String courseId) =>
      _enrollmentService.unenrollFromCourse(courseId);

  Future<ApiResponse<Map<String, dynamic>>> checkEnrollmentStatus(String courseId) =>
      _enrollmentService.checkEnrollmentStatus(courseId);

  // ==================== LEARNING METHODS ====================
  
  Future<ApiResponse<List<Map<String, dynamic>>>> getCourseSections(String courseId) =>
      _learningService.getCourseSections(courseId);

  Future<ApiResponse<List<Map<String, dynamic>>>> getLessonsBySection(String sectionId) =>
      _learningService.getLessonsBySection(sectionId);

  Future<ApiResponse<Map<String, dynamic>>> getLessonVideoStream(String lessonId, {int expiresIn = 3600}) =>
      _learningService.getLessonVideoStream(lessonId, expiresIn: expiresIn);

  Future<ApiResponse<Map<String, dynamic>>> createSection(String courseId, Map<String, dynamic> data) =>
      _learningService.createSection(courseId, data);

  Future<ApiResponse<Map<String, dynamic>>> updateSection(String sectionId, Map<String, dynamic> data) =>
      _learningService.updateSection(sectionId, data);

  Future<ApiResponse<dynamic>> deleteSection(String sectionId) =>
      _learningService.deleteSection(sectionId);

  Future<ApiResponse<Map<String, dynamic>>> createLesson(String sectionId, Map<String, dynamic> data) =>
      _learningService.createLesson(sectionId, data);

  Future<ApiResponse<Map<String, dynamic>>> updateLesson(String lessonId, Map<String, dynamic> data) =>
      _learningService.updateLesson(lessonId, data);

  Future<ApiResponse<dynamic>> deleteLesson(String lessonId) =>
      _learningService.deleteLesson(lessonId);

  Future<ApiResponse<Map<String, dynamic>>> uploadLessonVideo(String lessonId, File videoFile) =>
      _learningService.uploadLessonVideo(lessonId, videoFile);

  Future<ApiResponse<dynamic>> deleteLessonVideo(String lessonId) =>
      _learningService.deleteLessonVideo(lessonId);

  Future<ApiResponse<Map<String, dynamic>>> uploadThumbnail(File imageFile) =>
      _learningService.uploadThumbnail(imageFile);

  // ==================== REVIEW METHODS ====================
  
  Future<ApiResponse<Map<String, dynamic>>> createReview({
    required String courseId,
    required int rating,
    String? comment,
  }) => _reviewService.createReview(courseId: courseId, rating: rating, comment: comment);

  Future<ApiResponse<Map<String, dynamic>>> updateReview({
    required String reviewId,
    int? rating,
    String? comment,
  }) => _reviewService.updateReview(reviewId: reviewId, rating: rating, comment: comment);

  Future<ApiResponse<dynamic>> deleteReview(String reviewId) => _reviewService.deleteReview(reviewId);

  Future<ApiResponse<Map<String, dynamic>>> getCourseReviews({
    required String courseId,
    int page = 1,
    int limit = 10,
  }) => _reviewService.getCourseReviews(courseId: courseId, page: page, limit: limit);

  Future<ApiResponse<Map<String, dynamic>>> getMyReview(String courseId) =>
      _reviewService.getMyReview(courseId);

  // ==================== NOTES & MATERIALS METHODS ====================
  
  Future<ApiResponse<List<Map<String, dynamic>>>> getCourseNotes(String courseId) =>
      _notesService.getCourseNotes(courseId);

  Future<ApiResponse<Map<String, dynamic>>> addCourseNote(String courseId, String content, String? lessonId) =>
      _notesService.addCourseNote(courseId, content, lessonId);

  Future<ApiResponse<dynamic>> deleteCourseNote(String noteId) => _notesService.deleteCourseNote(noteId);

  Future<ApiResponse<List<Map<String, dynamic>>>> getCourseMaterials(String courseId) =>
      _notesService.getCourseMaterials(courseId);

  // ==================== NOTIFICATION METHODS ====================
  
  Future<ApiResponse<Map<String, dynamic>>> getNotifications({int page = 1, int limit = 20}) =>
      _notificationService.getNotifications(page: page, limit: limit);

  Future<ApiResponse<dynamic>> markNotificationAsRead(String id) =>
      _notificationService.markNotificationAsRead(id);

  Future<ApiResponse<dynamic>> markAllNotificationsAsRead() =>
      _notificationService.markAllNotificationsAsRead();

  Future<ApiResponse<dynamic>> deleteNotification(String id) => _notificationService.deleteNotification(id);

  Future<ApiResponse<Map<String, dynamic>>> getUnreadCount() => _notificationService.getUnreadCount();

  // ==================== SEARCH METHODS ====================
  
  Future<ApiResponse<List<SearchSuggestion>>> getSuggestions(String query) =>
      _searchService.getSuggestions(query);

  Future<ApiResponse<List<String>>> getRecentSearches() => _searchService.getRecentSearches();

  Future<ApiResponse<dynamic>> saveRecentSearch(String query) => _searchService.saveRecentSearch(query);

  Future<ApiResponse<dynamic>> clearRecentSearches() => _searchService.clearRecentSearches();

  Future<ApiResponse<SearchResults>> search({
    required String query,
    String type = 'all',
    int page = 1,
    int limit = 20,
    String? category,
    String? level,
    String? price,
    String sortBy = 'relevance',
  }) => _searchService.search(
        query: query,
        type: type,
        page: page,
        limit: limit,
        category: category,
        level: level,
        price: price,
        sortBy: sortBy,
      );

  Future<ApiResponse<SearchResults>> searchByType({
    required String type,
    required String query,
    int page = 1,
    int limit = 20,
    String? category,
    String? level,
    String? price,
    String sortBy = 'relevance',
  }) => _searchService.searchByType(
        type: type,
        query: query,
        page: page,
        limit: limit,
        category: category,
        level: level,
        price: price,
        sortBy: sortBy,
      );

  Future<ApiResponse<TrendingData>> getTrending() => _searchService.getTrending();

  // ==================== LIVE CLASS METHODS ====================

  // INSTRUCTOR LIVE CLASS METHODS
  Future<ApiResponse<List<LiveClass>>> getInstructorLiveClasses() =>
      _liveClassService.getInstructorLiveClasses();

  Future<ApiResponse<LiveClass>> createLiveClass(Map<String, dynamic> liveClassData) =>
      _liveClassService.createLiveClass(liveClassData);

  Future<ApiResponse<LiveClass>> updateLiveClass(String id, Map<String, dynamic> liveClassData) =>
      _liveClassService.updateLiveClass(id, liveClassData);

  Future<ApiResponse<LiveClass>> startLiveClass(String id) =>
      _liveClassService.startLiveClass(id);

  Future<ApiResponse<LiveClass>> endLiveClass(String id) =>
      _liveClassService.endLiveClass(id);

  Future<ApiResponse<LiveClass>> cancelLiveClass(String id) =>
      _liveClassService.cancelLiveClass(id);

  // STUDENT LIVE CLASS METHODS
  Future<ApiResponse<Map<String, dynamic>>> getAllStudentLiveClasses() =>
      _liveClassService.getAllStudentLiveClasses();

  Future<ApiResponse<List<LiveClass>>> getStudentLiveClasses() =>
      _liveClassService.getStudentLiveClasses();

  Future<ApiResponse<List<LiveClass>>> getUpcomingStudentLiveClasses() =>
      _liveClassService.getUpcomingStudentLiveClasses();

  Future<ApiResponse<List<LiveClass>>> getCurrentStudentLiveClasses() =>
      _liveClassService.getCurrentStudentLiveClasses();

  Future<ApiResponse<Map<String, dynamic>>> getStudentLiveClassStats() =>
      _liveClassService.getStudentLiveClassStats();

  Future<ApiResponse<Map<String, dynamic>>> joinLiveClass(String id) =>
      _liveClassService.joinLiveClass(id);

  // SHARED LIVE CLASS METHODS
  Future<ApiResponse<List<LiveClass>>> getCourseLiveClasses(String courseId) =>
      _liveClassService.getCourseLiveClasses(courseId);

  Future<ApiResponse<LiveClass>> getLiveClassById(String id) =>
      _liveClassService.getLiveClassById(id);

  // HELPER LIVE CLASS METHODS
  Future<ApiResponse<List<LiveClass>>> getLiveClassesByStatus(String status) =>
      _liveClassService.getLiveClassesByStatus(status);

  Future<ApiResponse<List<LiveClass>>> getUpcomingLiveClasses({int limit = 20}) =>
      _liveClassService.getUpcomingLiveClasses(limit: limit);

  Future<bool> isClassJoinable(String classId) =>
      _liveClassService.isClassJoinable(classId);

  Future<ApiResponse<Map<String, dynamic>>> getLiveClassRoomInfo(String classId) =>
      _liveClassService.getLiveClassRoomInfo(classId);

  // ==================== DEPRECATED METHODS ====================

  @Deprecated('Use getInstructorLiveClasses() or getCourseLiveClasses() instead')
  Future<ApiResponse<Map<String, dynamic>>> getLiveClasses({
    String? status,
    int page = 1,
    int limit = 20,
    String? categoryId,
    String? search,
    String? sortBy = 'scheduledTime',
    bool ascending = true,
  }) async {
    final result = await getInstructorLiveClasses();
    if (result.success && result.data != null) {
      var classes = result.data!;
      if (status != null && status.isNotEmpty) {
        classes = classes.where((c) => c.status == status).toList();
      }
      final start = (page - 1) * limit;
      final end = start + limit;
      final paginated = classes.length > start ? classes.sublist(start, end.clamp(0, classes.length)) : [];
      
      return ApiResponse.success({
        'data': paginated,
        'pagination': {
          'page': page,
          'limit': limit,
          'total': classes.length,
          'totalPages': (classes.length / limit).ceil(),
        },
        'stats': {},
      }, message: result.message);
    }
    return ApiResponse.error(result.error ?? 'Failed to fetch live classes');
  }

  @Deprecated('Follow functionality not implemented in backend')
  Future<ApiResponse<Map<String, dynamic>>> followLiveClass(String classId) =>
      _liveClassService.followLiveClass(classId);

  @Deprecated('Unfollow functionality not implemented in backend')
  Future<ApiResponse<Map<String, dynamic>>> unfollowLiveClass(String classId) =>
      _liveClassService.unfollowLiveClass(classId);

  @Deprecated('Toggle follow functionality not implemented in backend')
  Future<ApiResponse<Map<String, dynamic>>> toggleFollowLiveClass(String classId) =>
      _liveClassService.toggleFollowLiveClass(classId);

  @Deprecated('Follow status check not implemented in backend')
  Future<ApiResponse<Map<String, dynamic>>> isFollowingLiveClass(String classId) =>
      _liveClassService.isFollowingLiveClass(classId);

  @Deprecated('Use getStudentLiveClassStats() instead')
  Future<ApiResponse<Map<String, dynamic>>> getLiveClassStats() =>
      _liveClassService.getStudentLiveClassStats();
}