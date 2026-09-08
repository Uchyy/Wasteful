import 'package:flutter/material.dart';

enum PaddingSize {
  small,
  medium,
  large,
}

extension ResponsivePadding on BuildContext {
  EdgeInsets padding(PaddingSize size,) {
    final width = MediaQuery.of(this).size.width;

    double value;

    if (width < 600) {
      // 📱 Mobile
      switch (size) {
        case PaddingSize.small:
          value = 10;
          break;
        case PaddingSize.medium:
          value = 16;
          break;
        case PaddingSize.large:
          value = 24;
          break;
      }
    } else if (width < 1200) {
      // 📲 Tablet
      switch (size) {
        case PaddingSize.small:
          value = 12;
          break;
        case PaddingSize.medium:
          value = 24;
          break;
        case PaddingSize.large:
          value = 36;
          break;
      }
    } else {
      // 💻 Desktop/Web
      switch (size) {
        case PaddingSize.small:
          value = 16;
          break;
        case PaddingSize.medium:
          value = 32;
          break;
        case PaddingSize.large:
          value = 48;
          break;
      }
    }

    return EdgeInsets.all(value);
  }
}