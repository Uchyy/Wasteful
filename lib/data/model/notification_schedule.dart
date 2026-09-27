import 'package:flutter/material.dart';
import 'package:wasteful/core/constants/bin_types.dart';
import 'package:wasteful/core/constants/reminder_timing.dart';
import 'package:wasteful/data/model/schedule.dart';

class NotificationSchedule {
  NotificationSchedule(this.schedule);

  final Schedule schedule;

  int get id => schedule.notificationId;

  String get payload => schedule.notificationKey;

  DateTime get dateTime {

    final collectionDate = _collectionDate;
    final reminderDate = schedule.reminderTiming == ReminderTiming.eveningBefore ? _addDays(collectionDate, -1) : collectionDate;
    final time = schedule.notificationTime ?? const TimeOfDay(  hour: 20,  minute: 0, );

    return DateTime(
      reminderDate.year,
      reminderDate.month,
      reminderDate.day,
      time.hour,
      time.minute,
    );
  }

  String get title {

    switch (schedule.reminderTiming) {
      case ReminderTiming.eveningBefore:
        return 'Bin collection tomorrow';
      case ReminderTiming.morningOf:
        return 'Bin collection today';
    }
  }

  String get body => '${schedule.binTypes.notificationIcon} ${schedule.binTypes.label} ${schedule.binTypes.notificationIcon}';

  DateTime get _collectionDate {
    if (schedule.reminderTiming == ReminderTiming.morningOf && schedule.isCollectionToday) {
      final now = DateTime.now();

      return DateTime(
        now.year,
        now.month,
        now.day,
      );
    }

    return schedule.nextCollectionDate();
  }

  DateTime _addDays(DateTime date, int days) {
    return DateTime(
      date.year,
      date.month,
      date.day + days,
    );
  }
}