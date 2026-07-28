import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import '../../theme/stitch_colors.dart';
import '../../theme/stitch_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _wordmarkController;
  late AnimationController _taglineController;
  late AnimationController _progressController;

  late Animation<double> _logoAnimation;
  late Animation<Offset> _wordmarkAnimation;
  late Animation<double> _wordmarkOpacity;
  late Animation<Offset> _taglineAnimation;
  late Animation<double> _taglineOpacity;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();

    _logoController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _wordmarkController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _taglineController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    );

    _logoAnimation = CurvedAnimation(
      parent: _logoController, curve: Curves.easeOutBack,
    );

    _wordmarkAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3), end: Offset.zero,
    ).animate(CurvedAnimation(parent: _wordmarkController, curve: Curves.easeOutCubic));
    _wordmarkOpacity = CurvedAnimation(
      parent: _wordmarkController, curve: Curves.easeIn,
    );

    _taglineAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3), end: Offset.zero,
    ).animate(CurvedAnimation(parent: _taglineController, curve: Curves.easeOutCubic));
    _taglineOpacity = CurvedAnimation(
      parent: _taglineController, curve: Curves.easeIn,
    );

    _progressAnimation = CurvedAnimation(
      parent: _progressController, curve: const Cubic(0.4, 0.0, 0.2, 1.0),
    );

    _logoController.forward();
    Future.delayed(const Duration(milliseconds: 400), () => _wordmarkController.forward());
    Future.delayed(const Duration(milliseconds: 700), () => _taglineController.forward());
    Future.delayed(const Duration(milliseconds: 300), () => _progressController.forward());

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAuthAndNavigate();
    });
  }

  Future<void> _checkAuthAndNavigate() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await Future.wait([
      authProvider.loadUser(),
      Future.delayed(const Duration(seconds: 3)),
    ]);
    if (!mounted) return;
    Navigator.pushReplacementNamed(
      context,
      authProvider.isAuthenticated ? '/home' : '/login',
    );
  }

  @override
  void dispose() {
    _logoController.dispose();
    _wordmarkController.dispose();
    _taglineController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1220),
      body: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: _RadialGlowPainter(),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                const Spacer(),
                // Logo
                ScaleTransition(
                  scale: _logoAnimation,
                  child: Container(
                    width: 128,
                    height: 128,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const RadialGradient(
                        center: Alignment.center,
                        radius: 0.8,
                        colors: [
                          Color(0x332170E4),
                          Color(0x000058BE),
                        ],
                      ),
                    ),
                    child: Image.asset(
                      'assets/white_favicon.png',
                      width: 80,
                      height: 80,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => Icon(
                        Icons.school, size: 64,
                        color: StitchColors.primaryDark,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                // Wordmark
                SlideTransition(
                  position: _wordmarkAnimation,
                  child: FadeTransition(
                    opacity: _wordmarkOpacity,
                    child: Text(
                      'BuildAcad',
                      style: GoogleFonts.sora(
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                // Tagline
                SlideTransition(
                  position: _taglineAnimation,
                  child: FadeTransition(
                    opacity: _taglineOpacity,
                    child: Text(
                      'Learn. Build. Achieve.',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF94A3B8),
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
                const Spacer(),
                // Progress bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 48),
                  child: AnimatedBuilder(
                    animation: _progressAnimation,
                    builder: (context, child) {
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(2),
                        child: LinearProgressIndicator(
                          value: _progressAnimation.value,
                          backgroundColor: const Color(0x1AFFFFFF),
                          valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF3B82F6)),
                          minHeight: 2,
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'INITIALIZING PLATFORM',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withValues(alpha: 0.2),
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 48),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RadialGlowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.42);
    final radius = size.width * 0.7;

    final gradient = RadialGradient(
      center: Alignment.center,
      radius: 0.7,
      colors: [
        const Color(0x332170E4),
        const Color(0x082170E4),
        Colors.transparent,
      ],
      stops: const [0.0, 0.5, 1.0],
    );

    final paint = Paint()..shader = gradient.createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
