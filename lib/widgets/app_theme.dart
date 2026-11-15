import 'package:flutter/material.dart';

/// Cores de marca: iguais no tema claro e no escuro.
class AppColors {
  static const primary = Color(0xFF1D5FD1);
  static const sidebarTop = Color(0xFF0A3D91);
  static const sidebarBottom = Color(0xFF061B4A);

  static const teal = Color(0xFF14B8A6);
  static const blue = Color(0xFF2563EB);
  static const orange = Color(0xFFF59E0B);
  static const red = Color(0xFFEF4444);
  static const green = Color(0xFF22C55E);
  static const infoBackground = Color(0xFFEFF6FF);
}

/// Cores que MUDAM entre tema claro e escuro (fundo, cards, bordas e textos).
/// Uso: `context.cores.card`, `context.cores.muted`, etc.
@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  final Color background;
  final Color card;
  final Color border;
  final Color text;
  final Color muted;

ThemeData buildTheme() => ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        surface: AppColors.card,
      ),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.border),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }
}

extension AppThemeContext on BuildContext {
  AppPalette get cores => Theme.of(this).extension<AppPalette>()!;
}

/// Moldura branca (ou escura) dos cards.
BoxDecoration cardDecoration(BuildContext context) => BoxDecoration(
      color: context.cores.card,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: context.cores.border),
    );

ThemeData buildTheme([Brightness brilho = Brightness.light]) {
  final paleta = brilho == Brightness.dark ? AppPalette.escuro : AppPalette.claro;
  return ThemeData(
    useMaterial3: true,
    brightness: brilho,
    scaffoldBackgroundColor: paleta.background,
    colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary, brightness: brilho),
    extensions: [paleta],
  );
}
