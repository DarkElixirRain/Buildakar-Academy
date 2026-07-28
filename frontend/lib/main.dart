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
  Timer? _tokenRefreshTimer;

  @override
  void initState() {
    super.initState();

    if (!kIsWeb) {
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {});
      FirebaseMessaging.onMessageOpenedApp.listen((message) {});
      FirebaseMessaging.instance.getInitialMessage().then((message) {});
    }

    // Setup session expiry handler - only called when refresh token is truly invalid
    BaseApiService.onSessionExpired = _handleSessionExpired;

    // Start automatic token refresh timer
    _startTokenRefreshTimer();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      authProvider.addListener(_onAuthChanged);
    });
  }

  void _startTokenRefreshTimer() {
    // Refresh token every 4 minutes (proactively)
    _tokenRefreshTimer = Timer.periodic(const Duration(minutes: 4), (timer) async {
      try {
        final baseApiService = BaseApiService();
        final token = await baseApiService.getToken();
        final expiryStr = await baseApiService.getTokenExpiry();
        
        if (token != null && expiryStr != null) {
          final expiry = DateTime.parse(expiryStr);
          final timeUntilExpiry = expiry.difference(DateTime.now());
          
          // Only refresh if token expires in less than 5 minutes
          if (timeUntilExpiry.inMinutes < 5) {
            print('🔄 Proactive token refresh from timer');
            await baseApiService.refreshAccessToken();
          }
        }
      } catch (e) {
        // Silent fail - don't disrupt user
        print('⚠️ Proactive token refresh failed: $e');
      }
    });
  }

  void _handleSessionExpired() {
    print('🔄 Session expired - clearing session...');
    
    // This should only be called when the refresh token is truly invalid
    // Show a dialog asking user to login again
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final context = _navigatorKey.currentContext;
      if (context == null) return;

      // Show dialog before logging out
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text('Session Expired'),
          content: const Text('Your session has expired. Please login again to continue.'),
          actions: [
            TextButton(
              onPressed: () {
                // Clear session and navigate to login
                final authProvider = Provider.of<AuthProvider>(context, listen: false);
                authProvider.clearSession();
                Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
              },
              child: const Text('Login Again'),
            ),
          ],
        ),
      );
    });
  }

  void _onAuthChanged() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final isAuth = authProvider.isAuthenticated;

    // Only handle manual logout or login changes
    if (_lastKnownAuthState && !isAuth) {
      // User logged out manually - navigate to login
      _navigatorKey.currentState?.pushNamedAndRemoveUntil(
        '/login', 
        (route) => false,
      );
    }
    _lastKnownAuthState = isAuth;
  }

  @override
  void dispose() {
    _tokenRefreshTimer?.cancel();
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