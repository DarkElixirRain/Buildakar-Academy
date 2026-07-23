// lib/routes/app_routes.dart

import 'package:flutter/material.dart';
import 'package:buildacad/models/course_model.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/signup_screen.dart';
import '../screens/auth/forgot_password_screen.dart';
import '../screens/auth/verify_email_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/notifications/notification_screen.dart';
import '../screens/explore/explore_screen.dart';
import '../screens/live/live_screen.dart';
import '../screens/course/course_detail/course_detail_screen.dart';
import '../screens/course/course_learning/course_learning.dart';
import '../screens/categories/categories_screen.dart';
import '../screens/my_learning/my_learning_screen.dart';
import '../screens/splash/splash_screen.dart';

class AppRoutes {
  // Route names
  static const String splash = '/';
  static const String home = '/home';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String verifyEmail = '/verify-email';
  static const String forgotPassword = '/forgot-password';
  static const String notifications = '/notifications';
  static const String explore = '/explore';
  static const String live = '/live';
  static const String browse = '/browse';
  static const String myLearning = '/my-learning';
  static const String recommended = '/recommended';
  static const String popular = '/popular';
  static const String instructors = '/instructors';
  static const String categories = '/categories';
  static const String category = '/category';
  static const String instructor = '/instructor';
  static const String course = '/course';
  static const String courseLearning = '/course-learning';
  static const String liveClass = '/live-class';

  // Route arguments keys
  static const String argCourseId = 'courseId';
  static const String argCategoryId = 'categoryId';
  static const String argInstructorId = 'instructorId';
  static const String argClassId = 'classId';
  static const String argCourse = 'course';
  static const String argTab = 'tab';
  static const String argFilter = 'filter';

