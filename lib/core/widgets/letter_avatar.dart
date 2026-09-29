import 'package:flutter/material.dart';
import 'package:wasteful/core/extensions/responsive_font.dart';
import 'package:wasteful/core/theme/app_colors.dart';

class LetterAvatar extends StatelessWidget {
  const LetterAvatar({
    super.key,
    required this.letter,
    this.radius = 28,
  });

  final String letter;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final substring = capitalize(getAvatarText(letter));

    return CircleAvatar(
      backgroundColor: colors.accent.withAlpha(20),
      radius: radius,
      child: Text(
        substring,
        style: TextStyle(
          fontSize: context.fontSize(FontSize.small),
          fontWeight: FontWeight.bold,
          color: colors.accent
        ),
      ),
    );
  }

  String getAvatarText(String value) {
    final text = value.trim();
    if (text.isEmpty) return '?';

    // Address starts with a number.
    final numberMatch = RegExp(r'^\d+').firstMatch(text);
    if (numberMatch != null) {
      return numberMatch.group(0)!;
    }

    final words = text.split(RegExp(r'\s+'));
    if (words.length == 1) {
      return words[0].length >= 2
          ? words[0].substring(0, 2).toUpperCase()
          : words[0].toUpperCase();
    }

    return '${words[0][0]}${words[1][0]}'.toUpperCase();
  }

  String capitalize(String value) {
    if (value.isEmpty) return value;

    return value[0].toUpperCase() + value.substring(1).toLowerCase();
  }
}