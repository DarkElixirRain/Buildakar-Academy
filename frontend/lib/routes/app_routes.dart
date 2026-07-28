import 'package:flutter/material.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/signup_screen.dart';
import '../screens/auth/verify_email_screen.dart';
import '../screens/auth/forgot_password_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/splash/splash_screen.dart';
import '../screens/instructor/instructor_profile_screen.dart';
import '../screens/course/course_detail/course_detail_screen.dart';
import '../screens/my_learning/my_learning_screen.dart';
import '../screens/categories/categories_screen.dart';
import '../screens/category/category_detail_screen.dart';
import '../screens/explore/explore_screen.dart';
import '../screens/live/live_screen.dart';
import '../screens/instructor/instructor_screen.dart';

class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String verifyEmail = '/verify-email';
  static const String forgotPassword = '/forgot-password';
  static const String home = '/home';
  static const String instructor = '/instructor';
  static const String course = '/course';
  static const String courseDetail = '/course-detail';
  static const String myLearning = '/my-learning';
  static const String categories = '/categories';
  static const String category = '/category';
  static const String browse = '/browse';
  static const String instructorProfile = '/instructor-profile';
  static const String liveClass = '/live-class';
  static const String instructors = '/instructors';

  static const String argInstructorId = 'instructorId';
  static const String argCourseId = 'courseId';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case signup:
        return MaterialPageRoute(builder: (_) => const SignupScreen());
      case verifyEmail:
        final email = settings.arguments as String? ?? '';
        return MaterialPageRoute(builder: (_) => VerifyEmailScreen(email: email));
      case forgotPassword:
        return MaterialPageRoute(builder: (_) => const ForgotPasswordScreen());
      case home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case instructor:
      case instructorProfile:
        final args = settings.arguments;
        final instructorId = (args is Map<String, dynamic>)
            ? (args['instructorId'] as String? ?? '')
            : (args as String? ?? '');
        return MaterialPageRoute(
          builder: (_) => InstructorProfileScreen(instructorId: instructorId),
        );
      case course:
      case courseDetail:
        final args = settings.arguments;
        final courseId = (args is Map<String, dynamic>)
            ? (args['courseId'] as String? ?? '')
            : (args as String? ?? '');
        return MaterialPageRoute(
          builder: (_) => CourseDetailScreen(courseId: courseId),
        );
      case myLearning:
        return MaterialPageRoute(builder: (_) => const MyLearningScreen());
      case categories:
        return MaterialPageRoute(builder: (_) => const CategoriesScreen());
      case category:
        final args = settings.arguments;
        final categoryId = (args is Map<String, dynamic>)
            ? (args['categoryId'] as String? ?? '')
            : (args as String? ?? '');
        return MaterialPageRoute(
          builder: (_) => CategoryDetailScreen(
            categoryId: categoryId,
            categorySlug: categoryId,
            categoryName: categoryId,
          ),
        );
      case browse:
        return MaterialPageRoute(builder: (_) => const ExploreScreen());
      case liveClass:
        return MaterialPageRoute(builder: (_) => const LiveScreen());
      case instructors:
        return MaterialPageRoute(builder: (_) => const InstructorsScreen());
      default:
        return MaterialPageRoute(
          builder: (context) => Scaffold(
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.route, size: 64, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    Text(
                      'Page Not Found',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'We could not find the page you\'re looking for.',
                      style: TextStyle(color: Colors.grey[600]),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () => Navigator.of(context).pushNamedAndRemoveUntil(
                        home, (route) => false,
                      ),
                      icon: const Icon(Icons.home),
                      label: const Text('Go Home'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
    }
  }
}