import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'constants/colors.dart';
import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'providers/search_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/live_class_provider.dart';
import 'providers/instructor_dashboard_provider.dart';
import 'providers/instructor_course_provider.dart';
import 'routes/app_routes.dart';
import 'theme/app_theme.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
}

Future<void> main() async {
  await runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    try {
      await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
      if (!kIsWeb) {
        FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
        await FirebaseMessaging.instance.requestPermission(alert: true, badge: true, sound: true);
      }
    } catch (e) {
      debugPrint('Firebase init error: $e');
    }
    runApp(const BuildAcadApp());
  }, (error, stackTrace) {
    debugPrint('Unhandled zone error: $error');
  });
}

class BuildAcadApp extends StatelessWidget {
  const BuildAcadApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProxyProvider<AuthProvider, LiveClassProvider>(
          create: (ctx) => LiveClassProvider(authProvider: ctx.read<AuthProvider>()),
          update: (_, auth, prev) => prev ?? LiveClassProvider(authProvider: auth),
        ),
        ChangeNotifierProxyProvider<AuthProvider, SearchProvider>(
          create: (ctx) => SearchProvider(authProvider: ctx.read<AuthProvider>()),
          update: (_, auth, prev) => prev ?? SearchProvider(authProvider: auth),
        ),
        ChangeNotifierProxyProvider<AuthProvider, InstructorDashboardProvider>(
          create: (_) => InstructorDashboardProvider(),
          update: (_, __, prev) => prev ?? InstructorDashboardProvider(),
        ),
        ChangeNotifierProxyProvider<AuthProvider, InstructorCourseProvider>(
          create: (_) => InstructorCourseProvider(),
          update: (_, __, prev) => prev ?? InstructorCourseProvider(),
        ),
      ],
      child: const _BuildAcadMaterialApp(),
    );
  }
}

class _BuildAcadMaterialApp extends StatefulWidget {
  const _BuildAcadMaterialApp();
  @override
  State<_BuildAcadMaterialApp> createState() => _BuildAcadMaterialAppState();
}

