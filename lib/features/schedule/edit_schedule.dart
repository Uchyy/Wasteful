// features/settings/schedules/edit_schedule_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wasteful/core/extensions/responsive_padding.dart';
import 'package:wasteful/core/widgets/app_bar.dart';
import 'package:wasteful/core/widgets/schedule_form.dart';
import 'package:wasteful/data/model/schedule.dart';
import 'package:wasteful/features/home/home_controller.dart';

class EditScheduleScreen extends ConsumerStatefulWidget {
  final String addressId;
  final Schedule schedule;

  const EditScheduleScreen({
    super.key,
    required this.addressId,
    required this.schedule,
  });

  @override
  ConsumerState<EditScheduleScreen> createState() => _EditScheduleScreenState();
}

class _EditScheduleScreenState extends ConsumerState<EditScheduleScreen> {
  bool _isSaving = false;

  Future<void> _handleSubmit(String addressId, Schedule schedule) async {
    setState(() => _isSaving = true);

    try {
      ref.read(addressesProvider.notifier).updateSchedule(addressId, schedule);
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save changes: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: "Edit schedule", showBack: true),
      body: Padding(
        padding: context.padding(PaddingSize.medium),
        child: ScheduleForm(
          initialSchedule: widget.schedule,
          initialAddressId: widget.addressId,
          submitLabel: "Save changes",
          isSaving: _isSaving,
          onSubmit: _handleSubmit,
        ),
      ),
    );
  }
}