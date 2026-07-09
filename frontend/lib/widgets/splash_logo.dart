import 'package:flutter/material.dart';
import '../constants/colors.dart';

class SplashLogo extends StatefulWidget {
  const SplashLogo({Key? key}) : super(key: key);

  @override
  State<SplashLogo> createState() => _SplashLogoState();
}

class _SplashLogoState extends State<SplashLogo>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutBack,
      ),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final primaryColor = AppColors.getPrimaryColor(brightness);
    final size = MediaQuery.of(context).size;
    
    // Calculate responsive size
    final logoSize = size.width * 0.4.clamp(0.3, 0.5);
    final actualSize = logoSize.clamp(120.0, 200.0);

    // Determine which icon to use based on theme
    final isDarkMode = brightness == Brightness.dark;
    
    // Use correct asset paths without duplication
    final iconAsset = isDarkMode 
        ? 'assets/white_favicon.png' 
        : 'assets/favicon.png';

    // Debug output
    print('🌓 Theme: ${isDarkMode ? "Dark" : "Light"}');
    print('📁 Loading asset: $iconAsset');

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            width: actualSize,
            height: actualSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: primaryColor.withValues(alpha: 0.1),
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withValues(alpha: 0.3),
                  blurRadius: 40,
                  spreadRadius: 15,
                ),
              ],
            ),
            child: ClipOval(
              child: Image.asset(
                iconAsset,
                fit: BoxFit.cover,
                // Use a proper error widget instead of just a fallback
                errorBuilder: (context, error, stackTrace) {
                  print('❌ Error loading $iconAsset: $error');
                  // Show fallback with proper styling
                  return Container(
                    color: primaryColor.withValues(alpha: 0.2),
                    child: Icon(
                      Icons.school,
                      size: actualSize * 0.5,
                      color: primaryColor,
                    ),
                  );
                },
                // Add a loading indicator
                frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                  if (frame == null) {
                    return Container(
                      color: primaryColor.withValues(alpha: 0.1),
                      child: Center(
                        child: CircularProgressIndicator(
                          color: primaryColor,
                          strokeWidth: 2,
                        ),
                      ),
                    );
                  }
                  return child;
                },
              ),
            ),
          ),
        );
      },
    );
  }
}