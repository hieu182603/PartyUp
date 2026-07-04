import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF7C5CFF); // Tím chủ đạo
  static const Color secondary = Color(0xFFFF4B72); // Hồng/Đỏ (Nút bắt đầu, v.v.)
  static const Color background = Color(0xFFFAFAFC); // Nền sáng
  static const Color textPrimary = Color(0xFF1E202C); // Chữ chính tối màu
  static const Color textSecondary = Color(0xFF7D8398); // Chữ phụ xám
  static const Color truthColor = Color(0xFFFF4B72); // Thật - Hồng/Đỏ
  static const Color dareColor = Color(0xFF368DFF); // Thách - Xanh dương
  static const Color success = Color(0xFF00C48C);
  static const Color warning = Color(0xFFFFCF5C); // Xu vàng, sao

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF7C5CFF), Color(0xFF9D5CFF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient truthGradient = LinearGradient(
    colors: [Color(0xFFFF4B72), Color(0xFFFF8296)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient dareGradient = LinearGradient(
    colors: [Color(0xFF368DFF), Color(0xFF63ACFF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient luckyWheelGradient = LinearGradient(
    colors: [Color(0xFF8F5BFF), Color(0xFFB794FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient secretRuleGradient = LinearGradient(
    colors: [Color(0xFFFF8C4B), Color(0xFFFFB27A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient miniGamesGradient = LinearGradient(
    colors: [Color(0xFF00C6FF), Color(0xFF0072FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
