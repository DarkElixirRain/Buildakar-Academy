import 'package:flutter/material.dart';
import '../constants/colors.dart';

/// Instance-based theme accessor — delegates to the consolidated AppColors.
/// Use this in widgets that take a BuildContext and want `theme.primary` style access.
class AppTheme {
  final Brightness brightness;
  const AppTheme(this.brightness);

  bool get isDark => brightness == Brightness.dark;

  Color get background => AppColors.background(brightness);
  Color get surface => AppColors.surface(brightness);
  Color get surfaceContainer => AppColors.surfaceContainer(brightness);
  Color get surfaceContainerLow => AppColors.surfaceContainerLow(brightness);
  Color get surfaceContainerLowest => AppColors.surfaceContainerLowest(brightness);
  Color get surfaceVariant => AppColors.surfaceVariant(brightness);
  Color get text => AppColors.textOnSurface(brightness);
  Color get textSecondary => AppColors.textSecondary(brightness);
  Color get textOnSurfaceVariant => AppColors.textOnSurfaceVariant(brightness);
  Color get outline => AppColors.outline(brightness);
  Color get outlineVariant => AppColors.outlineVariant(brightness);
  Color get border => AppColors.border(brightness);
  Color get primary => AppColors.primary;
  Color get primaryContainer => AppColors.primaryContainer;
  Color get secondary => AppColors.secondary;
  Color get secondaryContainer => AppColors.secondaryContainer;
  Color get error => AppColors.error;
  Color get success => const Color(0xFF16A34A);
  Color get warning => const Color(0xFFF59E0B);

  static AppTheme of(BuildContext context) {
    return AppTheme(Theme.of(context).brightness);
  }
}

/// Backward-compat alias used by notes_list, study_material_list, course_reviews
class AppColorsCompat {
  final bool isDark;
  const AppColorsCompat(this.isDark);

  Color get background => isDark ? AppColors.backgroundDark : AppColors.backgroundLight;
  Color get backgroundElement => isDark ? AppColors.surfaceDark : AppColors.surfaceContainerLowestLight;
  Color get backgroundSelected => isDark ? AppColors.borderDark : AppColors.borderLight;
  Color get text => isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
  Color get textSecondary => isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
  Color get primary => AppColors.primary;
  Color get success => const Color(0xFF16A34A);
  Color get warning => const Color(0xFFF59E0B);
  Color get danger => AppColors.error;
  Color get skeleton => isDark ? AppColors.surfaceDark : AppColors.borderLight;
  Color get badgeBg => isDark ? const Color(0xFF1E3A5F) : const Color(0xFFEFF6FF);
}
