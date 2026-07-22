import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/instructor_dashboard_provider.dart';
import '../../providers/instructor_course_provider.dart';
import 'dashboard_home.dart';
import 'instructor_courses_screen.dart';
import 'instructor_live_classes_screen.dart';
import 'instructor_students_screen.dart';
import 'instructor_analytics_screen.dart';
import 'instructor_earnings_screen.dart';
import 'instructor_reviews_screen.dart';
import 'instructor_profile_screen.dart';

final ValueNotifier<String?> _currentSubScreenNotifier = ValueNotifier(null);

void showHome() => _currentSubScreenNotifier.value = null;
void setSubScreen(String screen) => _currentSubScreenNotifier.value = screen;

class InstructorDashboardScreen extends StatefulWidget {
  const InstructorDashboardScreen({super.key});

  @override
  State<InstructorDashboardScreen> createState() => _InstructorDashboardScreenState();
}

class _InstructorDashboardScreenState extends State<InstructorDashboardScreen> {
  @override
  void initState() {
    super.initState();
    _currentSubScreenNotifier.value = null;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<InstructorDashboardProvider>().loadAll();
      context.read<InstructorCourseProvider>().loadCourses();
    });
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String?>(
      valueListenable: _currentSubScreenNotifier,
      builder: (context, screen, _) {
        Widget child;
        switch (screen) {
          case null:
            child = const DashboardHome();
          case 'courses':
            child = const InstructorCoursesScreen();
          case 'live':
            child = const InstructorLiveClassesScreen();
          case 'students':
            child = const InstructorStudentsScreen();
          case 'analytics':
            child = const InstructorAnalyticsScreen();
          case 'earnings':
            child = const InstructorEarningsScreen();
          case 'reviews':
            child = const InstructorReviewsScreen();
          case 'profile':
            child = const InstructorProfileScreen();
          default:
            child = const DashboardHome();
        }

        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, _) {
            if (!didPop) {
              _currentSubScreenNotifier.value = null;
            }
          },
          child: child,
        );
      },
    );
  }
}
