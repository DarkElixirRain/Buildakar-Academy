import 'package:flutter/material.dart';

/// Stitch Elite Design System — Consolidated Color Tokens
/// Single source of truth for all colors in the app.
/// Light mode: #F8FAFC background, #FFFFFF surfaces
/// Dark mode: #0B1220 background, #151E2E surfaces
class AppColors {
  AppColors._();

  // ─── Semantic Primary: Electric Blue ───
  static const Color primary = Color(0xFF0058BE);
  static const Color primaryContainer = Color(0xFF2170E4);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onPrimaryContainer = Color(0xFFFEFCFF);
  static const Color primaryFixed = Color(0xFFD8E2FF);
  static const Color primaryFixedDim = Color(0xFFADC6FF);

  // ─── Semantic Secondary: Burnt Orange ───
  static const Color secondary = Color(0xFFA73A00);
  static const Color secondaryContainer = Color(0xFFFD651E);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color onSecondaryContainer = Color(0xFF571A00);

  // ─── Semantic Tertiary: Deep Amber ───
  static const Color tertiary = Color(0xFF924700);
  static const Color tertiaryContainer = Color(0xFFB75B00);
  static const Color onTertiary = Color(0xFFFFFFFF);

  // ─── Error ───
  static const Color error = Color(0xFFDC2626);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color errorContainer = Color(0xFFFFDAD6);

  // ─── Light Mode ───
  static const Color backgroundLight = Color(0xFFF8FAFC);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceDimLight = Color(0xFFCBDBF5);
  static const Color surfaceVariantLight = Color(0xFFD3E4FE);
  static const Color surfaceContainerLowestLight = Color(0xFFFFFFFF);
  static const Color surfaceContainerLowLight = Color(0xFFEFF4FF);
  static const Color surfaceContainerLight = Color(0xFFE5EEFF);
  static const Color surfaceContainerHighLight = Color(0xFFDCE9FF);
  static const Color textPrimaryLight = Color(0xFF0F172A);
  static const Color textOnSurfaceLight = Color(0xFF0B1C30);
  static const Color textSecondaryLight = Color(0xFF64748B);
  static const Color textOnSurfaceVariantLight = Color(0xFF424754);
  static const Color outlineLight = Color(0xFF727785);
  static const Color outlineVariantLight = Color(0xFFC2C6D6);
  static const Color borderLight = Color(0xFFE2E8F0);

  // ─── Dark Mode ───
  static const Color backgroundDark = Color(0xFF0B1220);
  static const Color surfaceDark = Color(0xFF151E2E);
  static const Color surfaceVariantDark = Color(0xFF263349);
  static const Color textPrimaryDark = Color(0xFFF1F5F9);
  static const Color textOnSurfaceDark = Color(0xFFF1F5F9);
  static const Color textSecondaryDark = Color(0xFF94A3B8);
  static const Color textOnSurfaceVariantDark = Color(0xFF94A3B8);
  static const Color outlineDark = Color(0xFF727785);
  static const Color outlineVariantDark = Color(0xFF263349);
  static const Color borderDark = Color(0xFF263349);
  static const Color surfaceContainerDark = Color(0xFF1E293B);

  // ─── Brand Constants (always same regardless of theme) ───
  static const Color brandNavy = Color(0xFF0B1220);
  static const Color brandBlue = Color(0xFF3B82F6);
  static const Color brandOrange = Color(0xFFEA580C);
  static const Color brandRed = Color(0xFFDC2626);
  static const Color brandGreen = Color(0xFF16A34A);
  static const Color brandAmber = Color(0xFFF59E0B);
  static const Color brandViolet = Color(0xFF7C3AED);
  static const Color brandTeal = Color(0xFF0D9488);
  static const Color deepAmber = Color(0xFFD16900);
  static const Color slateCustom = Color(0xFF64748B);
  static const Color primaryLight = Color(0xFF60A5FA);
  static const Color primaryDark = Color(0xFF003D82);
  static const Color liveGradientStart = Color(0xFFFD651E);
  static const Color liveGradientEnd = Color(0xFFD16900);

  // ─── Semantic Gradient (orange→amber, 135deg) ───
  static const LinearGradient premiumGradient = LinearGradient(
    colors: [Color(0xFFEA580C), Color(0xFFD16900)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ─── Theme-aware getters ───
  static Color background(Brightness b) =>
      b == Brightness.light ? backgroundLight : backgroundDark;
  static Color surface(Brightness b) =>
      b == Brightness.light ? surfaceLight : surfaceDark;
  static Color surfaceContainer(Brightness b) =>
      b == Brightness.light ? surfaceContainerLight : surfaceContainerDark;
  static Color surfaceContainerLow(Brightness b) =>
      b == Brightness.light ? surfaceContainerLowLight : surfaceContainerDark;
  static Color surfaceContainerLowest(Brightness b) =>
      b == Brightness.light ? surfaceContainerLowestLight : surfaceDark;
  static Color surfaceVariant(Brightness b) =>
      b == Brightness.light ? surfaceVariantLight : surfaceVariantDark;
  static Color textPrimary(Brightness b) =>
      b == Brightness.light ? textPrimaryLight : textPrimaryDark;
  static Color textOnSurface(Brightness b) =>
      b == Brightness.light ? textOnSurfaceLight : textOnSurfaceDark;
  static Color textSecondary(Brightness b) =>
      b == Brightness.light ? textSecondaryLight : textSecondaryDark;
  static Color textOnSurfaceVariant(Brightness b) =>
      b == Brightness.light ? textOnSurfaceVariantLight : textOnSurfaceVariantDark;
  static Color outline(Brightness b) =>
      b == Brightness.light ? outlineLight : outlineDark;
  static Color outlineVariant(Brightness b) =>
      b == Brightness.light ? outlineVariantLight : outlineVariantDark;
  static Color border(Brightness b) =>
      b == Brightness.light ? borderLight : borderDark;

  // ─── Backward-compat aliases for legacy gradient / field backgrounds ───
  static const Color darkBackground = brandNavy;
  static const Color darkBackgroundElement = surfaceContainerDark;
  static const Color darkBackgroundSelected = borderDark;
  static const Color lightBackground = backgroundLight;
  static const Color lightBackgroundElement = surfaceContainerLowLight;
  static const Color lightBackgroundSelected = borderLight;

  // Backward compat shims (used by existing providers/services)
  static Color getTextColor(Brightness b) => textOnSurface(b);
  static Color getBackgroundColor(Brightness b) => background(b);
  static Color getBackgroundElementColor(Brightness b) => surfaceContainerLowest(b);
  static Color getBackgroundSelectedColor(Brightness b) => border(b);
  static Color getTextSecondaryColor(Brightness b) => textSecondary(b);
  static Color getPrimaryColor(Brightness b) => primary;
  static Color getPrimaryLightColor(Brightness b) => primaryContainer;
  static Color getErrorColor(Brightness b) => error;
  static Color getSuccessColor(Brightness b) => const Color(0xFF16A34A);
  static Color getWarningColor(Brightness b) => const Color(0xFFF59E0B);
  static Color getInfoColor(Brightness b) => primary;
}
