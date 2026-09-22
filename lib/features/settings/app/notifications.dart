// features/settings/notification_settings_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wasteful/core/constants/reminder_timing.dart';
import 'package:wasteful/core/extensions/responsive_padding.dart';
import 'package:wasteful/core/theme/app_colors.dart';
import 'package:wasteful/core/widgets/app_bar.dart';
import 'package:wasteful/core/widgets/timing_option.dart';
import 'package:wasteful/features/settings/controllers/settings_controller.dart';

class NotificationSettingsScreen extends ConsumerWidget {
  const NotificationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final timing = ref.watch(reminderTimingProvider);
    final defaultTime = ref.watch(defaultNotificationTimeProvider); // TimeOfDay

    return Scaffold(
      appBar: CustomAppBar(showBack: true, title: "Notifications"),
      body: SingleChildScrollView(
        padding: context.padding(PaddingSize.medium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'These settings apply to every schedule by default. '
              'You can still set a different time for an individual schedule '
              'when adding or editing it.',
             style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),

            Text('When to remind you', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),

            TimingOption(
              title: 'Evening before',
              description: 'Get reminded the night before collection day — gives you time to put bins out.',
              selected: timing == ReminderTiming.eveningBefore,
              onTap: () => ref.read(reminderTimingProvider.notifier).update(ReminderTiming.eveningBefore),
            ),
            const SizedBox(height: 8),

            TimingOption(
              title: 'Morning of',
              description: 'Get reminded the same morning as collection day.',
              selected: timing == ReminderTiming.morningOf,
              onTap: () => ref.read(reminderTimingProvider.notifier).update(ReminderTiming.morningOf),
            ),

            const SizedBox(height: 28),
            Text('Default reminder time', style: Theme.of(context).textTheme.titleMedium),

            const SizedBox(height: 8),

            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: colors.border),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  
                  Text(
                    timing == ReminderTiming.eveningBefore
                        ? 'Notify at ${defaultTime.format(context)}, the evening before'
                        : 'Notify at ${defaultTime.format(context)}, the morning of',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),

                  TextButton(
                    onPressed: () async {
                      final picked = await showTimePicker(context: context, initialTime: defaultTime);
                      if (picked != null) {
                        ref.read(defaultNotificationTimeProvider.notifier).update(picked);
                      }
                    },
                    child: const Text('Change'),
                  ),

                ],
              ),
            ),

            const SizedBox(height: 20),

            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colors.accent.withAlpha(20),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Icon(Icons.info_outline, size: 18, color: colors.accent),
                  const SizedBox(width: 8),

                  Expanded(
                    child: Text(
                      'A schedule with its own custom reminder time will always use that '
                      'time instead of this default.',
                      style: TextStyle(fontSize: 12, color: colors.textSecondary, height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
