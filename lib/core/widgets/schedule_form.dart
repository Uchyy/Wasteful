// features/add_schedule/widgets/schedule_form.dart
import 'package:flutter/material.dart';
import 'package:wasteful/core/constants/bin_types.dart';
import 'package:wasteful/core/constants/repeat_interval.dart';
import 'package:wasteful/core/extensions/responsive_font.dart';
import 'package:wasteful/core/extensions/responsive_padding.dart';
import 'package:wasteful/core/theme/app_colors.dart';
import 'package:wasteful/core/utils/getOrdinalDate.dart';
import 'package:wasteful/data/model/schedule.dart';
import 'package:wasteful/features/schedule/widgets/add_schedule_dropdown.dart';
import 'package:wasteful/features/schedule/widgets/address_dropdown.dart';
import 'package:wasteful/features/schedule/widgets/date_time.dart';
import 'package:wasteful/features/schedule/widgets/waste_type.dart';


class ScheduleForm extends StatefulWidget {
  /// Pass an existing schedule + its address id to pre-fill for editing.
  /// Leave null for a fresh Add Schedule form.
  final Schedule? initialSchedule;
  final String? initialAddressId;

  final String submitLabel;
  final bool isSaving;
  /// Called with the completed schedule (id/createdAt untouched — caller
  /// decides whether this is a create or update) and the selected address id.
  final Future<void> Function(String addressId, Schedule schedule) onSubmit;

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
  late RepeatInterval? _selectedInterval = widget.initialSchedule?.repeatInterval;
  late BinType? _selectedBinType = widget.initialSchedule?.binTypes;
  late DateTime? _selectedStartDate = widget.initialSchedule?.startDate ?? DateTime.now();
  late String? _selectedAddressId = widget.initialAddressId;
  late TimeOfDay? _notificationTime = widget.initialSchedule?.notificationTime;

  String? _addressError;
  String? _binTypeError;
  String? _dayError;
  String? _intervalError;

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
    if (!_validate()) return;

    final now = DateTime.now();
    final schedule = Schedule(
      id: widget.initialSchedule?.id ?? now.millisecondsSinceEpoch.toString(),
      binTypes: _selectedBinType!,
      collectionWeekday: _selectedDay!,
      repeatInterval: _selectedInterval!,
      startDate: _selectedStartDate ?? now,
      notificationTime: _notificationTime,
      isArchived: widget.initialSchedule?.isArchived ?? false,
      createdAt: widget.initialSchedule?.createdAt ?? now,
      updatedAt: now,
    );

    await widget.onSubmit(_selectedAddressId!, schedule);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
            hintText: 'By default, reminders fire the evening before at 8:00 PM. Set a time below to override just this schedule.',
            DateField(
              label: _notificationTime == null
                  ? 'Default — evening before, 8:00 PM'
                  : 'Evening before, ${_notificationTime!.format(context)}',
              icon: Icons.notifications_outlined,
              onTap: () async {
                final picked = await showTimePicker(
                  context: context,
                  initialTime: _notificationTime ?? const TimeOfDay(hour: 20, minute: 0),
                );
                if (picked != null) setState(() => _notificationTime = picked);
              },
            ),
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
              onPressed: widget.isSaving ? null : _handleSubmit,
              icon: widget.isSaving
                  ? const SizedBox(
                      height: 18,
                      width: 18,
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
                  color: context.colors.accent.withAlpha(100),
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