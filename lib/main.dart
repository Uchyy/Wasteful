import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wasteful/app.dart';
import 'package:wasteful/data/repository/schedule_repository.dart';
import 'package:wasteful/notifications/notification_service.dart';
import 'package:wasteful/router/app_router.dart';

final navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await NotificationService.instance.initialize(
    onNotificationTap: _handleNotificationTap,
  );

  await NotificationService.instance.ensurePermission();

  runApp(
    const ProviderScope(
      child: WastefulApp(),
    ),
  );
}


Future<void> _handleNotificationTap(String? payload) async {
  if (payload == null || payload.isEmpty) return;
  final parts = payload.split('_');
  if (parts.length != 2) return;

  final scheduleId = parts[1];

  final repository = ScheduleRepository();
  final schedule = await repository.getSchedule(scheduleId);

  if (schedule == null) return;

  appRouter.push( AppRoutes.pizzaz,
    extra: { 'schedule': schedule, },
  );
}