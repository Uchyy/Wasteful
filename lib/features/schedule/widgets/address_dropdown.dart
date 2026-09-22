// features/add_schedule/widgets/address_dropdown_schedule.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wasteful/core/widgets/app_snackbar.dart';
import 'package:wasteful/data/model/address.dart';
import 'package:wasteful/features/schedule/widgets/add_schedule_dropdown.dart';
import 'package:wasteful/features/home/home_controller.dart';
import '../../../core/theme/app_colors.dart';

const _kAddNewSentinel = '__add_new__';

class AddressDropdownSchedule extends ConsumerStatefulWidget {
  final String? selectedId;
  final String? errorText;
  final ValueChanged<String?> onSelected;

  const AddressDropdownSchedule({
    super.key,
    required this.selectedId,
    required this.onSelected,
    this.errorText,
  });

  @override
  ConsumerState<AddressDropdownSchedule> createState() => _AddressDropdownScheduleState();
}

class _AddressDropdownScheduleState extends ConsumerState<AddressDropdownSchedule> {
  bool _showAddInput = false;
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _confirmNewAddress() async {
    final label = _controller.text.trim();
    if (label.isEmpty) return;

    final addresses = ref.read(addressesProvider);
    final isDuplicate = addresses.any(
      (a) => a.label.toLowerCase() == label.toLowerCase(),
    );

    if (isDuplicate) {
      showAppSnackBar(
        context,
        message: 'You already have an address named "$label"',
        type: SnackType.error,
      );
      return;
    }

    final newAddress = Address(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      label: label,
      isDefault: false,
      createdAt: DateTime.now(),
      schedules: [],
    );

    try {
      await ref.read(addressesProvider.notifier).add(newAddress);
      widget.onSelected(newAddress.id);
      _controller.clear();

      if (mounted) {
        setState(() => _showAddInput = false);
      }

      showAppSnackBar(
        context,
        message: 'Address added',
        type: SnackType.success,
      );
    } catch (error, stackTrace) {
      debugPrint('Failed to add address: $error');
      debugPrintStack(stackTrace: stackTrace);

      if (!mounted) return;

      showAppSnackBar(
        context,
        message: 'Could not add address',
        type: SnackType.error,
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final addresses = ref.watch(addressesProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [

        AddScheduleDropdown<String?>(
          selectLabel: "address",
          initialValue: widget.selectedId,
          icon: Icons.home_filled,
          items: [
            for (final address in addresses) AddScheduleItem(value: address.id, label: address.label),
            const AddScheduleItem(value: _kAddNewSentinel, label: '+ Add another address'),
          ],
          onSelected: (id) {
            if (id == _kAddNewSentinel) {
              setState(() => _showAddInput = true);
            } else {
              widget.onSelected(id);
            }
          },
          errorText: widget.errorText,
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 200),
          child: _showAddInput
              ? Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          autofocus: true,
                          onSubmitted: (_) => _confirmNewAddress(),
                          decoration: InputDecoration(
                            hintText: 'e.g. Portsmouth Home',
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: colors.border),
                            ),
                          ),
                        ),
                      ),
                      IconButton(onPressed: _confirmNewAddress, icon: Icon(Icons.check, color: colors.accent)),
                      IconButton(
                        onPressed: () => setState(() {
                          _controller.clear();
                          _showAddInput = false;
                        }),
                        icon: Icon(Icons.close, color: colors.textMuted),
                      ),
                    ],
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}