import 'package:wasteful/data/repository/schedule_repository.dart';
import 'package:wasteful/data/repository/settings_repository.dart';
import 'package:wasteful/notifications/schedule_notification_scheduler.dart';

class NotificationSyncService {
  NotificationSyncService({
    required this.repository,
    required this.settingsRepository,
    required this.scheduler,
  });

  final ScheduleRepository repository;
  final SettingsRepository settingsRepository;
  final ScheduleNotificationScheduler scheduler;

  Future<void> sync() async {
    final schedules = await repository.getActiveSchedules();

    final defaultTime = await settingsRepository.getDefaultNotificationTime();

    await scheduler.sync(
      schedules,
      defaultTime: defaultTime,
    );
  }
}