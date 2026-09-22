import 'dart:async';

import 'package:wasteful/data/repository/schedule_repository.dart';
import 'package:wasteful/data/repository/settings_repository.dart';
import 'package:wasteful/notifications/notification_service.dart';
import 'package:wasteful/notifications/notification_sync_service.dart';
import 'package:wasteful/notifications/schedule_notification_scheduler.dart';
import 'package:workmanager/workmanager.dart';


const dailyNotificationTask = 'daily_notification_sync';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    try {
      switch (taskName) {
        case dailyNotificationTask:
          await _runNotificationSync();
          return true;

        default:
          return true;
      }
    } catch (error, stackTrace) {
      print('WorkManager error: $error');
      print(stackTrace);

      return false;
    }
  });
}

Future<void> _runNotificationSync() async {
  final notificationService = NotificationService.instance;
  final settingsRepository = SettingsRepository();

  await notificationService.initialize();

  final syncService = NotificationSyncService(
    repository: ScheduleRepository(),
    settingsRepository: settingsRepository,
    scheduler: ScheduleNotificationScheduler(
      notificationService: notificationService,
    ),
  );

  await syncService.sync();
}

class WorkManagerService {
  WorkManagerService._();

  static final instance = WorkManagerService._();

  static const taskName = dailyNotificationTask;
  static const uniqueName = 'wasteful_daily_notification_sync';

  Future<void> initialize() async {
    await Workmanager().initialize(
      callbackDispatcher,
    );
  }

  Future<void> registerDailyTask() async {
    await Workmanager().registerPeriodicTask(
      uniqueName,
      taskName,
      frequency: const Duration(hours: 24),
    );
  }
}