import 'package:wasteful/data/model/notification_schedule.dart';
import 'package:wasteful/data/model/schedule.dart';
import 'package:wasteful/data/repository/schedule_repository.dart';
import 'package:wasteful/notifications/notification_service.dart';

class ScheduleService {
  ScheduleService({ required this.repository, required this.notificationService, });

  final ScheduleRepository repository;
  final NotificationService notificationService;

  Future<void> addSchedule( String addressId, Schedule schedule,) async {
    await repository.addSchedule( addressId, schedule, );
    await _scheduleNotification(schedule);
  }

  Future<void> updateSchedule( String addressId, Schedule schedule, ) async {
    final oldSchedule = await repository.getSchedule(schedule.id);
    if (oldSchedule != null) {
      await notificationService.cancel(
        oldSchedule.notificationId,
      );
    }

    await repository.updateSchedule( addressId, schedule,);
    await _scheduleNotification(schedule);
  }

  Future<void> deleteSchedule(String id) async {
    final schedule = await repository.getSchedule(id);
    await repository.deleteSchedule(id);

    if (schedule != null) {
      await notificationService.cancel(
        schedule.notificationId,
      );
    }
  }

  Future<void> _scheduleNotification(Schedule schedule) async {
    final notification = NotificationSchedule(schedule);

    await notificationService.schedule(
      id: notification.id,
      title: await notification.title,
      body: notification.body,
      dateTime: notification.dateTime,
      payload: notification.payload,
      groupKey: notification.groupKey,
    );
  }
}