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
    
    // Use correct asset paths - white for dark theme, colored for light theme
    final iconAsset = isDarkMode 
        ? 'assets/white_favicon.png' 
        : 'assets/favicon.png';

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Image.asset(
            iconAsset,
            width: actualSize,
            height: actualSize,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              // Fallback icon if image fails to load
              return Icon(
                Icons.school,
                size: actualSize * 0.8,
                color: primaryColor,
              );
            },
            frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
              if (frame == null) {
                return SizedBox(
                  width: actualSize,
                  height: actualSize,
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
        );
      },
    );
  }
}