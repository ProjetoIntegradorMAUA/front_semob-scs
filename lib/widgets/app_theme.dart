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

  const AppPalette({
    required this.background,
    required this.card,
    required this.border,
    required this.text,
    required this.muted,
  });

  static const claro = AppPalette(
    background: Color(0xFFF3F6FB),
    card: Colors.white,
    border: Color(0xFFE2E8F0),
    text: Color(0xFF1E293B),
    muted: Color(0xFF64748B),
  );

  static const escuro = AppPalette(
    background: Color(0xFF0F172A),
    card: Color(0xFF1E293B),
    border: Color(0xFF334155),
    text: Color(0xFFF1F5F9),
    muted: Color(0xFF94A3B8),
  );

  @override
  AppPalette copyWith({
    Color? background,
    Color? card,
    Color? border,
    Color? text,
    Color? muted,
  }) =>
      AppPalette(
        background: background ?? this.background,
        card: card ?? this.card,
        border: border ?? this.border,
        text: text ?? this.text,
        muted: muted ?? this.muted,
      );

  @override
  AppPalette lerp(ThemeExtension<AppPalette>? other, double t) {
    if (other is! AppPalette) return this;
    return AppPalette(
      background: Color.lerp(background, other.background, t)!,
      card: Color.lerp(card, other.card, t)!,
      border: Color.lerp(border, other.border, t)!,
      text: Color.lerp(text, other.text, t)!,
      muted: Color.lerp(muted, other.muted, t)!,
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
