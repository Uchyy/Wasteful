// features/home/widgets/waste_type_selector.dart
import 'package:flutter/material.dart';
import 'package:wasteful/core/constants/bin_types.dart';
import 'package:wasteful/core/extensions/responsive_font.dart';
import 'package:wasteful/core/extensions/responsive_padding.dart';
import '../../../core/theme/app_colors.dart';

class WasteTypeSelector extends StatefulWidget {
  final List<BinType> entries;
  final ValueChanged<BinType>? onSelected;

  const WasteTypeSelector({
    super.key,
    required this.entries,
    this.onSelected, BinType? initialValue,
  });

  @override
  State<WasteTypeSelector> createState() => _WasteTypeSelectorState();
}

class _WasteTypeSelectorState extends State<WasteTypeSelector> {
  BinType? _selectedType;

  @override
  Widget build(BuildContext context) {
    if (widget.entries.isEmpty) return const SizedBox.shrink();

    return LayoutBuilder(
      builder: (context, constraints) {
        // How many columns fit comfortably at this width.
        // Phones get 2, tablets/desktop get more, capped at 4.
        final columns = (constraints.maxWidth / 160).floor().clamp(2, 4);
        final spacing = context.padding(PaddingSize.small).right;
        final cardWidth = (constraints.maxWidth - spacing * (columns - 1)) / columns;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (final binType in widget.entries)
              SizedBox(
                width: cardWidth,
                child: _WasteCard(
                  binType: binType,
                  isSelected: _selectedType == binType,
                  onTap: () {
                    setState(() => _selectedType = binType);
                    widget.onSelected?.call(binType);
                  },
                ),
              ),
          ],
        );
      },
    );
  }
}

class _WasteCard extends StatelessWidget {
  final BinType binType;
  final bool isSelected;
  final VoidCallback onTap;

  const _WasteCard({
    required this.binType,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final baseColor = Color.lerp(binType.color, Colors.white, 0.8)!;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: context.padding(PaddingSize.medium),
        decoration: BoxDecoration(
          color: isSelected ? baseColor : colors.background,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? colors.accent : colors.inverseBackground,
            width: isSelected ? 2.5 : 1,
          ),
          boxShadow: isSelected
              ? [BoxShadow(color: colors.accent.withAlpha(60), blurRadius: 8, spreadRadius: 1)]
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            isSelected ? binType.icon(size: context.fontSize(FontSize.extraLarge) * 3) : binType.getfallBackIcon(size: context.fontSize(FontSize.extraLarge) * 3),
            const SizedBox(height: 10),
            Text(
              binType.label,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: isSelected ? Colors.black : colors.inverseBackground,
                    fontSize: context.fontSize(FontSize.normal),
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}