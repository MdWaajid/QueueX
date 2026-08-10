import 'package:flutter/material.dart';

abstract class AppColors {
  // Brand Colors
  static const Color primary = Color(0xFFFF6B00); // Warm Orange
  static const Color primaryLight = Color(0xFFFF8533);
  static const Color primaryDark = Color(0xFFCC5200);

  // Background & Surfaces
  static const Color background = Color(0xFFFAFAFA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color cardSurface = Color(0xFFFFFFFF);
  static const Color divider = Color(0xFFEEEEEE);

  // Text Colors
  static const Color textPrimary = Color(0xFF1E1E1E); // Dark Charcoal
  static const Color textSecondary = Color(0xFF757575); // Muted Gray
  static const Color textDisabled = Color(0xFFBDBDBD);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // Semantic Status Colors
  static const Color available = Color(0xFF2E7D32); // Green = available/success
  static const Color moderate = Color(0xFFF57F17); // Yellow = moderate/warning
  static const Color peak = Color(0xFFD32F2F); // Red = peak/danger/full
  static const Color success = Color(0xFF2E7D32);
  static const Color warning = Color(0xFFF57F17);
  static const Color error = Color(0xFFD32F2F);

  // Action / State Colors
  static const Color disabledButton = Color(0xFFE0E0E0);
  static const Color disabledButtonText = Color(0xFF9E9E9E);
}