  // Helper to safely extract string arguments
  static String getStringArg(BuildContext context, String key) {
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map<String, dynamic>) {
      final value = args[key];
      if (value != null) return value.toString();
    }
    return '';
  }

  // Helper to safely extract Course object
  static Course? getCourseArg(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map<String, dynamic>) {
      final course = args[argCourse];
      if (course is Course) return course;
    }
    return null;
  }

  // Route generator
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      
      case home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      
      case signup:
        return MaterialPageRoute(builder: (_) => const SignupScreen());
      
      case verifyEmail:
        final email = settings.arguments as String? ?? '';
        return MaterialPageRoute(
          builder: (_) => VerifyEmailScreen(email: email),
        );
      
      case forgotPassword:
        return MaterialPageRoute(builder: (_) => const ForgotPasswordScreen());
      
      case notifications:
        return MaterialPageRoute(builder: (_) => const NotificationScreen());
      
      case explore:
        return MaterialPageRoute(builder: (_) => const ExploreScreen());
      
      case live:
        return MaterialPageRoute(builder: (_) => const LiveScreen());
      
      case browse:
        return MaterialPageRoute(
          builder: (_) => const PlaceholderScreen(
            title: 'Browse Courses',
            icon: Icons.search,
          ),
        );
      
      case myLearning:
        return MaterialPageRoute(builder: (_) => const MyLearningScreen());
      
      case recommended:
        return MaterialPageRoute(
          builder: (_) => const ExploreScreen(initialTab: 1), // Courses tab
        );
      
      case popular:
        return MaterialPageRoute(
          builder: (_) => const ExploreScreen(initialTab: 1), // Courses tab
        );
      
      case instructors:
        return MaterialPageRoute(
          builder: (_) => const ExploreScreen(initialTab: 2), // Instructors tab
        );
      
      case categories:
        return MaterialPageRoute(builder: (_) => const CategoriesScreen());
      
      case category:
        final categoryId = settings.arguments as String? ?? '';
        return MaterialPageRoute(
          builder: (_) => PlaceholderScreen(
            title: 'Category',
            icon: Icons.category_outlined,
            subtitle: 'Category ID: $categoryId',
          ),
        );
      
      case instructor:
        final instructorId = settings.arguments as String? ?? '';
        return MaterialPageRoute(
          builder: (_) => PlaceholderScreen(
            title: 'Instructor Profile',
            icon: Icons.person_outline,
            subtitle: 'Instructor ID: $instructorId',
          ),
        );
      
      case course:
        final courseId = settings.arguments as String? ?? '';
        return MaterialPageRoute(
          builder: (_) => CourseDetailScreen(courseId: courseId),
        );
      
      case courseLearning:
        final args = settings.arguments as Map<String, dynamic>?;
        final courseId = args?[argCourseId] as String? ?? '';
        final course = args?[argCourse] as Course?;
        return MaterialPageRoute(
          builder: (_) => CourseLearningPage(
            courseId: courseId,
            course: course ??
                Course(
                  id: courseId,
                  title: 'Course',
                  description: '',
                  thumbnail: '',
                  price: 0,
                  level: 'Beginner',
                  language: 'English',
                  rating: 0,
                  studentsCount: 0,
                  createdAt: DateTime.now(),
                  updatedAt: DateTime.now(),
                  instructorId: '',
                  categoryId: '',
                  instructor: Instructor(
                    id: '',
                    firstName: 'Instructor',
                    lastName: '',
                    email: '',
                    photo: '',
                    bio: '',
                    rating: 0,
                    studentsCount: 0,
                    coursesCount: 0,
                  ),
                  category: CourseCategory(
                    id: '',
                    name: 'General',
                    slug: 'general',
                  ),
                  sections: const [],
                  reviews: const [],
                  studyMaterials: const [],
                  whatYouWillLearn: const [],
                  requirements: const [],
                  learningObjectives: const [],
                  reviewsCount: 0,
                ),
          ),
        );
      
      case liveClass:
        final classId = settings.arguments as String? ?? '';
        return MaterialPageRoute(
          builder: (_) => PlaceholderScreen(
            title: 'Live Class',
            icon: Icons.live_tv_outlined,
            subtitle: 'Class ID: $classId',
          ),
        );
      
      default:
        return _errorRoute(settings);
    }
  }

  static Route<dynamic> _errorRoute(settings) {
    return MaterialPageRoute(
      builder: (context) => Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red.shade300,
              ),
              const SizedBox(height: 16),
              const Text(
                'Page not found',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'The page "${settings.name}" does not exist.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, AppRoutes.home);
                },
                child: const Text('Go to Home'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Navigation helper methods
  static void navigateToHome(BuildContext context) {
    Navigator.pushReplacementNamed(context, home);
  }

  static void navigateToLogin(BuildContext context) {
    Navigator.pushReplacementNamed(context, login);
  }

  static void navigateToExplore(
    BuildContext context, {
    int? tabIndex,
    String? filter,
  }) {
    final args = <String, dynamic>{};
    if (tabIndex != null) args[argTab] = tabIndex;
    if (filter != null) args[argFilter] = filter;
    
    Navigator.pushNamed(
      context,
      explore,
      arguments: args.isNotEmpty ? args : null,
    );
  }

  static void navigateToRecommended(BuildContext context) {
    Navigator.pushNamed(context, recommended);
  }

  static void navigateToPopular(BuildContext context) {
    Navigator.pushNamed(context, popular);
  }

  static void navigateToInstructorsList(BuildContext context) {
    Navigator.pushNamed(context, instructors);
  }

  static void navigateToCourse(
    BuildContext context,
    String courseId, {
    Course? course,
  }) {
    Navigator.pushNamed(
      context,
      course as String,
      arguments: {
        argCourseId: courseId,
        if (course != null) argCourse: course,
      },
    );
  }

  static void navigateToMyLearning(BuildContext context) {
    Navigator.pushNamed(context, myLearning);
  }

  static void navigateToInstructorProfile(
    BuildContext context,
    String instructorId,
  ) {
    Navigator.pushNamed(context, instructor, arguments: instructorId);
  }

  static void navigateToCategory(
    BuildContext context,
    String categoryId,
  ) {
    Navigator.pushNamed(context, category, arguments: categoryId);
  }

  static void navigateToLiveClass(
    BuildContext context,
    String classId,
  ) {
    Navigator.pushNamed(context, liveClass, arguments: classId);
  }
}

// ============================================
// PLACEHOLDER SCREEN WIDGET
// ============================================

/// Reusable placeholder screen for screens that are not yet implemented
class PlaceholderScreen extends StatelessWidget {
  final String title;
  final IconData icon;
  final String? subtitle;

  const PlaceholderScreen({
    super.key,
    required this.title,
    required this.icon,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = theme.colorScheme.onSurface;
    final secondaryColor = textColor.withValues(alpha: 0.6);

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: secondaryColor),
            const SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                style: TextStyle(
                  fontSize: 16,
                  color: secondaryColor,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: 8),
            Text(
              'Coming Soon! 🚀',
              style: TextStyle(
                fontSize: 16,
                color: secondaryColor,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(Icons.arrow_back),
              label: const Text('Go Back'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}