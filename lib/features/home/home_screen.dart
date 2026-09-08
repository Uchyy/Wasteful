// features/home/home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wasteful/core/constants/bin_types.dart';
import 'package:wasteful/core/extensions/responsive_font.dart';
import 'package:wasteful/core/extensions/responsive_padding.dart';
import 'package:wasteful/core/utils/getOrdinalDate.dart';
import 'package:wasteful/core/widgets/app_bar.dart';
import 'package:wasteful/core/widgets/app_icon.dart';
import 'package:wasteful/core/widgets/section_wrapper.dart';
import 'package:wasteful/data/model/schedule.dart';
import 'package:wasteful/features/home/widgets/address_dropdown.dart';
import 'package:wasteful/features/home/widgets/swipeable_due_card.dart';
import '../../core/theme/app_colors.dart';
import 'home_controller.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final addresses = ref.watch(addressesProvider);
    final selectedAddressId = ref.watch(selectedAddressIdProvider);
    //final isDarkMode = Theme.of(context).brightness == Brightness.dark;
   
    final relevantAddresses = selectedAddressId == null ? addresses : addresses.where((a) => a.id == selectedAddressId).toList();
    final allSchedules = relevantAddresses.expand((a) => a.schedules).where((s) => !s.isArchived).toList();

    // 1. Due tonight
    final dueTonight = allSchedules.where((s) => s.isDueTonight).toList();

    // 2. Upcoming (everything else, soonest first)
    final upcoming = allSchedules.where((s) => !s.isDueTonight).toList()..sort((a, b) => a.nextCollectionDate().compareTo(b.nextCollectionDate()));

    if (addresses.isEmpty) {
      return Scaffold(
        appBar: CustomAppBar(
          title: "Wasteful",
          showBack: false,
        ),
        body: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: context.padding(PaddingSize.small).horizontal * 0.5,
                  vertical: context.padding(PaddingSize.small).vertical * 0.2,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    AppIcon(),
                  ],
                ),
              ),

              Icon(Icons.location_off_outlined, size: 46, color: colors.textMuted),
              const SizedBox(height: 16),

              const Text('No addresses yet', style: TextStyle(fontWeight: FontWeight.w500)),
              const SizedBox(height: 4),

              Text(
                'Add one to start getting reminders',
                style: TextStyle(fontSize: 12, color: colors.textMuted),
              ),
              const SizedBox(height: 20),
              ElevatedButton(onPressed: () {}, child: const Text('+ Add an address')),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: CustomAppBar(
        title: "Wasteful",
        showBack: false,
        actionWidget: addresses.isNotEmpty ? const AddressDropdown() : null,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: context.padding(PaddingSize.medium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [ 
              const SizedBox(height: 20),
              Text(
                "Hey, bins are calling!",
                style: TextStyle(
                  fontFamily: GoogleFonts.lilitaOne().fontFamily,
                  letterSpacing: 2,
                  fontSize: context.fontSize(FontSize.extraLarge),
                  color: colors.textPrimary,
                ),

              ),

              dueTonight.isNotEmpty
              ? SwipeableDueCards(entries: dueTonight.map((s) => (schedule: s)).toList())
              : Container (
                //margin: context.padding(PaddingSize.small),
                alignment: Alignment.center,
                padding: EdgeInsets.symmetric(vertical: context.padding(PaddingSize.large).vertical * 3,),
                margin: EdgeInsets.only(top: context.padding(PaddingSize.medium).top),
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: colors.border),
                ),
                child: const Text('No due items'),
              ),
              const SizedBox(height: 40),

              upcoming.isNotEmpty 
              ? SectionCard(
                  title: 'Upcoming',
                  backgroundColor: colors.inverseBackground,
                  //contentPadding: EdgeInsets.zero,
                  actionButton: upcoming.isNotEmpty
                    ? TextButton(
                        onPressed: () {},
                        child: Text(
                          'See all',
                          style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: colors.accent, fontSize: context.fontSize(FontSize.large) * 0.8 ),
                        ),
                      )
                    : null,
                  children: [
                    for (int i = 0; i < upcoming.length; i++) ...[
                      ListTile(
                        contentPadding: context.padding(PaddingSize.small) * 0.5,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
                        leading: upcoming[i].binTypes.first == BinType.general
                          ? upcoming[i].binTypes.first.getfallBackIcon(size: context.fontSize(FontSize.extraLarge) * 2)
                          : upcoming[i].binTypes.first.icon(size: context.fontSize(FontSize.extraLarge) * 2),
                        title: Text(
                          getOrdinalDate(upcoming[i].nextCollectionDate()),
                          style: Theme.of(context).textTheme.headlineMedium!.copyWith(color: colors.textPrimary,  fontSize: context.fontSize(FontSize.normal) ),
                        ),
                        subtitle: Text(
                          upcoming[i].binTypes.map((b) => b.label).join(' + '),
                          style: Theme.of(context).textTheme.headlineSmall!.copyWith(color: colors.textSecondary, letterSpacing: 1.5, fontSize: context.fontSize(FontSize.normal) * 0.5),
                        ),
                      ),
                    ]
                  ],
                )
              : Container (
                //margin: context.padding(PaddingSize.small),
                alignment: Alignment.center,
                padding: EdgeInsets.symmetric(vertical: context.padding(PaddingSize.large).vertical * 2,),
                margin: EdgeInsets.only(top: context.padding(PaddingSize.medium).top),
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: colors.border),
                ),
                child: const Text('No upcoming items'),
              ), 

            ],
          ),
        )


      ),
    );
  }
}



//for (final entry in dueSchedules)
 // Text('${entry.address.label}: ${entry.schedule.binTypes.map((b) => b.label).join(" + ")}')