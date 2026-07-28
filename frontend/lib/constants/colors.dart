import 'package:flutter/material.dart';
import '../theme/stitch_colors.dart';

class AppColors {
  // These now delegate to StitchColors for design system consistency

  static Color getTextColor(Brightness brightness) =>
      StitchColors.textPrimary(brightness);

  static Color getBackgroundColor(Brightness brightness) =>
      StitchColors.surface(brightness);

  static Color getBackgroundElementColor(Brightness brightness) =>
      StitchColors.surfaceContainerLowest(brightness);

  static Color getBackgroundSelectedColor(Brightness brightness) =>
      StitchColors.border(brightness);

  static Color getTextSecondaryColor(Brightness brightness) =>
      StitchColors.textSecondary(brightness);

  static Color getPrimaryColor(Brightness brightness) =>
      StitchColors.primary(brightness);

  static Color getPrimaryLightColor(Brightness brightness) =>
      StitchColors.primaryContainer(brightness);

  static Color getErrorColor(Brightness brightness) =>
      StitchColors.error(brightness);

  static Color getSuccessColor(Brightness brightness) =>
      StitchColors.success(brightness);

  static Color getWarningColor(Brightness brightness) =>
      StitchColors.warning(brightness);

  static Color getInfoColor(Brightness brightness) =>
      StitchColors.primary(brightness);

  // Legacy direct references - kept for backward compatibility
  static const Color lightPrimary = StitchColors.primaryLight;
  static const Color lightBackground = StitchColors.surfaceLight;
  static const Color lightBackgroundElement = StitchColors.surfaceContainerLowestLight;
  static const Color lightText = StitchColors.textPrimaryLight;
  static const Color lightTextSecondary = StitchColors.textSecondaryLight;
  static const Color lightError = StitchColors.errorLight;
  static const Color lightSuccess = StitchColors.successLight;
  static const Color lightWarning = StitchColors.warningLight;

  static const Color darkPrimary = StitchColors.primaryDark;
  static const Color darkBackground = StitchColors.surfaceDark;
  static const Color darkBackgroundElement = StitchColors.surfaceContainerLowestDark;
  static const Color darkText = StitchColors.textPrimaryDark;
  static const Color darkTextSecondary = StitchColors.textSecondaryDark;
  static const Color darkError = StitchColors.errorDark;
  static const Color darkSuccess = StitchColors.successDark;
  static const Color darkWarning = StitchColors.warningDark;
}
