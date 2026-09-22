import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wasteful/core/constants/bin_types.dart';
import 'package:wasteful/core/extensions/responsive_font.dart';
import 'package:wasteful/core/theme/app_colors.dart';
import 'package:wasteful/core/widgets/app_confirm_dialog.dart';
import 'package:wasteful/data/model/schedule.dart';
import 'package:wasteful/features/home/home_controller.dart';
import 'package:wasteful/router/app_router.dart';

class ScheduleRow extends ConsumerWidget {
  final String addressId;
  final Schedule schedule;

  const ScheduleRow({required this.addressId, required this.schedule});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;

    return Dismissible(
      key: ValueKey(schedule.id),
      direction: DismissDirection.endToStart, // swipe left to reveal delete
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.redAccent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(Icons.delete_outline, color: colors.background),
      ),
      confirmDismiss: (direction) => AppConfirmDialog.show(
        context,
        title: 'Delete schedule?',
        message: 'This will remove the ${schedule.binTypes.label} schedule.',
        confirmLabel: 'Delete',
        type: ConfirmDialogType.danger,
        icon: Icons.delete_outline,
        onConfirm: () => ref.read(addressesProvider.notifier).removeScheduleFromAddress(addressId, schedule.id),
      ),
      onDismissed: (direction) {},
      child: ListTile(
        onTap: () => context.push(
          AppRoutes.editSchedule,
          extra: {'addressId': addressId, 'schedule': schedule},
        ),
        leading: schedule.binTypes.getfallBackIcon(size: context.fontSize(FontSize.extraLarge)),
        title: Text(
          schedule.binTypes.label,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        subtitle: Text(
          '${_weekdayName(schedule.collectionWeekday)}, ${schedule.repeatInterval.name}',
          style: TextStyle(fontSize: 12, color: colors.textMuted),
        ),
        trailing: Icon(Icons.chevron_right, color: colors.textMuted),
      ),
    );
  }

  String _weekdayName(int weekday) {
    const names = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return names[weekday - 1];
  }
}