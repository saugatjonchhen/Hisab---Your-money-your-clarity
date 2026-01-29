import 'package:flutter/material.dart';

abstract class AppColors {
  // Brand Colors
  static const Color primary = Color(0xFF10B981); // Emerald/Mint
  static const Color secondary = Color(0xFF065F46); // Forest Green
  static const Color tertiary = Color(0xFFF43F5E); // Rose/Coral (for contrast)

  // Backgrounds
  static const Color backgroundLight = Color(0xFFF0FDF4); // Very Pale Green
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color backgroundDark = Color(0xFF0F1715); // Deep Charcoal with Emerald hint
  static const Color surfaceDark = Color(0xFF1B2421); // Dark Surface with subtle green tint

  // Text
  static const Color textPrimaryLight = Color(0xFF1A1A1A);
  static const Color textSecondaryLight = Color(0xFF757575);
  static const Color textPrimaryDark = Color(0xFFE0E0E0);
  static const Color textSecondaryDark = Color(0xFFA0A0A0);

  // Status
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFFBBF24);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // Features
  static const Color savings = Color(0xFF3B82F6); // Blue for Savings
  static const Color investment = Color(0xFF8B5CF6); // Violet for Investments

  // Gradients
  static const Gradient primaryGradient = LinearGradient(
    colors: [Color(0xFF10B981), Color(0xFF059669)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
