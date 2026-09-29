// features/home/home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wasteful/core/constants/bin_types.dart';
import 'package:wasteful/core/extensions/responsive_font.dart';
import 'package:wasteful/core/extensions/responsive_padding.dart';
import 'package:wasteful/core/utils/getOrdinalDate.dart';
import 'package:wasteful/core/widgets/app_bar.dart';
import 'package:wasteful/core/widgets/letter_avatar.dart';
import 'package:wasteful/core/widgets/section_wrapper.dart';
import 'package:wasteful/data/model/schedule.dart';
import 'package:wasteful/data/repository/schedule_provider.dart';
import 'package:wasteful/features/home/widgets/address_dropdown.dart';
import 'package:wasteful/features/home/widgets/swipeable_due_card.dart';
import 'package:wasteful/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import 'home_controller.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool _showAllUpcoming = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final addresses = ref.watch(addressesProvider);
    final selectedAddressId = ref.watch(selectedAddressIdProvider);

    final isAllSelected = selectedAddressId == null || selectedAddressId == kAllAddressesValue;
    final relevantAddresses = isAllSelected ? addresses : addresses.where((a) => a.id == selectedAddressId).toList();

    final allSchedules = relevantAddresses.expand((a) => a.schedules).where((s) => !s.isArchived).toList();

    final dueTonight = allSchedules.where((s) {
      if (!s.isDueTonight) return false;
      if (s.lastTakenOut == null) return true;

      final today = DateTime.now();

      return s.lastTakenOut!.year != today.year || s.lastTakenOut!.month != today.month ||s.lastTakenOut!.day != today.day;
    }).toList();
    final upcoming = allSchedules.where((s) => !s.isDueTonight).toList()..sort((a, b) => a.nextCollectionDate().compareTo(b.nextCollectionDate()));

    const previewLimit = 3;
    final hasMore = upcoming.length > previewLimit;
    final visibleUpcoming = (_showAllUpcoming || !hasMore) ? upcoming : upcoming.take(previewLimit).toList();

    if (addresses.isEmpty) {
      return Scaffold(
        appBar: CustomAppBar(
          title: "Wasteful",
          centerTitle: false,
          showBack: false,
        ),
        body: SafeArea(
          child: Center(
            
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
              
                Icon(Icons.location_off_outlined, size: 46, color: colors.textMuted),
                const SizedBox(height: 16),

                const Text('No addresses yet', style: TextStyle(fontWeight: FontWeight.w500)),
                const SizedBox(height: 4),

                Text(
                  'Add one to start getting reminders',
                  style: TextStyle(fontSize: 12, color: colors.textMuted),
                ),
                const SizedBox(height: 20),

                ElevatedButton(
                  onPressed: () {
                    context.push(AppRoutes.addSchedule);
                  }, 
                  style: ButtonStyle(
                    elevation: const WidgetStatePropertyAll<double>(4), 
                    foregroundColor: WidgetStatePropertyAll<Color>(Colors.redAccent),
                    padding: WidgetStatePropertyAll<EdgeInsetsGeometry>(
                      EdgeInsets.symmetric(vertical: context.padding(PaddingSize.small).vertical,
                      horizontal: context.padding(PaddingSize.medium).horizontal
                      ),
                    ),
                  ),
                  child: const Text('+ Add a Schedule')
                ),

              
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: CustomAppBar(
        title: "Wasteful",
        centerTitle: false,
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
                "👋 Hello, bins are calling!",
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
                actionButton: hasMore
                    ? TextButton(
                        onPressed: () => setState(() => _showAllUpcoming = !_showAllUpcoming),
                        child: Text(
                          _showAllUpcoming ? 'Show less' : 'See all',
                          style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                color: colors.accent,
                                fontSize: context.fontSize(FontSize.large) * 0.8,
                              ),
                        ),
                      )
                    : null,
                children: [
                  for (int i = 0; i < visibleUpcoming.length; i++) ...[

                    InkWell(
                      onTap: () => context.push(
                      AppRoutes.editSchedule,
                      extra: {'addressId': visibleUpcoming[i].addressId, 'schedule': visibleUpcoming[i]},
                      ),
                      child: ListTile(
                        contentPadding: context.padding(PaddingSize.small) * 0.5,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
                        leading: FutureBuilder<String>(
                          future: ref.read(scheduleRepositoryProvider).getAddressLabel(  visibleUpcoming[i].addressId, ),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return const LetterAvatar(letter: '?');
                            }

                            return LetterAvatar( letter: snapshot.data!,);
                          },
                        ),
      
                        title: Text(
                          getOrdinalDate(visibleUpcoming[i].nextCollectionDate()),
                          style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                            color: colors.textPrimary,
                            fontSize: context.fontSize(FontSize.normal),
                          ),
                        ),
                        subtitle: FutureBuilder<String>(
                          future: ref.read(scheduleRepositoryProvider).getAddressLabel(visibleUpcoming[i].addressId),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return const SizedBox.shrink();
                            }

                            return Row(
                              children: [
                                Expanded(
                                  child: Text.rich(
                                    maxLines: 2,
                                    TextSpan(
                                      children: [
                                        TextSpan(
                                          text: snapshot.data,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: context.fontSize(FontSize.small),
                                          ),
                                        ),
                                        TextSpan(
                                          text:
                                            '  ${visibleUpcoming[i].binTypes.notificationIcon}  ${visibleUpcoming[i].binTypes.label}',
                                        ),
                                      ],
                                    ),
                                    style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                                      color: colors.textSecondary,
                                      letterSpacing: 1.5,
                                      fontSize: context.fontSize(FontSize.small),
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    )
                  ],
                ],
              )
              : SectionCard(
                title: "Upcoming",
                children: [
                   Container (
                    //margin: context.padding(PaddingSize.small),
                    alignment: Alignment.center,
                    padding: EdgeInsets.symmetric(vertical: context.padding(PaddingSize.large).vertical * 2,),
                    margin: EdgeInsets.only(top: context.padding(PaddingSize.medium).top),
                    child: const Text('No upcoming items'),
                  ), 
                ]
              ),

            ],
          ),
        )

      ),
    );
  }
}

/*

 ElevatedButton(
  onPressed: () async {
    await NotificationService.instance.debugPending();
    await NotificationService.instance.showTestNotification();
    await NotificationService.instance.debugExactAlarmPermission();
    await NotificationService.instance.scheduleDebugNotification(
      DateTime.now().add(const Duration(minutes: 2)),
    );
  },
  child: Text('Check pending notifications', style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: colors.accent),),
)

ElevatedButton(
  onPressed: () async {
    await NotificationService.instance.showGroupSummaryTest();
  },
  child: const Text('Test notification grouping'),
),

*/
