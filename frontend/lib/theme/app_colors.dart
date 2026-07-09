import 'package:flutter/material.dart';

/// Small stand-in for the RN `useTheme()` context.
/// Wire this up to your real theme/provider (e.g. Provider, Riverpod, ThemeMode)
/// — for now it just takes a bool so the screen is drop-in runnable.
class AppColors {
  final bool isDark;
  const AppColors(this.isDark);

  Color get background => isDark ? const Color(0xFF0F172A) : const Color(0xFFFFFFFF);
  Color get backgroundElement => isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC);
  Color get backgroundSelected => isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
  Color get text => isDark ? const Color(0xFFF1F5F9) : const Color(0xFF0F172A);
  Color get textSecondary => isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
  Color get primary => const Color(0xFF2563EB);
  Color get success => const Color(0xFF16A34A);
  Color get warning => const Color(0xFFF59E0B);
  Color get danger => const Color(0xFFDC2626);
  Color get skeleton => isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0);
  Color get badgeBg => isDark ? const Color(0xFF1E3A5F) : const Color(0xFFEFF6FF);
}