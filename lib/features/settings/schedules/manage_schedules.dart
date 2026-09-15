// features/settings/manage_schedules_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wasteful/core/extensions/responsive_padding.dart';
import 'package:wasteful/core/theme/app_colors.dart';
import 'package:wasteful/core/widgets/app_bar.dart';
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
          ? Center(
              child: Text(
                'No addresses yet',
                style: TextStyle(color: colors.textMuted),
              ),
            )
          : SingleChildScrollView(
              padding: context.padding(PaddingSize.medium),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final address in addresses) ...[
                   
                    if (address.schedules.isEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          'No schedules for this address yet',
                          style: TextStyle(fontSize: 12, color: colors.textMuted),
                        ),
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

                          TextButton.icon(
                            onPressed: ( ) {
                              //ref.
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
                          )
                        ],
                     ),                      
                     
                  ],
                ],
              ),
            ),
    );
  }


}
