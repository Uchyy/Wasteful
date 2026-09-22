import 'package:flutter/foundation.dart';
import 'package:wasteful/data/model/schedule.dart';
import 'package:wasteful/data/repository/schedule_repository.dart';
import 'package:wasteful/notifications/schedule_notification_scheduler.dart';

class ScheduleService {
  ScheduleService({
    required this.repository,
    required this.notificationScheduler,
  });

  final ScheduleRepository repository;
  final ScheduleNotificationScheduler notificationScheduler;

  Future<void> addSchedule( String addressId, Schedule schedule,) async {
    await repository.addSchedule(
      addressId,
      schedule,
    );

    await _tryNotificationOperation(
      () => notificationScheduler.scheduleReminder(
        schedule,
      ),
    );
  }

Future<void> updateSchedule(
  String addressId,
  Schedule schedule,
) async {
  debugPrint('=== SCHEDULE SERVICE: UPDATE ===');
  debugPrint('Schedule ID: ${schedule.id}');
  debugPrint('Address ID: $addressId');
  debugPrint('New notification time: ${schedule.notificationTime}');
  debugPrint('New reminder timing: ${schedule.reminderTiming}');

  final oldSchedule = await repository.getSchedule(schedule.id);

  debugPrint('OLD SCHEDULE: ${oldSchedule?.id}');
  debugPrint(
    'OLD notification time: ${oldSchedule?.notificationTime}',
  );
  debugPrint(
    'OLD reminder timing: ${oldSchedule?.reminderTiming}',
  );

  await repository.updateSchedule(
    addressId,
    schedule,
  );

  debugPrint('DATABASE UPDATE COMPLETE');

  await _tryNotificationOperation(
    () async {
      if (oldSchedule != null) {
        debugPrint(
          'CANCELLING OLD NOTIFICATION: ${oldSchedule.id}',
        );

        await notificationScheduler.cancelReminder(
          oldSchedule,
        );

        debugPrint('OLD NOTIFICATION CANCEL COMPLETE');
      }

      debugPrint(
        'SCHEDULING NEW NOTIFICATION: ${schedule.id}',
      );

      await notificationScheduler.scheduleReminder(
        schedule,
      );

      debugPrint('NEW NOTIFICATION SCHEDULE COMPLETE');

      final pending = await notificationScheduler.notificationService.pending();

      debugPrint(
        'PENDING NOTIFICATIONS AFTER UPDATE: ${pending.length}',
      );

      for (final notification in pending) {
        debugPrint(
          'PENDING: '
          'id=${notification.id}, '
          'title=${notification.title}, '
          'payload=${notification.payload}',
        );
      }
    },
  );

  debugPrint('=== SCHEDULE SERVICE: UPDATE FINISHED ===');
}

  Future<void> deleteSchedule(String id) async {
    final schedule =  await repository.getSchedule(id);
    await repository.deleteSchedule(id);

    if (schedule == null) {
      return;
    }

    await _tryNotificationOperation(
      () => notificationScheduler.cancelReminder(
        schedule,
      ),
    );
  }

  Future<void> archiveSchedule(String id) async {
    final schedule =  await repository.getSchedule(id);

    await repository.archiveSchedule(id);

    if (schedule == null) {
      return;
    }

    await _tryNotificationOperation(
      () => notificationScheduler.cancelReminder(
        schedule,
      ),
    );
  }

  Future<void> _tryNotificationOperation(
    Future<void> Function() operation,
  ) async {
    try {
      await operation();
    } catch (error, stackTrace) {
      _logNotificationError(
        error,
        stackTrace,
      );
    }
  }

  void _logNotificationError(
    Object error,
    StackTrace stackTrace,
  ) {
    print('Notification error: $error');
    print(stackTrace);
  }
}