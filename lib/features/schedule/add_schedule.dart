// features/add_schedule/add_schedule_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wasteful/core/extensions/responsive_padding.dart';
import 'package:wasteful/core/widgets/app_bar.dart';
import 'package:wasteful/core/widgets/app_snackbar.dart';
import 'package:wasteful/core/widgets/schedule_form.dart';
import 'package:wasteful/data/model/schedule.dart';
import 'package:wasteful/data/repository/schdeule_provider.dart' hide addressesProvider;
import 'package:wasteful/features/home/home_controller.dart';
import 'package:wasteful/router/app_router.dart';

class AddScheduleScreen extends ConsumerStatefulWidget {
  const AddScheduleScreen({super.key});

  @override
  ConsumerState<AddScheduleScreen> createState() => _AddScheduleScreenState();
}

class _AddScheduleScreenState extends ConsumerState<AddScheduleScreen> {
  bool _isSaving = false;

  Future<void> _handleSubmit(String addressId, Schedule schedule) async {
    setState(() => _isSaving = true);

    try {
      final repository = ref.read(scheduleRepositoryProvider);
      await repository.addSchedule(addressId, schedule);
      ref.invalidate(addressesProvider);
      if (mounted) {
        context.go(AppRoutes.home); // navigate to Home directly, not pop
      }
    } catch (e) {
      if (mounted) {
        showAppSnackBar(context, message: 'Failed to save schedule: $e', type: SnackType.error);
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: "What are we tracking", showBack: false),
      body: Padding(
        padding: context.padding(PaddingSize.medium),
        child: ScheduleForm(
          submitLabel: "Add schedule",
          isSaving: _isSaving,
          onSubmit: _handleSubmit,
        ),
      ),
    );
  }
}