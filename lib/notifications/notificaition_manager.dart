import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:wasteful/data/repository/schedule_repository.dart';
import 'package:wasteful/data/repository/settings_repository.dart';
import 'package:wasteful/notifications/notification_service.dart';
import 'package:wasteful/notifications/notification_sync_service.dart';
import 'package:wasteful/notifications/schedule_notification_scheduler.dart';

class NotificationManager {
  NotificationManager._();

  static final instance = NotificationManager._();
  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  final NotificationService _notificationService = NotificationService.instance;
  final settingsRepository = SettingsRepository();

  late final NotificationSyncService _syncService = NotificationSyncService(
    repository: ScheduleRepository(),
    settingsRepository: settingsRepository,
    scheduler: ScheduleNotificationScheduler(
      notificationService: _notificationService,
    ),
  );

  Future<void> initialize() async {
    await _notificationService.initialize();
  }

  Future<void> sync() async {
    try {
      await _syncService.sync();
    } catch (error, stackTrace) {
      print('Notification sync failed: $error');
      print(stackTrace);
    }
  }

  Future<bool> ensurePermission() async {
   return await _notificationService.ensurePermission();
  }

  Future<void> debugPending() async {
    final notifications = await _plugin.pendingNotificationRequests();

    print(
      'Pending notifications: ${notifications.length}',
    );

    for (final notification in notifications) {
      print(
        '${notification.id}: '
        '${notification.title} - '
        '${notification.body}',
      );
    }
  }
}