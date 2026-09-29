import 'package:flutter/material.dart';
import 'package:wasteful/core/constants/bin_types.dart';
import 'package:wasteful/core/constants/reminder_timing.dart';
import 'package:wasteful/data/model/schedule.dart';
import 'package:wasteful/data/repository/schedule_repository.dart';

class NotificationSchedule {
  NotificationSchedule(this.schedule);

  final Schedule schedule;
  final repo = ScheduleRepository();

  int get id => schedule.notificationId;

  Future<String> get addressLabel => repo.getAddressLabel(schedule.addressId);

  String get groupKey => schedule.addressId;

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

  Future<String> get title async {
    final address = await addressLabel;
    return 'Bin day st $address';
  }

  int get notificationGroupId {
    final key = 'group_$groupKey';

    var hash = 0;
    for (final codeUnit in key.codeUnits) {
      hash = ((hash << 5) - hash + codeUnit) & 0x7fffffff;
    }

    return hash;
  }

  String get body => schedule.reminderTiming == ReminderTiming.eveningBefore 
    ? '${schedule.binTypes.notificationIcon} ${schedule.binTypes.label} goes out tomorrow ${schedule.binTypes.notificationIcon}' : '${schedule.binTypes.notificationIcon} ${schedule.binTypes.label} goes out today ${schedule.binTypes.notificationIcon}';

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