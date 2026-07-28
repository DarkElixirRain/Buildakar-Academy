import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'providers/search_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/live_class_provider.dart';
import 'providers/instructor_dashboard_provider.dart';
import 'providers/instructor_course_provider.dart';
import 'routes/app_routes.dart';
import 'theme/stitch_theme.dart';
import 'services/base_api_service.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
}

Future<void> main() async {
  await runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      if (!kIsWeb) {
        FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

        final settings = await FirebaseMessaging.instance.requestPermission(
          alert: true, badge: true, sound: true,
        );

        final token = await FirebaseMessaging.instance.getToken();

        FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {});
      }
    } catch (e) {}

    runApp(const LearnHubApp());
  }, (error, stackTrace) {});
}

class LearnHubApp extends StatelessWidget {
  const LearnHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProxyProvider<AuthProvider, LiveClassProvider>(
          create: (context) => LiveClassProvider(authProvider: context.read<AuthProvider>()),
          update: (context, authProvider, previous) =>
              previous ?? LiveClassProvider(authProvider: authProvider),
        ),
        ChangeNotifierProxyProvider<AuthProvider, SearchProvider>(
          create: (context) => SearchProvider(authProvider: context.read<AuthProvider>()),
          update: (context, authProvider, previous) =>
              previous ?? SearchProvider(authProvider: authProvider),
        ),
        ChangeNotifierProxyProvider<AuthProvider, InstructorDashboardProvider>(
          create: (context) => InstructorDashboardProvider(),
          update: (context, authProvider, previous) => previous ?? InstructorDashboardProvider(),
        ),
        ChangeNotifierProxyProvider<AuthProvider, InstructorCourseProvider>(
          create: (context) => InstructorCourseProvider(),
          update: (context, authProvider, previous) => previous ?? InstructorCourseProvider(),
        ),
      ],
      child: const MyApp(),
    );
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  bool _lastKnownAuthState = false;

  @override
  void initState() {
    super.initState();

    if (!kIsWeb) {
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {});
      FirebaseMessaging.onMessageOpenedApp.listen((message) {});
      FirebaseMessaging.instance.getInitialMessage().then((message) {});
    }

    BaseApiService.onSessionExpired = () {
      final context = _navigatorKey.currentContext;
      if (context == null) return;
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      authProvider.forceLogout();
    };

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      authProvider.addListener(_onAuthChanged);
    });
  }

  void _onAuthChanged() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final isAuth = authProvider.isAuthenticated;

    if (_lastKnownAuthState && !isAuth) {
      _navigatorKey.currentState?.pushNamedAndRemoveUntil('/login', (route) => false);
    }
    _lastKnownAuthState = isAuth;
  }

  @override
  void dispose() {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      authProvider.removeListener(_onAuthChanged);
    } catch (_) {}
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final isDarkMode = themeProvider.isDarkMode;
        final brightness = isDarkMode ? Brightness.dark : Brightness.light;

        return MaterialApp(
          title: 'BuildAcad',
          debugShowCheckedModeBanner: false,
          navigatorKey: _navigatorKey,

          theme: StitchTheme.build(brightness: Brightness.light),
          darkTheme: StitchTheme.build(brightness: Brightness.dark),
          themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,

          initialRoute: AppRoutes.splash,
          onGenerateRoute: AppRoutes.generateRoute,
        );
      },
    );
  }
}
