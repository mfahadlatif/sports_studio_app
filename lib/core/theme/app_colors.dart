import 'package:flutter/material.dart';

class AppColors {
  // Primary colors
  static const Color primary = Color(0xFF21AF6F);
  static const Color primaryDark = Color(0xFF1B8E5A);
  static const Color primaryLight = Color(0xFFE9F7F1);

  // Secondary colors
  static const Color secondary = Color(0xFF1F2937);
  static const Color secondaryLight = Color(0xFF374151);

  // Accent colors
  static const Color accent = Color(0xFFFA8019);
  static const Color accentDark = Color(0xFFD96D12);

  // Neutral colors
  static const Color background = Color(0xFFF7F9FB);
  static const Color surface = Colors.white;
  static const Color error = Color(0xFFE53E3E);
  
  // Text colors
  static const Color textPrimary = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textMuted = Color(0xFF9CA3AF);
  
  // Border colors
  static const Color border = Color(0xFFE5E7EB);
  static const Color inputBackground = Color(0xFFF9FAFB);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryDark],
  );

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accent, accentDark],
  );

  static const LinearGradient darkGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF111827), secondary],
  );
}
