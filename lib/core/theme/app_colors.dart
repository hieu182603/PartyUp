import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF6C63FF);
  static const Color secondary = Color(0xFFFF6584);
  static const Color background = Color(0xFFF0F4FD);
  static const Color textPrimary = Color(0xFF2D3142);
  static const Color textSecondary = Color(0xFF9094A6);
  static const Color truthColor = Color(0xFF4C9AFF);
  static const Color dareColor = Color(0xFFFF4C61);
  static const Color success = Color(0xFF00C48C);
  static const Color warning = Color(0xFFFFCF5C);

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF6C63FF), Color(0xFF9D94FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient truthGradient = LinearGradient(
    colors: [Color(0xFF4C9AFF), Color(0xFF82B8FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient dareGradient = LinearGradient(
    colors: [Color(0xFFFF4C61), Color(0xFFFF8291)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
