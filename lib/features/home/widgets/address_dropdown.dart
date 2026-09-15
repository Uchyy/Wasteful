// features/home/widgets/address_dropdown.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:wasteful/core/extensions/responsive_font.dart';
import 'package:wasteful/core/extensions/responsive_padding.dart';
import '../../../core/theme/app_colors.dart';
import '../home_controller.dart';

// features/home/widgets/address_dropdown.dart
const kAllAddressesValue = '__all__';

final selectedAddressIdProvider = StateProvider<String?>((ref) => kAllAddressesValue);

class AddressDropdown extends ConsumerWidget {
  const AddressDropdown({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final addresses = ref.watch(addressesProvider);
    final selectedId = ref.watch(selectedAddressIdProvider);
    final showAll = addresses.length > 2;

    // "All" is only a real selection when it's actually offered; otherwise
    // fall back sensibly rather than pointing at a sentinel with no match.
    final effectiveId = (selectedId == kAllAddressesValue && !showAll) ? (addresses.isNotEmpty ? addresses.first.id : null) : selectedId;

    final isAllSelected = effectiveId == kAllAddressesValue;
    final selectedLabel = isAllSelected ? 'All' : (effectiveId == null ? 'Select' : addresses.firstWhere((a) => a.id ==       effectiveId, orElse: () => addresses.first,  ).label);

    if (addresses.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: colors.border, width: 1),
        ),
        child: Text('No addresses', style: TextStyle(color: colors.textMuted)),
      );
    }

    return PopupMenuButton<String?>(
      initialValue: effectiveId,
      color: colors.surface,
      elevation: 3,
      padding: context.padding(PaddingSize.small),
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: colors.border, width: 1),
      ),
      constraints: const BoxConstraints(minWidth: 160, maxWidth: 220),
      offset: const Offset(0, 32),
      onSelected: (id) => ref.read(selectedAddressIdProvider.notifier).state = id,
      itemBuilder: (context) => [
        if (showAll)
          _buildItem(context, colors, value: kAllAddressesValue, label: 'All', isSelected: isAllSelected),
        for (final address in addresses)
          _buildItem(context, colors, value: address.id, label: address.label, isSelected: effectiveId == address.id),
      ],
      child: Container(
        padding: context.padding(PaddingSize.small),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: colors.accent.withAlpha(50), width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              selectedLabel.toUpperCase(),
              style: Theme.of(context).textTheme.bodySmall!.copyWith(
                fontSize: context.fontSize(FontSize.normal),
                letterSpacing: 1.5,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.keyboard_arrow_down, size: 16, color: colors.textMuted),
          ],
        ),
      ),
    );
  }

  PopupMenuItem<String?> _buildItem(BuildContext context, AppColors colors, {required String? value, required String label, required bool isSelected}) {
    return PopupMenuItem(
      value: value,
      padding: context.padding(PaddingSize.small),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall!.copyWith(
              fontSize: context.fontSize(FontSize.normal),
              letterSpacing: 1.5,
              color: isSelected ? colors.accent : colors.textPrimary,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
          if (isSelected) Icon(Icons.check, size: 16, color: colors.accent),
        ],
      ),
    );
  }
}