// core/theme/bin_colors.dart
import 'package:flutter/material.dart';

/// Fixed, real-world bin colors (Portsmouth scheme).
/// These represent physical bin colors, not app theme —
/// they stay constant regardless of light/dark mode.
class BinColors {
  BinColors._();

  static const general = Color(0xFF2B2B2B);   // black
  static const recycling = Color(0xFF4CAF6D); // green
  static const garden = Color(0xFF6B4A2E);    // brown
  static const food = Color(0xFF9E9E96);      // gray/ash caddy
  static const other = Color(0xFFFE852D);
}