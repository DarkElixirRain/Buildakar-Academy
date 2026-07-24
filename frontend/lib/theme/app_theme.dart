import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:buildacad/constants/colors.dart';

/// Stitch Elite Typography — Sora (headings) + Plus Jakarta Sans (body)
class AppTypography {
  AppTypography._();

  // ─── Font Families ───
  static TextStyle _sora({double size = 16, FontWeight weight = FontWeight.w400, double height = 1.5}) {
    return GoogleFonts.sora(fontSize: size, fontWeight: weight, height: height);
  }

  static TextStyle _pjs({double size = 16, FontWeight weight = FontWeight.w400, double height = 1.5}) {
    return GoogleFonts.plusJakartaSans(fontSize: size, fontWeight: weight, height: height);
  }

  // ─── Display / Headings (Sora) ───
  static TextStyle get displayLg => _sora(size: 32, weight: FontWeight.w700, height: 1.25);
  static TextStyle get displayLgMobile => _sora(size: 28, weight: FontWeight.w700, height: 1.286);
  static TextStyle get headlineMd => _sora(size: 24, weight: FontWeight.w600, height: 1.333);
  static TextStyle get headlineSm => _sora(size: 20, weight: FontWeight.w600, height: 1.4);
  static TextStyle get headlineSmMobile => _sora(size: 18, weight: FontWeight.w600, height: 1.333);
  static TextStyle get headlineMdMobile => _sora(size: 24, weight: FontWeight.w700, height: 1.333);
  static TextStyle get headlineLgMobile => _sora(size: 28, weight: FontWeight.w700, height: 1.286);

  // ─── Body (Plus Jakarta Sans) ───
  static TextStyle get bodyLg => _pjs(size: 18, weight: FontWeight.w400, height: 1.556);
  static TextStyle get bodyMd => _pjs(size: 16, weight: FontWeight.w400, height: 1.5);
  static TextStyle get bodySm => _pjs(size: 14, weight: FontWeight.w400, height: 1.429);

  // ─── Labels (Plus Jakarta Sans, uppercase tracking) ───
  static TextStyle get labelCaps => _pjs(size: 11, weight: FontWeight.w500, height: 1.455).copyWith(
    letterSpacing: 0.5,
  );

  // ─── Numerals (tabular figures for prices/stats) ───
  static TextStyle get numericTabular => _pjs(size: 16, weight: FontWeight.w500, height: 1.5);

  // ─── Semantic Combos ───
  static TextStyle sectionHeading(BuildContext context) =>
      headlineSm.copyWith(color: Theme.of(context).colorScheme.onSurface);

  static TextStyle cardTitle(BuildContext context) =>
      _sora(size: 15, weight: FontWeight.w600, height: 1.333).copyWith(
    color: Theme.of(context).colorScheme.onSurface,
  );

  static TextStyle priceText({required Brightness brightness}) =>
      _pjs(size: 18, weight: FontWeight.w700, height: 1.5).copyWith(
    color: AppColors.primary,
  );
}

/// Stitch Elite Spacing & Shape tokens
class AppSpacing {
  AppSpacing._();

  static const double screenMargin = 16;
  static const double gridGutter = 12;
  static const double sectionGap = 24;
  static const double base = 4;
  static const double targetMin = 44;
  static const double navBarHeight = 64;
}

class AppRadius {
  AppRadius._();

  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;

  static BorderRadius get smAll => BorderRadius.circular(sm);
  static BorderRadius get mdAll => BorderRadius.circular(md);
  static BorderRadius get lgAll => BorderRadius.circular(lg);
  static BorderRadius get xlAll => BorderRadius.circular(xl);
  static BorderRadius get full => BorderRadius.circular(9999);

  static BorderRadius get cardAll => BorderRadius.circular(lg);
  static BorderRadius get buttonAll => BorderRadius.circular(md);
  static BorderRadius get inputAll => BorderRadius.circular(md);
  static BorderRadius get chipAll => BorderRadius.circular(sm);
  static BorderRadius get sheetAll => BorderRadius.circular(xl);
  static BorderRadius get dialogAll => BorderRadius.circular(xl);
}

/// Stitch Elite Shadow tokens
class AppShadow {
  AppShadow._();

  static List<BoxShadow> get card => [
    const BoxShadow(
      color: Color(0x0A0F172A),
      blurRadius: 8,
      offset: Offset(0, 2),
    ),
  ];

  static List<BoxShadow> get elevated => [
    const BoxShadow(
      color: Color(0x140F172A),
      blurRadius: 12,
      offset: Offset(0, 4),
    ),
  ];

  static List<BoxShadow> get buttonPrimary => [
    const BoxShadow(
      color: Color(0x330058BE),
      blurRadius: 8,
      offset: Offset(0, 2),
    ),
  ];
}
