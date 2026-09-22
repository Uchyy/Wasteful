import 'package:flutter/material.dart';
import 'package:wasteful/core/constants/reminder_timing.dart';
import 'package:wasteful/data/model/schedule.dart';
import 'package:wasteful/data/repository/schedule_repository.dart';

import 'notification_service.dart';

class ScheduleNotificationScheduler {
  ScheduleNotificationScheduler({
    required this.notificationService,
  });

  final NotificationService notificationService;

  static const TimeOfDay defaultNotificationTime = TimeOfDay(
    hour: 20,
    minute: 0,
  );

  Future<void> scheduleReminder( Schedule schedule, { TimeOfDay? defaultTime,}) async {
    if (schedule.isArchived) {
      debugPrint('NOTIFICATION: schedule ${schedule.id} is archived');
      return;
    }

    final collectionDate = schedule.reminderTiming == ReminderTiming.morningOf && schedule.isCollectionToday
        ? DateTime(
            DateTime.now().year,
            DateTime.now().month,
            DateTime.now().day,
          )
        : schedule.nextCollectionDate();

    final repository = ScheduleRepository();
    final label = await repository.getAddressLabel(schedule.addressId);

    final reminderDate = _reminderDate( collectionDate, schedule.reminderTiming,);

    final notificationTime = schedule.notificationTime ?? defaultTime ??defaultNotificationTime;

    final notificationDate = DateTime(
      reminderDate.year,
      reminderDate.month,
      reminderDate.day,
      notificationTime.hour,
      notificationTime.minute,
    );

    final now = DateTime.now();

    debugPrint('--- NOTIFICATION DEBUG ---');
    debugPrint('Schedule: ${schedule.id}');
    debugPrint('Address: $label');
    debugPrint('Collection: $collectionDate');
    debugPrint('Timing: ${schedule.reminderTiming}');
    debugPrint('Reminder date: $reminderDate');
    debugPrint('Notification time: $notificationTime');
    debugPrint('Notification date: $notificationDate');
    debugPrint('Now: $now');
    debugPrint(
      'Will schedule: ${notificationDate.isAfter(now)}',
    );

    if (!notificationDate.isAfter(now)) {
      debugPrint('NOTIFICATION SKIPPED: notification time has passed');
      return;
    }

    final id = notificationId(
      schedule.id,
      collectionDate,
    );

    debugPrint('Scheduling notification ID: $id');

    await notificationService.schedule(
  id: id,
  title: _title(schedule.reminderTiming, label),
  body: _body(schedule),
  dateTime: notificationDate,
  payload: schedule.id,
);

debugPrint('NOTIFICATION SCHEDULED SUCCESSFULLY');

final pending = await notificationService.pending();

final exists = pending.any((notification) => notification.id == id);

debugPrint(
  'REAL NOTIFICATION STILL PENDING: $exists',
);

for (final notification in pending) {
  debugPrint(
    'PENDING -> '
    'id=${notification.id}, '
    'title=${notification.title}, '
    'body=${notification.body}, '
    'payload=${notification.payload}',
  );
}
  }

  Future<void> cancelReminder(Schedule schedule) async {
    final collectionDate = schedule.nextCollectionDate();

    await notificationService.cancel(
      notificationId(
        schedule.id,
        collectionDate,
      ),
    );
  }

  Future<void> sync( List<Schedule> schedules, { TimeOfDay? defaultTime,}) async {
    for (final schedule in schedules) {
      await scheduleReminder(
        schedule,
        defaultTime: defaultTime,
      );
    }
  }

  DateTime _reminderDate( DateTime collectionDate, ReminderTiming timing,) {
    switch (timing) {
      case ReminderTiming.eveningBefore:
        return _addDays(collectionDate, -1);

      case ReminderTiming.morningOf:
        return collectionDate;
    }
  }

  String _title(ReminderTiming timing, String addressLabel) {
    
    switch (timing) {
      case ReminderTiming.eveningBefore:
        return 'Bin collection tomorrow 🔶 $addressLabel';

      case ReminderTiming.morningOf:
        return 'Bin collection today 🔶 $addressLabel';
    }
  }

  String _body(Schedule schedule) {
    return '${schedule.binTypes.name} collection is '
        '${schedule.reminderTiming == ReminderTiming.eveningBefore ? 'tomorrow' : 'today'}.';
  }

  static int notificationId( String scheduleId, DateTime collectionDate, ) {
    final value ='$scheduleId-${collectionDate.year}-${collectionDate.month}-${collectionDate.day}';

    var hash = 0;

    for (final codeUnit in value.codeUnits) {
      hash = ((hash << 5) - hash + codeUnit) & 0x7fffffff;
    }

    return hash;
  }


  DateTime _addDays( DateTime date, int days,) {
    return DateTime(
      date.year,
      date.month,
      date.day + days,
    );
  }
}