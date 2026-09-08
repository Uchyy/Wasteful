import 'package:go_router/go_router.dart';
import 'package:wasteful/core/widgets/shell.dart';
import 'package:wasteful/features/add_schedule/add_schedule.dart';
import '../features/splash/splash_screen.dart';

class AppRoutes {
  AppRoutes._();
  static const splash = '/';
  static const home = '/home';
  static const addSchedule = '/add-schedule';
  // add as features are built:
  // static const manage = '/manage';
  // static const settings = '/settings';
  // static const help = '/help';
}

final appRouter = GoRouter(
  initialLocation: AppRoutes.splash,
  routes: [
    GoRoute(
      path: AppRoutes.splash,
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: AppRoutes.home,
      builder: (context, state) => const MainShell(),
    ),
    GoRoute(
      path: AppRoutes.addSchedule,
      builder: (context, state) => const AddScheduleScreen(),
    ),

  ],
);