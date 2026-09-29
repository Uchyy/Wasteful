import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:wasteful/core/constants/bin_types.dart';
import 'package:wasteful/core/constants/reminder_timing.dart';
import 'package:wasteful/core/extensions/responsive_font.dart';
import 'package:wasteful/core/extensions/responsive_padding.dart';
import 'package:wasteful/core/theme/app_colors.dart';
import 'package:wasteful/core/utils/getOrdinalDate.dart';
import 'package:wasteful/core/widgets/app_bar.dart';
import 'package:wasteful/core/widgets/section_wrapper.dart';
import 'package:wasteful/data/model/schedule.dart';
import 'package:wasteful/data/repository/schedule_repository.dart';
import 'package:wasteful/features/pizzaz/widget/pizzaz_animation.dart';

class Pizzaz extends StatefulWidget {
  final Schedule schedule;

  const Pizzaz({
    super.key,
    required this.schedule,
  });

  @override
  State<Pizzaz> createState() => _PizzazState();
}

class _PizzazState extends State<Pizzaz> {
  late bool _takenOut;

  @override
  void initState() {
    super.initState();
    _takenOut = _isTakenOutForCurrentCollection();
  }

  bool _isTakenOutForCurrentCollection() {
    final lastTakenOut = widget.schedule.lastTakenOut;

    if (lastTakenOut == null) {
      return false;
    }

    final collectionDate = widget.schedule.nextCollectionDate();

    final takenOutDate = DateTime(
      lastTakenOut.year,
      lastTakenOut.month,
      lastTakenOut.day,
    );

    final targetDate = DateTime(
      collectionDate.year,
      collectionDate.month,
      collectionDate.day,
    );

    return takenOutDate == targetDate;
  }

  Future<void> _markAsTakenOut() async {
    if (_takenOut) return;

    final updatedSchedule = widget.schedule.copyWith(
      lastTakenOut: DateTime.now(),
    );

    if (kIsWeb) {  setState(() {
      _takenOut = true;
    });return;};

    final repository = ScheduleRepository();

    await repository.updateSchedule(
      widget.schedule.addressId,
      updatedSchedule,
    );

    if (!mounted) return;

    setState(() {
      _takenOut = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final size = MediaQuery.sizeOf(context);
    final width = size.width;
    final height = size.height;
    final repo = ScheduleRepository();
    final schedule = widget.schedule;

    final heroHeight = (height * 0.35).clamp(360.0, 500.0);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: const CustomAppBar(
        title: '',
        showBack: true,
      ),
      body: SingleChildScrollView(
        padding: context.padding(PaddingSize.medium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // ---------------------------------------------------------
            // Animation / Ready section
            // ---------------------------------------------------------
            SizedBox(
              height: heroHeight,
              width: double.infinity,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Image.asset(
                      'assets/images/pizzaz2.png',
                      fit: BoxFit.cover,
                    ),
                  ),

                  Positioned(
                    top: heroHeight * 0.04,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        width: (width * 0.7).clamp( 260.0, 340.0, ),
                        height: heroHeight * 0.76,
                        padding: context.padding( PaddingSize.small, ),
                        decoration: BoxDecoration(
                          color: colors.background,
                          borderRadius:BorderRadius.circular(30),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              _takenOut ? 'Done!' : 'Ready?',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.displayLarge!.copyWith(
                                color: _takenOut ? Colors.green : colors.accent,
                                fontWeight: FontWeight.w900,
                                fontSize: context.fontSize( FontSize.extraLarge, ) * 1.5,
                                letterSpacing: 2.5,
                              ),
                            ),

                            const SizedBox(height: 10),

                            Text(
                              _takenOut ? 'Nice! This bin has\nbeen taken out.' : 'Ready to mark this bin\nas taken out?',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodySmall!.copyWith(
                                color: colors.textPrimary,
                                fontWeight: FontWeight.w300,
                                fontSize: context.fontSize( FontSize.large,),
                              ),
                            ),
                            const SizedBox(height: 20),

                            Flexible(
                              child: PizzazAnimation(
                                child: Image.asset(
                                  'assets/images/pizzaz_bin.png',
                                  width: (width * 0.38).clamp( 120.0, 160.0,),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // ---------------------------------------------------------
            // Schedule information
            // ---------------------------------------------------------
            _takenOut 
              ? SectionCard(
                  children: [
                    Text(
                      'Next collection',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        letterSpacing: 1.5,
                        color: colors.textPrimary,
                        fontSize: context.fontSize( FontSize.normal,),
                        fontWeight:FontWeight.w300,
                      ),
                    ),

                    ListTile(
                      leading: Icon(
                        Icons.calendar_view_month_outlined,
                        size: context.fontSize(FontSize.extraLarge,),
                      ),
                      title: Text(
                        '${weekdayName(schedule.nextCollectionDate())},  ${getOrdinalDate( schedule.nextCollectionDate() )}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          letterSpacing: 1.5,
                          color: colors.textPrimary,
                          fontSize: context.fontSize( FontSize.small,),
                          fontWeight:FontWeight.w900,
                        ),
                      ),
                      subtitle: Text( schedule.repeatInterval.name),
                    ),
                  ],
                )
              : SectionCard(
                  children: [
                    ListTile(
                      leading: Icon(
                        Icons.calendar_month_outlined,
                        size: context.fontSize(FontSize.extraLarge,),
                      ),
                      title: Text(
                        "${schedule.binTypes.label} waste",
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontSize: context.fontSize(FontSize.normal,),
                          letterSpacing: 1.5,
                          color: colors.textMuted,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      subtitle: FutureBuilder<String>(
                        future: repo.getAddressLabel( schedule.addressId, ),
                        builder: (context, snapshot) {
                          return Text(
                            snapshot.data ?? '',
                            maxLines: 1,
                            overflow:TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              letterSpacing: 1.5,
                              color: colors.textPrimary,
                              fontSize: context.fontSize(FontSize.normal,),
                              fontWeight:FontWeight.w800,
                            ),
                          );
                        },
                      ),
                    ),

                    ListTile(
                      leading: Icon(
                        Icons.calendar_month_outlined,
                        size: context.fontSize(FontSize.extraLarge,),
                      ),
                      title: Text(
                        schedule.reminderTiming == ReminderTiming.eveningBefore ? 'Tomorrow' : 'Today',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          letterSpacing: 1.5,
                          color: colors.textPrimary,
                          fontSize: context.fontSize( FontSize.normal,),
                          fontWeight:FontWeight.w900,
                        ),
                      ),
                      subtitle: Text(
                        '${weekdayName(schedule.nextCollectionDate())},  ${getOrdinalDate( schedule.nextCollectionDate() )}',
                      ),
                    ),
                  ],
                ),
            const SizedBox(height: 16),

            // ---------------------------------------------------------
            // Mark as taken out
            // ---------------------------------------------------------
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _takenOut ? null : _markAsTakenOut,
                icon: Icon( _takenOut ? Icons.check_circle: Icons.check_circle_outline,),
                label: Text(
                  _takenOut ? 'Taken out' : 'Mark as taken out',
                ),
                style: ButtonStyle(
                  backgroundColor: WidgetStatePropertyAll<Color>( _takenOut ? Colors.green: colors.accent,),
                  foregroundColor: WidgetStatePropertyAll<Color>( colors.inverseBackground,),
                ),
              ),
            ),

            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: Theme.of(context).textTheme.bodySmall!.copyWith(color: colors.textMuted,),
              ),
            ),

            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  String weekdayName(DateTime date) {
    const weekdays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];

    return weekdays[date.weekday - 1];
  }
}