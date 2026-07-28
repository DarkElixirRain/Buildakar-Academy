import 'package:flutter/material.dart';
import '../constants/colors.dart';

class SplashTitle extends StatelessWidget {
  const SplashTitle({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final primaryColor = AppColors.getPrimaryColor(brightness);
    final primaryLightColor = AppColors.getPrimaryLightColor(brightness);
    final textSecondaryColor = AppColors.getTextSecondaryColor(brightness);

    return Column(
      children: [
        ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            colors: [
              primaryColor,
              primaryLightColor,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(bounds),
          child: Text(
            'BuildAcad',
            style: TextStyle(
              fontSize: 42,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 1.5,
              shadows: [
                Shadow(
                  color: primaryColor.withValues(alpha: 0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Learn. Build. Achieve.',
          style: TextStyle(
            fontSize: 16,
            color: textSecondaryColor,
            letterSpacing: 2,
            fontWeight: FontWeight.w300,
          ),
        ),
      ],
    );
  }
}