import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/colors.dart';
import '../../providers/theme_provider.dart';

class AppButton extends StatelessWidget {
  final String title;
  final VoidCallback? onPressed;
  final bool isLoading;
  final double? width;
  final double? height;

  const AppButton({
    super.key,
    required this.title,
    required this.onPressed,
    this.isLoading = false,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final brightness = isDark ? Brightness.dark : Brightness.light;
    final isEnabled = !isLoading && onPressed != null;
    final primaryColor = AppColors.getPrimaryColor(brightness);

    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: ElevatedButton(
        onPressed: isEnabled ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: isEnabled
              ? primaryColor
              : AppColors.getTextSecondaryColor(brightness),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: isEnabled ? 4 : 0,
          shadowColor: isEnabled
              ? primaryColor.withValues(alpha: 0.3)
              : Colors.transparent,
        ),
        child: isLoading
            ? const SizedBox(
                height: 22,
                width: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white,
                ),
              )
            : Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  letterSpacing: 0.5,
                ),
              ),
      ),
    );
  }
}

class AppSocialButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color iconColor;
  final Color? backgroundColor;
  final VoidCallback onPressed;
  final bool isSmallDevice;

  const AppSocialButton({
    super.key,
    required this.icon,
    required this.label,
    required this.iconColor,
    this.backgroundColor,
    required this.onPressed,
    this.isSmallDevice = false,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final brightness = isDark ? Brightness.dark : Brightness.light;

    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor:
              backgroundColor ??
              AppColors.getBackgroundElementColor(brightness),
          foregroundColor: AppColors.getTextColor(brightness),
          padding: EdgeInsets.symmetric(vertical: isSmallDevice ? 12 : 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          side: BorderSide(
            color: AppColors.getBackgroundSelectedColor(brightness),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: isSmallDevice ? 20 : 22, color: iconColor),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: isSmallDevice ? 13 : 15,
                color: AppColors.getTextColor(brightness),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
