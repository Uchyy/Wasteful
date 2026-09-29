// features/settings/manage_schedules_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wasteful/core/constants/bin_types.dart';
import 'package:wasteful/core/extensions/responsive_padding.dart';
import 'package:wasteful/core/theme/app_colors.dart';
import 'package:wasteful/core/widgets/app_bar.dart';
import 'package:wasteful/core/widgets/app_confirm_dialog.dart';
import 'package:wasteful/core/widgets/app_snackbar.dart';
import 'package:wasteful/core/widgets/section_wrapper.dart';
import 'package:wasteful/features/home/home_controller.dart';
import 'package:wasteful/features/settings/widget/schedule_row.dart';

class ManageSchedulesScreen extends ConsumerStatefulWidget {
  const ManageSchedulesScreen({super.key});

  @override
  ConsumerState<ManageSchedulesScreen> createState() =>  _ManageSchedulesScreenState();
}

class _ManageSchedulesScreenState extends ConsumerState<ManageSchedulesScreen> {
  bool _searching = false;
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final addresses = ref.watch(addressesProvider);

    final filteredAddresses = addresses
      .map((address) {
        if (_query.isEmpty) {
          return address;
        }

        // If the address itself matches, show all of its schedules.
        if (address.label.toLowerCase().contains(_query)) {
          return address;
        }

        // Otherwise only show schedules matching the search.
        final schedules = address.schedules.where((schedule) { return schedule.binTypes.label.toLowerCase().contains(_query);}).toList();
        return address.copyWith( schedules: schedules,);
      }).where((address) {
        return _query.isEmpty || address.label.toLowerCase().contains(_query) || address.schedules.isNotEmpty; }).toList();

    return Scaffold(
      appBar: CustomAppBar(
        showBack: true,
        title: 'Manage Schedules',
      ),
      body: addresses.isEmpty
        ? Column(
            children: [
              hintText(context),
              const SizedBox(height: 20),

              Center(
                child: Text(
                  'No addresses yet',
                  style: TextStyle(
                    color: colors.textMuted,
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          )
        : SingleChildScrollView(
            padding: context.padding(PaddingSize.medium),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),
                hintText(context),

                const SizedBox(height: 12),
                searchButton(context),

                const SizedBox(height: 20),

                if (filteredAddresses.isEmpty && _query.isNotEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 30),
                      child: Text(
                        'No schedules found',
                        style: TextStyle(
                          color: colors.textMuted,
                        ),
                      ),
                    ),
                  ),

                for (final address in filteredAddresses) ...[

                  if (address.schedules.isEmpty)
                    SectionCard(
                      title: address.label,
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric( vertical: context.padding(PaddingSize.small).vertical, ),
                          child: Center(
                            child: Text(
                              'No schedules for this address yet',
                              style: TextStyle(
                                fontSize: 12,
                                color: colors.textMuted,
                              ),
                            ),
                          ),
                        ),

                        DeleteAddressButton(
                          context: context,
                          ref: ref,
                          label: address.label,
                          id: address.id,
                        ),
                      ],
                    )

                  else
                    SectionCard(
                      title: address.label,
                      children: [
                        
                        for (int i = 0; i < address.schedules.length; i++) ...[
                          ScheduleRow(
                            addressId: address.id,
                            schedule: address.schedules[i],
                          ),
                        ],

                        DeleteAddressButton(
                          context: context,
                          ref: ref,
                          label: address.label,
                          id: address.id,
                        ),
                      ],
                    ),

                  const SizedBox(height: 16),
                ],
              ],
            ),
          ),
    );
  }

  Widget searchButton(BuildContext context) {
    final colors = context.colors;

    if (!_searching) {
      return InkWell(
        onTap: () {
          setState(() {
            _searching = true;
          });
        },
        borderRadius: BorderRadius.circular(15),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          decoration: BoxDecoration(
            border: Border.all(
              color: colors.accent,
            ),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Row(
            children: [
              Icon( Icons.search, color: colors.textMuted,),
              const SizedBox(width: 10),

              Text(
                'Search schedules',
                style: TextStyle( color: colors.textMuted, ),
              ),
            ],
          ),
        ),
      );
    }

    return TextField(
      autofocus: true,
      onChanged: (value) {
        setState(() {
          _query = value.trim().toLowerCase();
        });
      },
      decoration: InputDecoration(
        hintText: 'Search schedules',
        prefixIcon: const Icon(Icons.search),
        suffixIcon: IconButton(
          onPressed: () {
            setState(() {
              _query = '';
              _searching = false;
            });
          },
          icon: const Icon(Icons.close),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: colors.accent)
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(
            color: colors.border,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(
            color: colors.accent,
            width: 1.5,
          ),
        ),
      ),
    );
  }

  Widget DeleteAddressButton({  required BuildContext context, required WidgetRef ref, required String label, required String id,
  }) {
    return TextButton.icon(
      onPressed: () async {
        final confirmed = await AppConfirmDialog.show(
          context,
          title: 'Delete this address?',
          message: 'This will also delete all schedules for "$label". This can\'t be undone.',
          confirmLabel: 'Delete',
          type: ConfirmDialogType.danger,
          icon: Icons.delete_outline,
          onConfirm: () => ref.read(addressesProvider.notifier).remove(id),
        );

        if (confirmed && context.mounted) {
          showAppSnackBar(
            context,
            message: '$label deleted',
            type: SnackType.info,
          );
        }
      },
      icon: const Icon( Icons.delete_outline, color: Colors.redAccent,),
      label: Text(
        'Delete this address',
        style: Theme.of(context).textTheme.titleSmall!.copyWith(  color: Colors.redAccent, ),
      ),
      style: ButtonStyle(
        elevation: const WidgetStatePropertyAll<double>(4),
        foregroundColor: const WidgetStatePropertyAll<Color>( Colors.redAccent, ),
        padding: WidgetStatePropertyAll<EdgeInsetsGeometry>(
          EdgeInsets.symmetric(
            vertical: context.padding(PaddingSize.small).vertical,
            horizontal: context.padding(PaddingSize.medium).horizontal,
          ),
        ),
      ),
    );
  }

  Widget hintText(BuildContext context) {
    final colors = context.colors;

    return Container(
      decoration: BoxDecoration(
        color: colors.accent.withAlpha(20),
        borderRadius: BorderRadius.circular(15),
      ),
      width: double.infinity,
      padding: context.padding(PaddingSize.small),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            size: 16,
            color: colors.accent,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Swipe left to delete a schedule, or tap to edit',
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
        ],
      ),
    );
  }
}