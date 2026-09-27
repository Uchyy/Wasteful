import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:wasteful/data/repository/settings_repository.dart';
import 'package:wasteful/notifications/notification_service.dart';


class NotificationMacnager {
  NotificationMacnager._();

  static final instance = NotificationMacnager._();
  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  final NotificationService _notificationService = NotificationService.instance;
  final settingsRepository = SettingsRepository();

  Future<void> initialize() async {
    await _notificationService.initialize();
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