class _BuildAcadMaterialAppState extends State<_BuildAcadMaterialApp> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  bool _lastKnownAuthState = false;

  @override
  void initState() {
    super.initState();
    if (!kIsWeb) {
      FirebaseMessaging.onMessage.listen((m) => debugPrint('FG: ${m.notification?.title}'));
      FirebaseMessaging.onMessageOpenedApp.listen((m) => debugPrint('BG tap: ${m.data}'));
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ap = Provider.of<AuthProvider>(context, listen: false);
      ap.addListener(_onAuthChanged);
    });
  }

  void _onAuthChanged() {
    final ap = Provider.of<AuthProvider>(context, listen: false);
    if (_lastKnownAuthState && !ap.isAuthenticated) {
      _navigatorKey.currentState?.pushNamedAndRemoveUntil('/login', (_) => false);
    }
    _lastKnownAuthState = ap.isAuthenticated;
  }

  @override
  void dispose() {
    try {
      Provider.of<AuthProvider>(context, listen: false).removeListener(_onAuthChanged);
    } catch (_) {}
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (ctx, themeProvider, _) {
        final isDark = themeProvider.isDarkMode;
        final brightness = isDark ? Brightness.dark : Brightness.light;

        final colorScheme = ColorScheme(
          brightness: brightness,
          primary: AppColors.primary,
          onPrimary: AppColors.onPrimary,
          primaryContainer: AppColors.primaryContainer,
          onPrimaryContainer: AppColors.onPrimaryContainer,
          secondary: AppColors.secondary,
          onSecondary: AppColors.onSecondary,
          secondaryContainer: AppColors.secondaryContainer,
          onSecondaryContainer: AppColors.onSecondaryContainer,
          tertiary: AppColors.tertiary,
          onTertiary: AppColors.onTertiary,
          tertiaryContainer: AppColors.tertiaryContainer,
          error: AppColors.error,
          onError: AppColors.onError,
          errorContainer: AppColors.errorContainer,
          surface: AppColors.surface(brightness),
          onSurface: AppColors.textOnSurface(brightness),
          surfaceContainerLowest: AppColors.surfaceContainerLowest(brightness),
          surfaceContainerLow: AppColors.surfaceContainerLow(brightness),
          surfaceContainer: AppColors.surfaceContainer(brightness),
          surfaceContainerHigh: isDark ? const Color(0xFF1E293B) : const Color(0xFFDCE9FF),
          surfaceContainerHighest: isDark ? const Color(0xFF263349) : const Color(0xFFD3E4FE),
          surfaceVariant: AppColors.surfaceVariant(brightness),
          onSurfaceVariant: AppColors.textOnSurfaceVariant(brightness),
          outline: AppColors.outline(brightness),
          outlineVariant: AppColors.outlineVariant(brightness),
          inverseSurface: isDark ? const Color(0xFFE2E8F0) : const Color(0xFF213145),
          onInverseSurface: isDark ? const Color(0xFF0B1220) : const Color(0xFFEAF1FF),
          shadow: const Color(0xFF0F172A),
          surfaceTint: AppColors.primary,
        );

        final textTheme = TextTheme(
          displayLarge: AppTypography.displayLg.copyWith(color: colorScheme.onSurface),
          displayMedium: AppTypography.displayLgMobile.copyWith(color: colorScheme.onSurface),
          headlineMedium: AppTypography.headlineMd.copyWith(color: colorScheme.onSurface),
          headlineSmall: AppTypography.headlineSm.copyWith(color: colorScheme.onSurface),
          titleMedium: AppTypography.headlineSmMobile.copyWith(color: colorScheme.onSurface),
          bodyLarge: AppTypography.bodyLg.copyWith(color: colorScheme.onSurface),
          bodyMedium: AppTypography.bodyMd.copyWith(color: colorScheme.onSurface),
          bodySmall: AppTypography.bodySm.copyWith(color: colorScheme.onSurfaceVariant),
          labelLarge: AppTypography.labelCaps.copyWith(color: colorScheme.onSurfaceVariant),
          labelSmall: AppTypography.labelCaps.copyWith(color: colorScheme.outline),
        );

        return MaterialApp(
          title: 'BuildAcad',
          debugShowCheckedModeBanner: false,
          navigatorKey: _navigatorKey,
          theme: ThemeData(
            useMaterial3: true,
            brightness: brightness,
            colorScheme: colorScheme,
            scaffoldBackgroundColor: AppColors.background(brightness),
            textTheme: textTheme,
            fontFamily: GoogleFonts.plusJakartaSans().fontFamily,
            appBarTheme: AppBarTheme(
              backgroundColor: AppColors.surface(brightness),
              foregroundColor: colorScheme.onSurface,
              elevation: 0,
              scrolledUnderElevation: 0,
              surfaceTintColor: Colors.transparent,
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.onPrimary,
                elevation: 0,
                minimumSize: Size.fromHeight(AppSpacing.targetMin),
                padding: const EdgeInsets.symmetric(horizontal: 24),
                shape: RoundedRectangleBorder(borderRadius: AppRadius.buttonAll),
                textStyle: AppTypography.bodyMd.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
            outlinedButtonTheme: OutlinedButtonThemeData(
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                minimumSize: Size.fromHeight(AppSpacing.targetMin),
                padding: const EdgeInsets.symmetric(horizontal: 24),
                shape: RoundedRectangleBorder(borderRadius: AppRadius.buttonAll),
                side: const BorderSide(color: AppColors.primary, width: 1.5),
                textStyle: AppTypography.bodyMd.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
                textStyle: AppTypography.bodySm.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
            cardTheme: CardThemeData(
              color: AppColors.surfaceContainerLowest(brightness),
              elevation: 0,
              margin: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: AppRadius.cardAll,
                side: BorderSide(color: AppColors.border(brightness), width: 1),
              ),
            ),
            inputDecorationTheme: InputDecorationTheme(
              filled: true,
              fillColor: AppColors.surfaceContainerLowest(brightness),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              border: OutlineInputBorder(
                borderRadius: AppRadius.inputAll,
                borderSide: BorderSide(color: AppColors.border(brightness)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: AppRadius.inputAll,
                borderSide: BorderSide(color: AppColors.border(brightness)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: AppRadius.inputAll,
                borderSide: const BorderSide(color: AppColors.primary, width: 2),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: AppRadius.inputAll,
                borderSide: const BorderSide(color: AppColors.error),
              ),
              labelStyle: AppTypography.bodySm.copyWith(color: AppColors.outline(brightness)),
              hintStyle: AppTypography.bodyMd.copyWith(color: AppColors.outline(brightness)),
            ),
            chipTheme: ChipThemeData(
              backgroundColor: AppColors.surfaceContainer(brightness),
              labelStyle: AppTypography.bodySm.copyWith(color: colorScheme.onSurfaceVariant),
              shape: RoundedRectangleBorder(
                borderRadius: AppRadius.chipAll,
                side: BorderSide.none,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            dividerTheme: DividerThemeData(
              color: AppColors.border(brightness),
              thickness: 1,
              space: 0,
            ),
            switchTheme: SwitchThemeData(
              thumbColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) return AppColors.primary;
                return AppColors.outline(brightness);
              }),
              trackColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return AppColors.primary.withValues(alpha: 0.4);
                }
                return AppColors.outlineVariant(brightness);
              }),
            ),
            bottomNavigationBarTheme: BottomNavigationBarThemeData(
              backgroundColor: AppColors.surface(brightness),
              selectedItemColor: AppColors.primary,
              unselectedItemColor: AppColors.outline(brightness),
              type: BottomNavigationBarType.fixed,
              elevation: 0,
            ),
            dialogTheme: DialogThemeData(
              backgroundColor: AppColors.surfaceContainerLowest(brightness),
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: AppRadius.sheetAll),
            ),
            bottomSheetTheme: BottomSheetThemeData(
              backgroundColor: AppColors.surfaceContainerLowest(brightness),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
            ),
          ),
          themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
          initialRoute: AppRoutes.splash,
          onGenerateRoute: AppRoutes.generateRoute,
        );
      },
    );
  }
}
