// core/theme/app_text_styles.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTextStyles {
  AppTextStyles._();

  static TextTheme textTheme(Color primary, Color secondary, {bool isDark = false}) {
    final base = (isDark
            ? Typography.material2021(platform: TargetPlatform.android).white
            : Typography.material2021(platform: TargetPlatform.android).black)
        .apply(bodyColor: primary, displayColor: primary);

    return base.copyWith(
      headlineSmall: GoogleFonts.bricolageGrotesque(
        fontSize: 32,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.3,
        color: primary,
      ),
      titleMedium: GoogleFonts.merriweather(
        fontSize: 18,
        fontWeight: FontWeight.w500,
        color: primary,
      ),
      bodyMedium: GoogleFonts.fraunces(
        fontSize: 14,
        color: primary,
      ),
      bodySmall: GoogleFonts.smoochSans(
        fontSize: 12,
        color: secondary,
      ),
      labelSmall: GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.6,
        color: secondary,
      ),
    );
  }
}

// core/theme/app_text_styles.dart (add at bottom) — unchanged
extension AppTextStylesContext on BuildContext {
  TextTheme get textStyles => Theme.of(this).textTheme;
}