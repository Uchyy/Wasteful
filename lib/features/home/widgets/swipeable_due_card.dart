// features/home/widgets/swipeable_due_cards.dart
import 'package:flutter/material.dart';
import 'package:wasteful/core/constants/bin_types.dart';
import 'package:wasteful/core/constants/reminder_timing.dart';
import 'package:wasteful/core/extensions/responsive_font.dart';
import 'package:wasteful/core/extensions/responsive_padding.dart';
import 'package:wasteful/data/model/schedule.dart';
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
    final height = MediaQuery.of(context).size.height * 0.2;

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

    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(right: context.padding(PaddingSize.small).right, top: context.padding(PaddingSize.small).top, ),
      //padding: context.padding(PaddingSize.small),
      decoration: BoxDecoration(
        color: Color.lerp(primaryBinType.color, Colors.white, 0.8)!,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.border),
      ),

      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [

          Container(
            width: context.fontSize(FontSize.extraLarge) * 5,
            //padding: EdgeInsets.zero,
            height: double.infinity,
            child: primaryBinType.getfallBackIcon(size: context.fontSize(FontSize.extraLarge) * 3),
          ),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              //mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Next collection'.toUpperCase(), 
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    letterSpacing: 1.5, 
                    color: Colors.black, 
                    fontSize: context.fontSize(FontSize.normal),
                    fontWeight: FontWeight.w800
                  ),
                  
                ),

                Text(
                  entry.schedule.reminderTiming == ReminderTiming.eveningBefore  ? 'Tomorrow' : 'Today',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: Colors.black,  fontSize: context.fontSize(FontSize.extraLarge) * 1.2, fontWeight: FontWeight.w900)
                ),

                Text(
                  entry.schedule.binTypes.label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: context.fontSize(FontSize.normal),  letterSpacing: 1.5, color: Colors.black,   fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}