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

  Future<void> addSchedule( String addressId, Schedule schedule, ) async {
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

  Future<void> updateSchedule( String addressId, Schedule schedule,) async {
    final oldSchedule =
        await repository.getSchedule(schedule.id);

    await repository.updateSchedule(
      addressId,
      schedule,
    );

    await _tryNotificationOperation(
      () async {
        if (oldSchedule != null) {
          await notificationScheduler.cancelReminder(
            oldSchedule,
          );
        }

        await notificationScheduler.scheduleReminder(
          schedule,
        );
      },
    );
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

  Future<void> _tryNotificationOperation( Future<void> Function() operation, ) async {
    try {
      await operation();
    } catch (error, stackTrace) {
      _logNotificationError(
        error,
        stackTrace,
      );
    }
  }

  void _logNotificationError( Object error,StackTrace stackTrace, ) {
    print('Notification error: $error');
    print(stackTrace);
  }
}