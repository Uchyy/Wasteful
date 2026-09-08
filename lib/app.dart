// app.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wasteful/core/theme/theme_provider.dart';
import 'core/theme/app_theme.dart';
import 'router/app_router.dart';

class WastefulApp extends ConsumerWidget {
  const WastefulApp({super.key});


  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: 'Wasteful',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode, // switch to a Riverpod provider once dark-mode toggle is built
      routerConfig: appRouter,
    );
  }
}