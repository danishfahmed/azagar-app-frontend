import 'package:flutter/material.dart';
import 'package:azager/core/theme/app_theme_controller.dart';

class AppColors {
  AppColors._();

  // Primary / Brand
  static const Color primary = Color(0xFFE98610);
  static const Color primaryLight = Color(0xFFFFF3E0);

  // Neutrals
  static const Color black = Color(0xFF1A1A1A);
  static const Color darkGrey = Color(0xFF4A4A4A);
  static const Color grey = Color(0xFF9E9E9E);
  static const Color lightGrey = Color(0xFFE0E0E0);
  static const Color fieldBorder = Color(0xFFD0D0D0);
  static Color get background => AppThemeController.isDark
      ? const Color(0xFF121212)
      : const Color.fromARGB(255, 255, 255, 255);
  static Color get scaffold =>
      AppThemeController.isDark ? const Color(0xFF161616) : Colors.white;

  // Text
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF6B6B6B);
  static const Color textHint = Color(0xFFBDBDBD);

  // Social
  static const Color google = Color(0xFFDB4437);
  static const Color facebook = Color(0xFF1877F2);
}
