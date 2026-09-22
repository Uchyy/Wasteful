// features/add_schedule/widgets/schedule_form.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:wasteful/core/constants/bin_types.dart';
import 'package:wasteful/core/constants/reminder_timing.dart';
import 'package:wasteful/core/constants/repeat_interval.dart';
import 'package:wasteful/core/extensions/responsive_font.dart';
import 'package:wasteful/core/extensions/responsive_padding.dart';
import 'package:wasteful/core/theme/app_colors.dart';
import 'package:wasteful/core/utils/getOrdinalDate.dart';
import 'package:wasteful/core/widgets/app_snackbar.dart';
import 'package:wasteful/core/widgets/timing_option.dart';
import 'package:wasteful/data/model/schedule.dart';
import 'package:wasteful/features/schedule/widgets/add_schedule_dropdown.dart';
import 'package:wasteful/features/schedule/widgets/address_dropdown.dart';
import 'package:wasteful/features/schedule/widgets/date_time.dart';
import 'package:wasteful/features/schedule/widgets/waste_type.dart';
import 'package:wasteful/notifications/notificaition_manager.dart';
import 'package:wasteful/router/app_router.dart';
import 'package:uuid/uuid.dart';


class ScheduleForm extends StatefulWidget {
  /// Pass an existing schedule + its address id to pre-fill for editing.
  /// Leave null for a fresh Add Schedule form.
  final Schedule? initialSchedule;
  final String? initialAddressId;

  final String submitLabel;
  final bool isSaving;
  final Future<bool> Function(String addressId, Schedule schedule) onSubmit;
  

  const ScheduleForm({
    super.key,
    this.initialSchedule,
    this.initialAddressId,
    required this.submitLabel,
    required this.onSubmit,
    this.isSaving = false,
  });

  @override
  State<ScheduleForm> createState() => _ScheduleFormState();
}

class _ScheduleFormState extends State<ScheduleForm> {
  late int? _selectedDay = widget.initialSchedule?.collectionWeekday;
  late ReminderTiming _selectedReminderTiming = widget.initialSchedule?.reminderTiming ?? ReminderTiming.eveningBefore;
  late RepeatInterval? _selectedInterval = widget.initialSchedule?.repeatInterval;
  late BinType? _selectedBinType = widget.initialSchedule?.binTypes;
  late DateTime? _selectedStartDate = widget.initialSchedule?.startDate ?? DateTime.now();
  late String? _selectedAddressId = widget.initialAddressId;
  late TimeOfDay? _notificationTime = widget.initialSchedule?.notificationTime;

  String? _addressError;
  String? _binTypeError;
  String? _dayError;
  String? _intervalError;
  bool _isSubmitting = false;

  bool _validate() {
    setState(() {
      _addressError = _selectedAddressId == null ? 'Please select an address' : null;
      _binTypeError = _selectedBinType == null ? 'Please select a waste type' : null;
      _dayError = _selectedDay == null ? 'Please select a collection day' : null;
      _intervalError = _selectedInterval == null ? 'Please select how often' : null;
    });
    return _addressError == null && _binTypeError == null && _dayError == null && _intervalError == null;
  }

