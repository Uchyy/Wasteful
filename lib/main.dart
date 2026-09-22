import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

import 'package:wasteful/app.dart';
import 'package:wasteful/data/repository/schedule_repository.dart';
import 'package:wasteful/data/repository/settings_repository.dart';
import 'package:wasteful/notifications/notification_service.dart';
import 'package:wasteful/notifications/notification_sync_service.dart';
import 'package:wasteful/notifications/schedule_notification_scheduler.dart';
import 'package:wasteful/notifications/work_manager_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Configure the database before anything accesses it.
  if (kIsWeb) {
    databaseFactory = databaseFactoryFfiWeb;
  }

  if (!kIsWeb) {
    await NotificationService.instance.initialize();

    await WorkManagerService.instance.initialize();
    await WorkManagerService.instance.registerDailyTask();
    final settingsRepository = SettingsRepository();

    final notificationSyncService = NotificationSyncService(
      repository: ScheduleRepository(),
      settingsRepository: settingsRepository,
      scheduler: ScheduleNotificationScheduler(
        notificationService: NotificationService.instance,
      ),
    );

    try {
      await notificationSyncService.sync();
    } catch (error, stackTrace) {
      print('Startup notification sync failed: $error');
      print(stackTrace);
    }
  }

  runApp(
    const ProviderScope(
      child: WastefulApp(),
    ),
  );
}