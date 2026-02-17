import 'package:flutter/material.dart';

class AppColors {
  // Primary Palette
  static const Color primary = Color(0xFF10B981); // Emerald 500 (More vibrant)
  static const Color primaryDark = Color(0xFF15803D);
  static const Color primaryLight = Color(0xFF4ADE80);

  // Backgrounds
  static const Color background = Color(0xFF0F172A); // Slate 900
  static const Color surface = Color(0xFF1E293B); // Slate 800
  static const Color surfaceLight = Color(0xFF334155); // Slate 700

  // Text
  static const Color textPrimary = Color(0xFFF8FAFC); // Slate 50
  static const Color textSecondary = Color(0xFF94A3B8); // Slate 400
  static const Color textMuted = Color(0xFF64748B); // Slate 500

  // Accents & Functional
  static const Color accent = Color(0xFFF97316); // Orange
  static const Color error = Color(0xFFEF4444); // Red
  static const Color success = Color(0xFF22C55E); // Green

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkGradient = LinearGradient(
    colors: [surface, background],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [background, surface],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient premiumGradient = LinearGradient(
    colors: [Color(0xFF10B981), Color(0xFF064E3B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFFF97316), Color(0xFFC2410C)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static List<BoxShadow> premiumShadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.3),
      blurRadius: 15,
      offset: const Offset(0, 8),
    ),
    BoxShadow(
      color: primary.withOpacity(0.1),
      blurRadius: 30,
      offset: const Offset(0, 10),
    ),
  ];

  // Glassmorphism
  static const Color glassWhite = Color(0x14FFFFFF); // 8% white
  static const Color glassBorder = Color(0x1FFFFFFF); // 12% white
  static const double glassBlur = 12.0;
}
