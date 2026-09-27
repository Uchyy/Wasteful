import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'package:wasteful/app.dart';
import 'package:wasteful/notifications/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Configure the database before anything accesses it.
  if (kIsWeb) {
    databaseFactory = databaseFactoryFfiWeb;
  }

  if (!kIsWeb) {

  }
  
  await NotificationService.instance.initialize();
  await NotificationService.instance.ensurePermission();

  runApp(
    const ProviderScope(
      child: WastefulApp(),
    ),
  );
}