  Future<void> _handleSubmit() async {
   if (!_validate() || _isSubmitting) return;

    setState(() => _isSubmitting = true);
    await NotificationManager.instance.ensurePermission();

    final now = DateTime.now();
    final schedule = Schedule(
      id: widget.initialSchedule?.id ?? const Uuid().v4(),
      addressId: _selectedAddressId!,
      binTypes: _selectedBinType!,
      collectionWeekday: _selectedDay!,
      repeatInterval: _selectedInterval!,
      startDate: _selectedStartDate ?? now,
      notificationTime: _notificationTime,
      reminderTiming: _selectedReminderTiming,
      isArchived: widget.initialSchedule?.isArchived ?? false,
      createdAt: widget.initialSchedule?.createdAt ?? now,
      updatedAt: now,
    );

    final success = await widget.onSubmit(_selectedAddressId!, schedule);

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (success) {
      showAppSnackBar(
        context,
        message: widget.initialSchedule == null ? 'Schedule added' : 'Schedule updated',
        type: SnackType.success,
      );

      context.go(AppRoutes.home);
    } else {
      showAppSnackBar(
        context,
        message: 'Something went wrong. Please try again.',
        type: SnackType.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          TextButton(
            onPressed: () => context.push(AppRoutes.findCouncil),
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              alignment: Alignment.centerLeft,
            ),
            child: RichText(
              text: TextSpan(
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontSize: context.fontSize(FontSize.normal),
                      color: colors.textMuted,
                    ),
                children: [
                  const TextSpan(text: "Not sure of your collection days? "),
                  TextSpan(
                    text: "Find your council",
                    style: TextStyle(
                      color: colors.accent,
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.underline,
                      decorationColor: colors.accent
                    ),
                  ),
                ],
              ),
            ),
          ),

          formAddress(
            context,
            "Address",
            AddressDropdownSchedule(
              selectedId: _selectedAddressId,
              errorText: _addressError,
              onSelected: (id) => setState(() {
                _selectedAddressId = id;
                _addressError = null;
              }),
            ),
          ),

          formAddress(
            context,
            "Waste type",
            hintText: _binTypeError ?? "",
            SizedBox(
              width: double.infinity,
              child: WasteTypeSelector(
                entries: BinType.values,
                initialValue: _selectedBinType,
                onSelected: (type) => setState(() {
                  _selectedBinType = type;
                  _binTypeError = null;
                }),
              ),
            ),
          ),

          formAddress(
            context,
            "Collection day",
            AddScheduleDropdown<int>(
              selectLabel: "collection day",
              initialValue: _selectedDay,
              icon: Icons.calendar_month_outlined,
              items: const [
                AddScheduleItem(value: DateTime.sunday, label: 'Sunday'),
                AddScheduleItem(value: DateTime.monday, label: 'Monday'),
                AddScheduleItem(value: DateTime.tuesday, label: 'Tuesday'),
                AddScheduleItem(value: DateTime.wednesday, label: 'Wednesday'),
                AddScheduleItem(value: DateTime.thursday, label: 'Thursday'),
                AddScheduleItem(value: DateTime.friday, label: 'Friday'),
                AddScheduleItem(value: DateTime.saturday, label: 'Saturday'),
              ],
              onSelected: (day) => setState(() {
                _selectedDay = day!;
                _dayError = null;
              }),
              errorText: _dayError,
            ),
          ),

          formAddress(
            context,
            "Repeat every",
            AddScheduleDropdown<RepeatInterval>(
              selectLabel: "repeat interval",
              initialValue: _selectedInterval,
              icon: Icons.repeat_outlined,
              items: RepeatInterval.values.map((r) => AddScheduleItem(value: r, label: r.label)).toList(),
              onSelected: (interval) => setState(() {
                _selectedInterval = interval!;
                _intervalError = null;
              }),
              errorText: _intervalError,
            ),
          ),

          formAddress(
            context,
            "Start date",
            DateField(
              label: _selectedStartDate == null ? 'Select a date' : getOrdinalDate(_selectedStartDate!),
              icon: Icons.calendar_month_outlined,
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _selectedStartDate ?? DateTime.now(),
                  firstDate: DateTime.now().subtract(const Duration(days: 30)),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (picked != null) setState(() => _selectedStartDate = picked);
              },
            ),
          ),

          formAddress(
            context,
            "Reminder",
            hintText: 'Choose when you want to be reminded about this collection.',
            Row(
              children: [
                Expanded(
                  child: TimingOption(
                    title: 'Evening before',
                    //description: 'The night before collection.',
                    selected: _selectedReminderTiming == ReminderTiming.eveningBefore,
                    onTap: () {
                      setState(() {
                        _selectedReminderTiming = ReminderTiming.eveningBefore;
                        _notificationTime = null;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TimingOption(
                    title: 'Morning of',
                    //description: 'The morning of collection.',
                    selected: _selectedReminderTiming == ReminderTiming.morningOf,
                    onTap: () {
                      setState(() {
                        _selectedReminderTiming = ReminderTiming.morningOf;
                        _notificationTime = null;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          DateField(
            label: _notificationTime == null
                ? _selectedReminderTiming == ReminderTiming.eveningBefore
                    ? 'Default — 8:00 PM'
                    : 'Default — 5:00 AM'
                : _selectedReminderTiming == ReminderTiming.eveningBefore
                    ? 'Evening before, ${_notificationTime!.format(context)}'
                    : 'Morning of, ${_notificationTime!.format(context)}',
            icon: Icons.access_time_outlined,
            onTap: () async {
              final defaultTime =_selectedReminderTiming == ReminderTiming.eveningBefore
                      ? const TimeOfDay(hour: 20, minute: 0)
                      : const TimeOfDay(hour: 7, minute: 0);

              final picked = await showTimePicker(
                context: context,
                initialTime: _notificationTime ?? defaultTime,
              );

              if (picked != null) {
                setState(() => _notificationTime = picked);
              }
            },
          ),

          Container(
            margin: EdgeInsets.only(top: context.padding(PaddingSize.large).top),
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ButtonStyle(
                elevation: const WidgetStatePropertyAll<double>(5),
                backgroundColor: WidgetStatePropertyAll<Color>(colors.accent),
                padding: WidgetStatePropertyAll<EdgeInsetsGeometry>(
                    EdgeInsets.symmetric(vertical: context.padding(PaddingSize.small).vertical)),
              ),
              onPressed: widget.isSaving || _isSubmitting ? null : _handleSubmit,
              icon: widget.isSaving
              ? const SizedBox( height: 18, width: 18,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : const Icon(Icons.add_card_outlined, color: Colors.white),
              label: Text(
                widget.isSaving ? "Saving..." : widget.submitLabel,
                style: Theme.of(context).textTheme.titleSmall!.copyWith(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Widget formAddress(BuildContext context, String title, Widget widget, {String hintText = ""}) {
  return Container(
    margin: EdgeInsets.only(top: context.padding(PaddingSize.large).top),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        Text(title, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 5),

        if (hintText.isNotEmpty) ...[
          Text(
            hintText,
            style: Theme.of(context).textTheme.bodySmall!.copyWith(
              color: context.colors.textPrimary,
              fontSize: context.fontSize(FontSize.small),
            ),
          ),
        ],
        const SizedBox(height: 10),
        widget,
      ],
    ),
  );
}