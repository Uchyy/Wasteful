// features/home/widgets/swipeable_due_cards.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:popover/popover.dart';
import 'package:wasteful/core/constants/bin_types.dart';
import 'package:wasteful/core/constants/reminder_timing.dart';
import 'package:wasteful/core/extensions/responsive_font.dart';
import 'package:wasteful/core/extensions/responsive_padding.dart';
import 'package:wasteful/core/widgets/section_wrapper.dart';
import 'package:wasteful/data/model/schedule.dart';
import 'package:wasteful/data/repository/schedule_repository.dart';
import 'package:wasteful/features/home/home_controller.dart';
import 'package:wasteful/router/app_router.dart';
import '../../../core/theme/app_colors.dart';

class SwipeableDueCards extends StatefulWidget {
  final List<({Schedule schedule})> entries;

  const SwipeableDueCards({super.key, required this.entries});

  @override
  State<SwipeableDueCards> createState() => _SwipeableDueCardsState();
}

class _SwipeableDueCardsState extends State<SwipeableDueCards> {
  late final PageController _controller;
  int _page = 0;

  @override
  void initState() {
    super.initState();
    _controller = PageController(viewportFraction: 0.85);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.entries.isEmpty) return const SizedBox.shrink();
    final screenHeight = MediaQuery.sizeOf(context).height;
    final height = screenHeight < 500 ? 160.0 : (screenHeight * 0.2).clamp(150.0, 190.0);

    // Single entry doesn't need PageView's multi-card viewport sizing —
    // just show the one card at full width.
    if (widget.entries.length == 1) {
      return SizedBox(
        height: height,
        width: double.infinity,
        child: _DueCard(entry: widget.entries.first),
      );
    }

    return Column(
      children: [
        SizedBox(
          height: height,
          width: double.infinity,
          child: PageView.builder(
            controller: _controller,
            padEnds: false,
            physics: const BouncingScrollPhysics(),
            itemCount: widget.entries.length,
            onPageChanged: (i) => setState(() => _page = i),
            itemBuilder: (context, index) => _DueCard(entry: widget.entries[index]),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(widget.entries.length, (i) {
            final isActive = i == _page;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: isActive ? 16 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: isActive ? context.colors.accent : context.colors.border,
                borderRadius: BorderRadius.circular(3),
              ),
            );
          }),
        ),
      ],
    );
  }
}

class _DueCard extends StatelessWidget {
  final ({Schedule schedule}) entry;
  const _DueCard({required this.entry});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final primaryBinType = entry.schedule.binTypes;
    final repo = ScheduleRepository();
    final size = MediaQuery.sizeOf(context);


    return InkWell(
      onTap: () {
        showPopover(
          backgroundColor: colors.background,
          context: context,
          bodyBuilder: (popoverContext) => SectionCard(
            contentPadding: EdgeInsets.zero,
            margin: EdgeInsets.zero,
            radius: 0,
            depth: 0,
            children: [
              InkWell(
                onTap: () { 
                  Navigator.of(popoverContext).pop();
                  context.push(
                    AppRoutes.editSchedule,
                    extra: {'addressId': entry.schedule.addressId, 'schedule': entry.schedule},
                  );
                },
                child: ListTile(
                  leading: Icon(Icons.edit_calendar_outlined),
                  title: Text(
                    "Edit schedule",
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(
                      color: context.colors.textPrimary,
                      fontSize: context.fontSize(FontSize.small),
                      fontWeight: FontWeight.w900,
                    ),
                  ), 
                ),
              ),

              InkWell(
                onTap: () async {
                  Navigator.of(popoverContext).pop();

                  final container = ProviderScope.containerOf(context);
                  final updatedSchedule = entry.schedule.copyWith(
                    lastTakenOut: DateTime.now(),
                  );

                  await container.read(addressesProvider.notifier).updateSchedule( entry.schedule.addressId, updatedSchedule,);
                  context.push(
                    AppRoutes.pizzaz,
                    extra: {'schedule': entry.schedule},
                  );
                },
                child: ListTile(
                  leading: Icon(Icons.check),
                  title: Text(
                    "Mark as taken out",
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(
                      color: context.colors.textPrimary,
                      fontSize: context.fontSize(FontSize.small),
                      fontWeight: FontWeight.w900,
                    ),
                  ), 
                ),
              )
            ],
          ),
          onPop: () => print('Popover was popped!'),
          direction: PopoverDirection.bottom,
          width: (size.width * 0.55).clamp(180.0, 200.0),
          height: (size.height * 0.09).clamp(130.0, 200.0),
          arrowHeight: 15,
          arrowWidth: 30,
        );
      },
      child: Container(
        width: double.infinity,
        margin: EdgeInsets.only(right: context.padding(PaddingSize.small).right, top: context.padding(PaddingSize.small).top, ),
        padding: EdgeInsetsGeometry.only(right: context.padding(PaddingSize.large).right),
        decoration: BoxDecoration(
          color: Color.lerp(primaryBinType.color, Colors.white, 0.8)!,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: colors.border),
        ),

        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          //mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [

             Expanded(
              flex: 2,
              child: Center(
                child: primaryBinType.getfallBackIcon(
                  size: context.fontSize(FontSize.extraLarge) * 3,
                ),
              ),
            ),

          
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  
                  FutureBuilder<String>(
                    future: repo.getAddressLabel(entry.schedule.addressId),
                    builder: (context, snapshot) {
                      return Text(
                        snapshot.data ?? '',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          letterSpacing: 1.5,
                          color: Colors.black,
                          fontSize: context.fontSize(FontSize.normal),
                          fontWeight: FontWeight.w800,
                        ),
                      );
                    },
                  ),

                  Text(
                    entry.schedule.reminderTiming == ReminderTiming.eveningBefore  ? 'Tomorrow' : 'Today',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: Colors.black,  fontSize: context.fontSize(FontSize.extraLarge) * 1.2, fontWeight: FontWeight.w900)
                  ),

                  Text(
                    entry.schedule.binTypes.label,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: context.fontSize(FontSize.normal),  letterSpacing: 1.5, color: Colors.black,   fontWeight: FontWeight.w500),
                  ),

                  const SizedBox(width: 10,)
                ],
              ),
              
            ),
            
          ],
        ),
      ),
    );
  }
}