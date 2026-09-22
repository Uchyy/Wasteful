// data/repositories/schedule_repository_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wasteful/data/repository/schedule_repository.dart';
import 'package:wasteful/notifications/notification_service.dart';
import 'package:wasteful/notifications/schedule_notification_scheduler.dart';
import 'package:wasteful/notifications/schedule_service.dart';


final scheduleRepositoryProvider = Provider<ScheduleRepository>(
  (ref) => ScheduleRepository(),
);


final scheduleServiceProvider = Provider<ScheduleService>((ref) {
  return ScheduleService(
    repository: ref.read(scheduleRepositoryProvider),
    notificationScheduler: ScheduleNotificationScheduler(
      notificationService: NotificationService.instance,
    ),
  );
});
