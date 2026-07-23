import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../../constants/colors.dart';
import '../../widgets/splash_logo.dart';
import '../../widgets/splash_title.dart';
import '../../widgets/splash_loading.dart';
import '../../providers/theme_provider.dart';
import '../../providers/auth_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Set status bar style
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
    );

    // Initialize animation
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeIn,
      ),
    );

    // Start animation
    _animationController.forward();

    // Defer until after the first frame. initState() runs synchronously
    // during the build phase, and calling authProvider.loadUser()
    // directly from here can trigger notifyListeners() before the
    // widget tree has finished building (Dart async functions run
    // synchronously up to their first `await`), which throws
    // "setState() or markNeedsBuild() called during build".
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAuthAndNavigate();
    });
  }

  Future<void> _checkAuthAndNavigate() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // Run the auth check alongside the splash's minimum display time, so
    // the splash always shows for at least 4 seconds regardless of how
    // fast loadUser() resolves.
    await Future.wait([
      authProvider.loadUser(),
      Future.delayed(const Duration(seconds: 4)),
    ]);

    if (!mounted) return;

    Navigator.pushReplacementNamed(
      context,
      authProvider.isAuthenticated ? '/home' : '/login',
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final brightness = isDark ? Brightness.dark : Brightness.light;

    return Scaffold(
      backgroundColor: AppColors.getBackgroundColor(brightness),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
                    AppColors.darkBackground,
                    AppColors.darkBackgroundElement,
                    AppColors.darkBackgroundSelected,
                  ]
                : [
                    AppColors.lightBackground,
                    AppColors.lightBackgroundElement,
                    AppColors.lightBackgroundSelected,
                  ],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Spacer(flex: 1),
                SplashLogo(),
                SizedBox(height: 40),
                SplashTitle(),
                Spacer(flex: 1),
                SplashLoading(),
                SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}