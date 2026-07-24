import 'package:flutter/material.dart';
import 'package:buildacad/screens/splash/splash_screen.dart';
import 'package:buildacad/screens/auth/login_screen.dart';
import 'package:buildacad/screens/auth/signup_screen.dart';
import 'package:buildacad/screens/auth/verify_email_screen.dart';
import 'package:buildacad/screens/auth/forgot_password_screen.dart';
import 'package:buildacad/screens/home/home_screen.dart';
import 'package:buildacad/screens/course/course_detail_screen.dart';
import 'package:buildacad/screens/course/course_learning.dart';
import 'package:buildacad/screens/instructor/instructor_profile_screen.dart';
import 'package:buildacad/screens/instructor/instructor_dashboard_screens.dart';
import 'package:buildacad/screens/live/live_screen.dart';
import 'package:buildacad/screens/live/create_live_class_screen.dart';
import 'package:buildacad/screens/live/live_class_room_screen.dart';
import 'package:buildacad/screens/common/notification_screen.dart';
import 'package:buildacad/screens/common/my_learning_screen.dart';
import 'package:buildacad/screens/common/categories_screen.dart';
import 'package:buildacad/screens/common/category_detail_screen.dart';
import 'package:buildacad/screens/settings/settings_screen.dart';

class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String verifyEmail = '/verify-email';
  static const String forgotPassword = '/forgot-password';
  static const String home = '/home';
  static const String courseDetail = '/course-detail';
  static const String courseLearning = '/course-learning';
  static const String instructorProfile = '/instructor-profile';
  static const String instructorDashboard = '/instructor-dashboard';
  static const String liveClasses = '/live-classes';
  static const String createLiveClass = '/create-live-class';
  static const String liveClassRoom = '/live-class-room';
  static const String notifications = '/notifications';
  static const String myLearning = '/my-learning';
  static const String categories = '/categories';
  static const String categoryDetail = '/category-detail';
  static const String settings = '/settings';

  static const String argCourseId = 'courseId';
  static const String argInstructorId = 'instructorId';
  static const String argCategoryName = 'categoryName';

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
      case courseDetail:
        final args = settings.arguments as Map<String, dynamic>?;
        final courseId = args?[argCourseId] as String? ?? '';
        return MaterialPageRoute(builder: (_) => CourseDetailScreen(courseId: courseId));
      case courseLearning:
        final args = settings.arguments as Map<String, dynamic>?;
        final courseId = args?[argCourseId] as String? ?? '';
        return MaterialPageRoute(builder: (_) => CourseLearningScreen(courseId: courseId));
      case instructorProfile:
        return MaterialPageRoute(builder: (_) => const InstructorProfileScreen());
      case instructorDashboard:
        return MaterialPageRoute(builder: (_) => const InstructorDashboardScreen());
      case liveClasses:
        return MaterialPageRoute(builder: (_) => const LiveScreen());
      case createLiveClass:
        return MaterialPageRoute(builder: (_) => const CreateLiveClassScreen());
      case liveClassRoom:
        final args = settings.arguments as Map<String, dynamic>?;
        final classId = args?['classId'] as String? ?? '';
        return MaterialPageRoute(builder: (_) => LiveClassRoomScreen(classId: classId));
      case notifications:
        return MaterialPageRoute(builder: (_) => const NotificationScreen());
      case myLearning:
        return MaterialPageRoute(builder: (_) => const MyLearningScreen());
      case categories:
        return MaterialPageRoute(builder: (_) => const CategoriesScreen());
      case categoryDetail:
        final args = settings.arguments as Map<String, dynamic>?;
        final name = args?[argCategoryName] as String? ?? '';
        return MaterialPageRoute(builder: (_) => CategoryDetailScreen(categoryName: name));
      case AppRoutes.settings:
        return MaterialPageRoute(builder: (_) => const SettingsScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }
}
