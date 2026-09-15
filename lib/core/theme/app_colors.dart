// core/theme/app_colors.dart
import 'package:flutter/material.dart';

class AppColors extends ThemeExtension<AppColors> {
  final Color background;
  final Color inverseBackground;
  final Color surface;
  final Color border;
  final Color divider;
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color accent;
  final Color cardBackground; // the "ink" card on Home, inverts per mode

  const AppColors({
    required this.background,
    required this.inverseBackground,
    required this.surface,
    required this.border,
    required this.divider,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.accent,
    required this.cardBackground,
  });

  static const light = AppColors(
    background: Color(0xFFF6F7F3),
    inverseBackground: Color(0xFF14181A),
    surface: Color(0xFFFAFBF7),
    border: Color(0xFFDFE3D6),
    divider: Color(0xFFAFB2B2),
    textPrimary: Color(0xFF1B1F1B),
    textSecondary: Color(0xFF5C6459),
    textMuted: Color(0xFF8A9186),
    accent: Color(0xFFDEB841),
    cardBackground: Color(0xFF14181A),
  );

  static const dark = AppColors(
    background: Color(0xFF14181A),
    inverseBackground: Color(0xFFFAFBF7),
    surface: Color(0xFF181D1F),
    border: Color(0xFF262C2E),
    divider: Color(0xFFAFB2B2),
    textPrimary: Color(0xFFF4F1EC),
    textSecondary: Color(0xFFB5BBAC),
    textMuted: Color(0xFF6B7268),
    accent: Color(0xFFDEB841),
    cardBackground: Color(0xFF0D0F10),
  );

  @override
  AppColors copyWith({
    Color? background,
    Color? surface,
    Color? border,
    Color? divider,
    Color? textPrimary,
    Color? textSecondary,
    Color? textMuted,
    Color? accent,
    Color? cardBackground,
    Color? inverseBackground,
  }) {
    return AppColors(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      border: border ?? this.border,
      divider: divider ?? this.divider,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textMuted: textMuted ?? this.textMuted,
      accent: accent ?? this.accent,
      cardBackground: cardBackground ?? this.cardBackground,
      inverseBackground: inverseBackground ?? this.inverseBackground, 
    );
  }

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    return AppColors(
      background: Color.lerp(background, other.background, t)!,
      inverseBackground: Color.lerp(inverseBackground, other.inverseBackground, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      border: Color.lerp(border, other.border, t)!,
      divider: Color.lerp(divider, other.divider, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      cardBackground: Color.lerp(cardBackground, other.cardBackground, t)!,
    );
  }
}

extension AppColorsContext on BuildContext {
  AppColors get colors => Theme.of(this).extension<AppColors>()!;
}