import 'package:flutter/material.dart';

class AppColors {
  static const primary = Color(0xFF1D5FD1);
  static const sidebarTop = Color(0xFF0A3D91);
  static const sidebarBottom = Color(0xFF061B4A);
  static const background = Color(0xFFF3F6FB);
  static const card = Colors.white;
  static const border = Color(0xFFE2E8F0);
  static const text = Color(0xFF1E293B);
  static const muted = Color(0xFF64748B);

  static const teal = Color(0xFF14B8A6);
  static const blue = Color(0xFF2563EB);
  static const orange = Color(0xFFF59E0B);
  static const red = Color(0xFFEF4444);
  static const green = Color(0xFF22C55E);
}

final cardDecoration = BoxDecoration(
  color: AppColors.card,
  borderRadius: BorderRadius.circular(12),
  border: Border.all(color: AppColors.border),
);

ThemeData buildTheme() => ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
    );
