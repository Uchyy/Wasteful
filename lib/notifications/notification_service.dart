import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();
  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();

  static const String _channelId = 'bin_collection';
  static const String _channelName = 'Bin collection';
  static const String _channelDescription = 'Reminders for upcoming bin collections.';

  Future<void> initialize() async {
    tz.initializeTimeZones();

    final timezone = await FlutterTimezone.getLocalTimezone();

    tz.setLocalLocation( tz.getLocation(timezone.identifier), );
    const androidSettings = AndroidInitializationSettings(  '@mipmap/ic_launcher',);
    const iosSettings = DarwinInitializationSettings();

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(settings: settings);
  }

  Future<bool> requestPermission() async {

    final android = _plugin .resolvePlatformSpecificImplementation< AndroidFlutterLocalNotificationsPlugin>();
    final ios = _plugin.resolvePlatformSpecificImplementation<  IOSFlutterLocalNotificationsPlugin>();
    final androidGranted = await android?.requestNotificationsPermission() ?? true;

    final iosGranted =await ios?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    ) ?? true;

    return androidGranted && iosGranted;
  }

  Future<void> schedule({required int id, required String title,required String body, required DateTime dateTime, String? payload, }) async {

    final scheduledDate = tz.TZDateTime.from( dateTime, tz.local,);

    debugPrint('SYSTEM NOW: ${DateTime.now()}');
    debugPrint('TZ NOW: ${tz.TZDateTime.now(tz.local)}');
    debugPrint('SCHEDULED DATE: $scheduledDate');
    debugPrint('TZ LOCATION: ${tz.local.name}');

    await _plugin.zonedSchedule(id: id, title: title, body: body, scheduledDate: scheduledDate, notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDescription,
          importance: Importance.high,
          priority: Priority.high,
          icon:  '@mipmap/ic_launcher',
         // styleInformation: 
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexact,
      payload: payload,
    );
  }

  Future<void> cancel(int id) async {
    await _plugin.cancel(id: id);
  }

  Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }

  Future<List<PendingNotificationRequest>> pending() {
    return _plugin.pendingNotificationRequests();
  }

  Future<bool> ensurePermission() async {
    final android = _plugin .resolvePlatformSpecificImplementation< AndroidFlutterLocalNotificationsPlugin>();

    final ios = _plugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();

    final androidEnabled = await android?.areNotificationsEnabled() ?? true;

    if (!androidEnabled) {
      return await android?.requestNotificationsPermission() ?? false;
    }

    final iosPermissions = await ios?.checkPermissions();

    if (iosPermissions != null && !iosPermissions.isEnabled) {
      return await ios?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          ) ??
          false;
    }

    return true;
  }


  Future<void> debugPending() async {
    final notifications = await _plugin.pendingNotificationRequests();
    print('Pending notifications: ${notifications.length}');

    for (final notification in notifications) {
      print(
        '${notification.id}: '
        '${notification.title} - '
        '${notification.body}',
      );
    }
  }

  Future<void> showTestNotification() async {
    await _plugin.show(
      id: 999999,
      title: 'Wasteful test',
      body: 'If you can see this, notifications are working.',
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDescription,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }

  Future<void> scheduleDebugNotification(DateTime dateTime) async {
    await _plugin.zonedSchedule(
      id: 888888,
      title: 'Scheduled test',
      body: 'This should fire at $dateTime',
      scheduledDate: tz.TZDateTime.from(dateTime, tz.local),
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDescription,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@drawable/ic_stat_wasteful_icon',
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }

  Future<void> debugExactAlarmPermission() async {
    final android = _plugin.resolvePlatformSpecificImplementation< AndroidFlutterLocalNotificationsPlugin>();
    final canSchedule = await android?.canScheduleExactNotifications();

    debugPrint('CAN SCHEDULE EXACT: $canSchedule');
  }


}