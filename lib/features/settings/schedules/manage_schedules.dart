// features/settings/manage_schedules_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wasteful/core/extensions/responsive_padding.dart';
import 'package:wasteful/core/theme/app_colors.dart';
import 'package:wasteful/core/widgets/app_bar.dart';
import 'package:wasteful/core/widgets/app_confirm_dialog.dart';
import 'package:wasteful/core/widgets/app_snackbar.dart';
import 'package:wasteful/core/widgets/section_wrapper.dart';
import 'package:wasteful/features/home/home_controller.dart';
import 'package:wasteful/features/settings/widget/schedule_row.dart';


class ManageSchedulesScreen extends ConsumerWidget {
  const ManageSchedulesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final addresses = ref.watch(addressesProvider);

    return Scaffold(
      appBar: CustomAppBar(showBack: true, title: "Manage Schedules"),
      body: addresses.isEmpty
          ? Column(
            children: [
              hintText(context),

              Center(
                child: Text(
                  'No addresses yet',
                  style: TextStyle(color: colors.textMuted),
                ),
              ),

              const SizedBox(height: 40,)
            ],

          )
          : SingleChildScrollView(
              padding: context.padding(PaddingSize.medium),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 40,),
                  hintText(context),

                  for (final address in addresses) ...[
                   
                    if (address.schedules.isEmpty)
                     SectionCard(
                      title: address.label,
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: context.padding(PaddingSize.small).vertical
                          ),
                          child: Center(
                            child: Text(
                              'No schedules for this address yet',
                              style: TextStyle(fontSize: 12, color: colors.textMuted),
                            ),
                          ),
                        ),

                        DeleteAddressButton(context: context, ref: ref, label: address.label, id: address.id)
                      ]
                     )
                      
                    else
                     SectionCard (
                       title: address.label,
                       children: [
                        for (int i = 0; i < address.schedules.length; i++) ...[
                            ScheduleRow(
                              addressId: address.id,
                              schedule: address.schedules[i],
                            ),
                          ],

                          DeleteAddressButton(context: context, ref: ref, label: address.label, id: address.id)
                        ],
                     ),                      
                     
                  ],
                ],
              ),
            ),
    );
  }

  Widget DeleteAddressButton ({required BuildContext context, required WidgetRef ref, required String label, required String id}) {
    return TextButton.icon(
      onPressed: ( ) async {
        final confirmed = await AppConfirmDialog.show(
          context,
          title: 'Delete this address?',
          message: 'This will also delete all schedules for "${label}". This can\'t be undone.',
          confirmLabel: 'Delete',
          type: ConfirmDialogType.danger,
          icon: Icons.delete_outline,
          onConfirm: () => ref.read(addressesProvider.notifier).remove(id),
        );

        if (confirmed && context.mounted) {
          showAppSnackBar(context, message: '${label} deleted', type: SnackType.info);
        }
      }, 
      icon: Icon(Icons.delete_outline, color: Colors.redAccent,),
      label: Text(
        "Delete this address",
        style: Theme.of(context).textTheme.titleSmall!.copyWith(color: Colors.redAccent),
      ),
      style: ButtonStyle(
        elevation: const WidgetStatePropertyAll<double>(4), 
        foregroundColor: WidgetStatePropertyAll<Color>(Colors.redAccent),
        padding: WidgetStatePropertyAll<EdgeInsetsGeometry>(
          EdgeInsets.symmetric(vertical: context.padding(PaddingSize.small).vertical,
          horizontal: context.padding(PaddingSize.medium).horizontal
          ),
        ),
      )
    );
  }

  Widget hintText(BuildContext context) {
    final colors = context.colors;
    return Container(
      //margin: context.padding(PaddingSize.small),
      decoration: BoxDecoration(
        color: colors.accent.withAlpha(20), 
        borderRadius: BorderRadius.circular(15)
      ),
      width: double.infinity,
      padding: context.padding(PaddingSize.small),
      child: Row(
        children: [
          Icon(Icons.info_outline, size: 16, color: colors.accent),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              "Swipe left to delete a schedule, or tap to edit",
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
        ],
      ),
    );
  }


}
