import 'package:flutter/material.dart';
import 'package:wasteful/core/theme/bin_colors.dart';

enum BinType {
  general,
  recycling,
  garden,
  food,
  other,
}

extension BinTypeX on BinType {
  String get label {
    switch (this) {
      case BinType.general:
        return 'General';
      case BinType.recycling:
        return 'Recycling';
      case BinType.garden:
        return 'Garden';
      case BinType.food:
        return 'Food waste';
      case BinType.other:
        return 'Other';
    }
  }

  Color get color {
    switch (this) {
      case BinType.general:
        return BinColors.general;
      case BinType.recycling:
        return BinColors.recycling;
      case BinType.garden:
        return BinColors.garden;
      case BinType.food:
        return BinColors.food;
      case BinType.other:
        return BinColors.other;
    }
  }

  Widget icon({double size = 24}) {
    switch (this) {
      case BinType.general:
        return getBinWidget("black", size: size);
      case BinType.recycling:
        return getBinWidget("green", size: size);
      case BinType.garden:
        return getBinWidget("brown", size: size);
      case BinType.food:
        return getBinWidget("gray", size: size);
      case BinType.other:
        return getBinWidget("orange", size: size);
    }
  }

  Icon getfallBackIcon ({double size = 24}) {
    switch (this) {
      case BinType.general:
        return Icon(Icons.delete_outline, color: BinColors.general, size: size,);
      case BinType.recycling:
        return Icon(Icons.recycling_outlined, color: BinColors.recycling, size: size,);
      case BinType.garden:
        return Icon(Icons.eco_outlined, color: BinColors.garden, size: size,);
      case BinType.food:
        return Icon(Icons.compost_outlined, color: BinColors.food, size: size,);
      case BinType.other:
        return Icon(Icons.help_outline, color: BinColors.other, size: size,);
    }
  }

  Widget getBinWidget(String binType, {double size = 24}) {
    return Image.asset(
      'assets/icons/bin/bin_${binType}.png',
      fit: BoxFit.contain,
      width: size,
      height: size,
    );
  }
}