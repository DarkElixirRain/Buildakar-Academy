// lib/main.dart

import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'constants/colors.dart';
import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'providers/search_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/live_class_provider.dart'; // Add this import
import 'routes/app_routes.dart';

/// Background message handler
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  debugPrint("📩 Background Notification");
  debugPrint("Title: ${message.notification?.title}");
  debugPrint("Body : ${message.notification?.body}");
  debugPrint("Data : ${message.data}");
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await runZonedGuarded(() async {
    try {
      /// Initialize Firebase
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      debugPrint("✅ Firebase initialized");

      /// Only initialize Firebase Messaging for non-web platforms
      if (!kIsWeb) {
        /// Register background handler
        FirebaseMessaging.onBackgroundMessage(
          firebaseMessagingBackgroundHandler,
        );

        /// Request notification permission
        final settings = await FirebaseMessaging.instance.requestPermission(
          alert: true,
          badge: true,
          sound: true,
        );

        debugPrint(
          "🔔 Notification Permission: ${settings.authorizationStatus}",
        );

        /// Get FCM Token
        final token = await FirebaseMessaging.instance.getToken();

        debugPrint("=================================");
        debugPrint("📱 FCM TOKEN");
        debugPrint(token);
        debugPrint("=================================");

        /// Listen for token refresh
        FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
          debugPrint("🔄 New FCM Token:");
          debugPrint(newToken);

          /// TODO:
          /// Upload the new token to your backend
        });
      } else {
        debugPrint("🌐 Running on Web - Firebase Messaging skipped");
      }
    } catch (e, stackTrace) {
      debugPrint("❌ Firebase Initialization Error");
      debugPrint(e.toString());
      debugPrint(stackTrace.toString());
    }

    runApp(const LearnHubApp());
  }, (error, stackTrace) {
    debugPrint('Unhandled zone error: $error');
    debugPrint(stackTrace.toString());
  });
}

class LearnHubApp extends StatelessWidget {
  const LearnHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => ThemeProvider(),
        ),
        ChangeNotifierProxyProvider<AuthProvider, LiveClassProvider>(
          create: (context) => LiveClassProvider(
            authProvider: context.read<AuthProvider>(),
          ),
          update: (context, authProvider, previous) =>
              previous ??
              LiveClassProvider(
                authProvider: authProvider,
              ),
        ),
        ChangeNotifierProxyProvider<AuthProvider, SearchProvider>(
          create: (context) => SearchProvider(
            authProvider: context.read<AuthProvider>(),
          ),
          update: (context, authProvider, previous) =>
              previous ??
              SearchProvider(
                authProvider: authProvider,
              ),
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
  @override
  void initState() {
    super.initState();

    /// Only initialize Firebase Messaging for non-web platforms
    if (!kIsWeb) {
      /// Foreground notification
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        debugPrint("📩 Foreground Notification");

        debugPrint("Title: ${message.notification?.title}");
        debugPrint("Body : ${message.notification?.body}");
        debugPrint("Data : ${message.data}");

        /// Later we'll show a local notification here.
      });

      /// User tapped notification while app was in background
      FirebaseMessaging.onMessageOpenedApp.listen((message) {
        debugPrint("👆 Notification Clicked");

        debugPrint(message.data.toString());

        /// TODO:
        /// Navigate to a specific screen
      });

      /// App opened from terminated state
      FirebaseMessaging.instance.getInitialMessage().then((message) {
        if (message != null) {
          debugPrint("🚀 App Opened From Notification");

          debugPrint(message.data.toString());

          /// TODO:
          /// Navigate to the correct page
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Use Consumer to listen to ThemeProvider changes
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final isDarkMode = themeProvider.isDarkMode;
        final brightness = isDarkMode ? Brightness.dark : Brightness.light;

        return MaterialApp(
          title: 'LearnHub',
          debugShowCheckedModeBanner: false,

          theme: ThemeData(
            brightness: brightness,
            primaryColor: AppColors.getPrimaryColor(brightness),
            scaffoldBackgroundColor: AppColors.getBackgroundColor(brightness),
            colorScheme: ColorScheme(
              brightness: brightness,
              primary: AppColors.getPrimaryColor(brightness),
              onPrimary: Colors.white,
              secondary: AppColors.getPrimaryLightColor(brightness),
              onSecondary: Colors.white,
              error: AppColors.getErrorColor(brightness),
              onError: Colors.white,
              surface: AppColors.getBackgroundElementColor(brightness),
              onSurface: AppColors.getTextColor(brightness),
            ),
            fontFamily: 'Inter',
            appBarTheme: AppBarTheme(
              backgroundColor: AppColors.getBackgroundElementColor(brightness),
              foregroundColor: AppColors.getTextColor(brightness),
              elevation: 0,
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.getPrimaryColor(brightness),
                foregroundColor: Colors.white,
              ),
            ),
            cardTheme: CardThemeData(
              color: AppColors.getBackgroundElementColor(brightness),
              elevation: 2,
            ),
            dialogTheme: DialogThemeData(
              backgroundColor: AppColors.getBackgroundElementColor(brightness),
              titleTextStyle: TextStyle(
                color: AppColors.getTextColor(brightness),
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              contentTextStyle: TextStyle(
                color: AppColors.getTextColor(brightness),
                fontSize: 16,
              ),
            ),
            dividerTheme: DividerThemeData(
              color: AppColors.getBackgroundSelectedColor(brightness),
              thickness: 1,
            ),
            switchTheme: SwitchThemeData(
              thumbColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return AppColors.getPrimaryColor(brightness);
                }
                return Colors.grey.shade400;
              }),
              trackColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return AppColors.getPrimaryColor(brightness).withValues(alpha: 0.5);
                }
                return Colors.grey.shade300;
              }),
            ),
          ),

          themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
          initialRoute: AppRoutes.splash,
          onGenerateRoute: AppRoutes.generateRoute,
        );
      },
    );
  }
}