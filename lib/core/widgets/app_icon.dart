import 'package:flutter/material.dart';
import 'package:wasteful/core/extensions/responsive_font.dart';

class AppIcon extends StatelessWidget {
  const AppIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return Image(
      image:  AssetImage('assets/icons/bin/bin_orange.png') ,
      width: context.fontSize(FontSize.extraLarge) * 2,
      height: context.fontSize(FontSize.extraLarge) * 1.7,
      fit: BoxFit.contain,
    );
  }
}

