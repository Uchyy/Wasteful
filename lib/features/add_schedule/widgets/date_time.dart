// core/widgets/date_field.dart
import 'package:flutter/material.dart';
import 'package:wasteful/core/extensions/responsive_font.dart';
import 'package:wasteful/core/extensions/responsive_padding.dart';
import 'package:wasteful/core/theme/app_colors.dart';

class DateField extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final String? errorText;

  const DateField({
    required this.label,
    required this.icon,
    required this.onTap,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final hasError = errorText != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: context.padding(PaddingSize.medium),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: hasError ? Colors.redAccent : colors.accent.withAlpha(50),
                width: hasError ? 1.5 : 1,
              ),
            ),
            child: Row(
              children: [
                Icon(icon, size: 18, color: colors.textPrimary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    label,
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(
                          fontSize: context.fontSize(FontSize.normal),
                          letterSpacing: 1.2,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
                Icon(Icons.keyboard_arrow_down, size: 16, color: colors.textMuted),
              ],
            ),
          ),
        ),
        if (hasError) ...[
          const SizedBox(height: 4),
          Text(
            errorText!,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.redAccent,
                  fontSize: context.fontSize(FontSize.small),
                ),
          ),
        ],
      ],
    );
  }
}