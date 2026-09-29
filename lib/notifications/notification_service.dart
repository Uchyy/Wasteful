import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:wasteful/data/model/notification_schedule.dart';
import 'package:wasteful/data/repository/schedule_repository.dart';

class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();
  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  final repository = ScheduleRepository();

  static const String _channelId = 'bin_collection';
  static const String _channelName = 'Bin collection';
  static const String _channelDescription = 'Reminders for upcoming bin collections.';

  Future<void> initialize({ void Function(String? payload)? onNotificationTap, }) async {
    tz.initializeTimeZones();

    final timezone = await FlutterTimezone.getLocalTimezone();

    tz.setLocalLocation( tz.getLocation(timezone.identifier), );
    const androidSettings = AndroidInitializationSettings(  '@mipmap/ic_launcher',);
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(
      settings: settings,
      onDidReceiveNotificationResponse: (response) {
        onNotificationTap?.call(response.payload);
      },
    );
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

  Future<void> schedule({required int id, required String title,required String body, required DateTime dateTime, String? payload, required String groupKey, }) async {

    final scheduledDate = tz.TZDateTime.from( dateTime, tz.local,);

    debugPrint('SYSTEM NOW: ${DateTime.now()}');
    debugPrint('TZ NOW: ${tz.TZDateTime.now(tz.local)}');
    debugPrint('SCHEDULED DATE: $scheduledDate');
    debugPrint('TZ LOCATION: ${tz.local.name}');

    await _plugin.zonedSchedule(id: id, title: title, body: body, scheduledDate: scheduledDate, notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDescription,
          importance: Importance.high,
          priority: Priority.high,
          icon:  '@mipmap/ic_launcher',
          groupKey: groupKey,
         // styleInformation: 
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
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
          icon: '@mipmap/ic_launcher',
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

  Future<void> rescheduleAll() async {
    
    await cancelAll();
    final schedules = await repository.getActiveSchedules();

    for (final schedule in schedules) {
      final notification = NotificationSchedule(schedule);

      await this.schedule(
        id: notification.id,
        title: await notification.title,
        body: notification.body,
        dateTime: notification.dateTime,
        payload: notification.payload,
        groupKey: notification.groupKey
      );
    }
  }

  Future<void> showGroupSummary({ required int id, required String title, required String groupKey}) async {
    await _plugin.show(
      id: id,
      title: title,
      body: 'Bin collection reminders',
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: _channelDescription,
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
        groupKey: groupKey,
        setAsGroupSummary: true,
        ),
      ),
    );
  } 

  Future<void> showGroupSummaryTest() async {
  const String groupKey = 'com.wasteful.BIN_COLLECTION';
  const String groupChannelId = 'wasteful_grouped_channel';
  const String groupChannelName = 'Grouped bin notifications';
  const String groupChannelDescription =
      'Grouped bin collection notifications';

  // First notification
  const AndroidNotificationDetails firstNotificationAndroidSpecifics =
      AndroidNotificationDetails(
    groupChannelId,
    groupChannelName,
    channelDescription: groupChannelDescription,
    importance: Importance.max,
    priority: Priority.high,
    groupKey: groupKey,
  );

  const NotificationDetails firstNotificationPlatformSpecifics =
      NotificationDetails(
    android: firstNotificationAndroidSpecifics,
  );

  await _plugin.show(
    id: 700001,
    title: 'General waste',
    body: 'Bin collection tomorrow',
    notificationDetails: firstNotificationPlatformSpecifics,
  );

  // Second notification
  const AndroidNotificationDetails secondNotificationAndroidSpecifics =
      AndroidNotificationDetails(
    groupChannelId,
    groupChannelName,
    channelDescription: groupChannelDescription,
    importance: Importance.max,
    priority: Priority.high,
    groupKey: groupKey,
  );

  const NotificationDetails secondNotificationPlatformSpecifics =
      NotificationDetails(
    android: secondNotificationAndroidSpecifics,
  );

  await _plugin.show(
    id: 700002,
    title: 'Recycling waste',
    body: 'Bin collection tomorrow',
    notificationDetails: secondNotificationPlatformSpecifics,
  );

  // Summary notification
  const List<String> lines = <String>[
    'General waste    Bin collection tomorrow',
    'Recycling waste  Bin collection tomorrow',
  ];

  const InboxStyleInformation inboxStyleInformation =
      InboxStyleInformation(
    lines,
    contentTitle: '2 bin collections',
    summaryText: 'Wasteful',
  );

  const AndroidNotificationDetails androidNotificationDetails =
      AndroidNotificationDetails(
    groupChannelId,
    groupChannelName,
    channelDescription: groupChannelDescription,
    styleInformation: inboxStyleInformation,
    groupKey: groupKey,
    setAsGroupSummary: true,
  );

  const NotificationDetails notificationDetails =
      NotificationDetails(
    android: androidNotificationDetails,
  );

  await _plugin.show(
    id: 700000,
    title: 'Bin collections',
    body: '2 bin collection reminders',
    notificationDetails: notificationDetails,
  );
}

  
  Future<void> debugActiveNotifications() async {
    final android = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

    final notifications = await android?.getActiveNotifications();

    debugPrint('========== ACTIVE NOTIFICATIONS ==========');
    debugPrint('COUNT: ${notifications?.length ?? 0}');

    for (final notification in notifications ?? []) {
      debugPrint('------------------------------');
      debugPrint('ID: ${notification.id}');
      debugPrint('TITLE: ${notification.title}');
      debugPrint('BODY: ${notification.body}');
      debugPrint('GROUP: ${notification.groupKey}');
    }

    debugPrint('==========================================');
  }
}


