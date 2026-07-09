import 'package:flutter/material.dart';

class AppColors {
  // Light theme colors
  static const Color lightText = Color(0xFF000000);
  static const Color lightBackground = Color(0xFFFFFFFF);
  static const Color lightBackgroundElement = Color(0xFFF0F0F3);
  static const Color lightBackgroundSelected = Color(0xFFE0E1E6);
  static const Color lightTextSecondary = Color(0xFF60646C);
  static const Color lightPrimary = Color(0xFF2563EB);
  static const Color lightPrimaryLight = Color(0xFF60A5FA);
  static const Color lightError = Color(0xFFEF4444);
  static const Color lightSuccess = Color(0xFF22C55E);
  static const Color lightWarning = Color(0xFFF59E0B);
  static const Color lightInfo = Color(0xFF3B82F6);

  // Dark theme colors
  static const Color darkText = Color(0xFFFFFFFF);
  static const Color darkBackground = Color(0xFF000000);
  static const Color darkBackgroundElement = Color(0xFF212225);
  static const Color darkBackgroundSelected = Color(0xFF2E3135);
  static const Color darkTextSecondary = Color(0xFFB0B4BA);
  static const Color darkPrimary = Color(0xFF60A5FA);
  static const Color darkPrimaryLight = Color(0xFF93C5FD);
  static const Color darkError = Color(0xFFF87171);
  static const Color darkSuccess = Color(0xFF34D399);
  static const Color darkWarning = Color(0xFFFBBF24);
  static const Color darkInfo = Color(0xFF60A5FA);

  // Theme getters
  static Color getTextColor(Brightness brightness) =>
      brightness == Brightness.light ? lightText : darkText;

  static Color getBackgroundColor(Brightness brightness) =>
      brightness == Brightness.light ? lightBackground : darkBackground;

  static Color getBackgroundElementColor(Brightness brightness) =>
      brightness == Brightness.light ? lightBackgroundElement : darkBackgroundElement;

  static Color getBackgroundSelectedColor(Brightness brightness) =>
      brightness == Brightness.light ? lightBackgroundSelected : darkBackgroundSelected;

  static Color getTextSecondaryColor(Brightness brightness) =>
      brightness == Brightness.light ? lightTextSecondary : darkTextSecondary;

  static Color getPrimaryColor(Brightness brightness) =>
      brightness == Brightness.light ? lightPrimary : darkPrimary;

  static Color getPrimaryLightColor(Brightness brightness) =>
      brightness == Brightness.light ? lightPrimaryLight : darkPrimaryLight;

  static Color getErrorColor(Brightness brightness) =>
      brightness == Brightness.light ? lightError : darkError;

  static Color getSuccessColor(Brightness brightness) =>
      brightness == Brightness.light ? lightSuccess : darkSuccess;

  static Color getWarningColor(Brightness brightness) =>
      brightness == Brightness.light ? lightWarning : darkWarning;

  static Color getInfoColor(Brightness brightness) =>
      brightness == Brightness.light ? lightInfo : darkInfo;
}