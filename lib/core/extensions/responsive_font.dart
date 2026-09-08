import 'package:flutter/material.dart';

enum FontSize {
  small,
  normal,
  large,
  extraLarge,
}

extension ResponsiveFont on BuildContext {
  double fontSize(FontSize size) {
    final width = MediaQuery.of(this).size.width;

    // Screen scale factor
    double scale;
    if (width < 600) {
      scale = 1.0;        // Mobile
    } else if (width < 1200) {
      scale = 1.1;        // Tablet
    } else {
      scale = 1.2;        // Desktop/Web
    }

    switch (size) {
      case FontSize.small:
        return 14 * scale;
      case FontSize.normal:
        return 18 * scale;   // 👈 Your base
      case FontSize.large:
        return 22 * scale;
      case FontSize.extraLarge:
        return 26 * scale;
    }
  }
}