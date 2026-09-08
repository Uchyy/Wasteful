// core/widgets/app_dropdown.dart
import 'package:flutter/material.dart';
import 'package:wasteful/core/extensions/responsive_font.dart';
import 'package:wasteful/core/extensions/responsive_padding.dart';
import 'package:wasteful/core/theme/app_colors.dart';

class AddScheduleItem<T> {
  final T value;
  final String label;

  const AddScheduleItem({
    required this.value,
    required this.label,
  });
}

class AddScheduleDropdown<T> extends StatefulWidget {
  final List<AddScheduleItem<T>> items;
  final T? initialValue;
  final ValueChanged<T?> onSelected;
  final String Function(T?)? labelBuilder;
  final IconData icon;
  final String? errorText; // <-- new

  const AddScheduleDropdown({
    super.key,
    required this.items,
    required this.onSelected,
    this.initialValue,
    this.labelBuilder,
    this.errorText,
    required this.icon
  });

  @override
  State<AddScheduleDropdown<T>> createState() => _AddScheduleDropdownState<T>();
}

class _AddScheduleDropdownState<T> extends State<AddScheduleDropdown<T>> {
  late T? _selected = widget.initialValue;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final hasError = widget.errorText != null;

    final selectedItem = widget.items.where((i) => i.value == _selected).firstOrNull;
    final label = widget.labelBuilder?.call(_selected) ?? selectedItem?.label ?? 'Select';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        PopupMenuButton<T>(
          initialValue: _selected,
          color: colors.surface,
          elevation: 3,
          padding: context.padding(PaddingSize.small),
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: colors.accent.withAlpha(100), width: 1),
          ),
          constraints: const BoxConstraints(minWidth: 160, maxWidth: 260),
          offset: const Offset(0, 32),
          onSelected: (value) {
            setState(() => _selected = value);
            widget.onSelected(value);
          },
          itemBuilder: (context) => [
            for (final item in widget.items)
              _buildItem(context, colors, item: item, isSelected: _selected == item.value),
          ],

          child: Container(
            width: double.infinity,
            padding: context.padding(PaddingSize.medium),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: hasError ? Colors.redAccent : colors.accent.withAlpha(50),
                width: hasError ? 1.5 : 1,
              ),
            ),

            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Icon(widget.icon, size: 16, color: colors.textPrimary),
                const SizedBox(width: 20),

                Text(
                  label.toUpperCase(),
                  style: Theme.of(context).textTheme.bodySmall!.copyWith(
                    fontSize: context.fontSize(FontSize.normal),
                    letterSpacing: 1.8,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const Spacer(),

                Icon(Icons.keyboard_arrow_down, size: 16, color: colors.textMuted),
              ],
            ),
          ),
        ),

        if (hasError) ...[
          const SizedBox(height: 4),
          Text(
            widget.errorText!,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.redAccent,
                  fontSize: context.fontSize(FontSize.small),
                ),
          ),
        ],
      ],
    );
  }

  PopupMenuItem<T> _buildItem( BuildContext context, AppColors colors, { required AddScheduleItem<T> item, required bool isSelected, }) {
    return PopupMenuItem<T>(
      value: item.value,
      padding: context.padding(PaddingSize.small),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [

          Row(
            children: [
              
              Text(
                item.label,
                style: Theme.of(context).textTheme.bodySmall!.copyWith(
                      fontSize: context.fontSize(FontSize.normal),
                      letterSpacing: 1.5,
                      color: isSelected ? colors.accent : colors.textPrimary,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    ),
              ),
            ],
          ),

          if (isSelected) Icon(Icons.check, size: 16, color: colors.accent),
        ],
      ),
    );
  }
}