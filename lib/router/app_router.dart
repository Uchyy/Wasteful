// router/app_router.dart
import 'package:go_router/go_router.dart';
import 'package:wasteful/core/widgets/shell.dart';
import 'package:wasteful/data/model/schedule.dart';
import 'package:wasteful/features/schedule/add_schedule.dart';
import 'package:wasteful/features/schedule/edit_schedule.dart';
import 'package:wasteful/features/settings/app/notifications.dart';
import 'package:wasteful/features/settings/help_and_info/about_wasteful.dart';
import 'package:wasteful/features/settings/help_and_info/find_my_council.dart';
import 'package:wasteful/features/settings/help_and_info/help.dart';
import 'package:wasteful/features/settings/help_and_info/privacy_policy.dart';
import 'package:wasteful/features/settings/help_and_info/terms_of_service.dart';
import 'package:wasteful/features/settings/schedules/manage_schedules.dart';
import '../features/splash/splash_screen.dart';

class AppRoutes {
  AppRoutes._();
  static const splash = '/';
  static const home = '/home';
  static const addSchedule = '/add-schedule';
  static const manageSchedules = '/manage-schedules';
  static const findCouncil = '/find-council';
  static const help = '/help';
  static const privacy = '/privacy';
  static const about = '/about';
  static const termsOfService = '/terms-of-service';
  static const notification = '/notification';
  static const editSchedule = '/editSchedule';
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
    GoRoute(
      path: AppRoutes.manageSchedules,
      builder: (context, state) => const ManageSchedulesScreen(),
    ),
    GoRoute(
      path: AppRoutes.findCouncil,
      builder: (context, state) => const FindMyCouncilScreen(),
    ),
    GoRoute(
      path: AppRoutes.help,
      builder: (context, state) => const HelpScreen(),
    ),
    GoRoute(
      path: AppRoutes.privacy,
      builder: (context, state) => const PrivacyPolicyScreen(),
    ),
    GoRoute(
      path: AppRoutes.about,
      builder: (context, state) => const AboutWastefulScreen(),
    ),
    GoRoute(
      path: AppRoutes.termsOfService,
      builder: (context, state) => const TermsOfServiceScreen(),
    ),
    GoRoute(
      path: AppRoutes.notification,
      builder: (context, state) => const NotificationsScree(),
    ),
    GoRoute(
      path: AppRoutes.editSchedule,
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>;
        return EditScheduleScreen(
          addressId: extra['addressId'] as String,
          schedule: extra['schedule'] as Schedule,
        );
      },
    ),
  ],
);