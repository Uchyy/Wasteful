// features/add_schedule/add_schedule_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wasteful/core/constants/bin_types.dart';
import 'package:wasteful/core/constants/repeat_interval.dart';
import 'package:wasteful/core/extensions/responsive_font.dart';
import 'package:wasteful/core/extensions/responsive_padding.dart';
import 'package:wasteful/core/theme/app_colors.dart';
import 'package:wasteful/core/utils/getOrdinalDate.dart';
import 'package:wasteful/core/widgets/app_bar.dart';
import 'package:wasteful/data/model/schedule.dart';
import 'package:wasteful/data/repository/schdeule_provider.dart';
import 'package:wasteful/features/add_schedule/widgets/add_schedule_dropdown.dart';
import 'package:wasteful/features/add_schedule/widgets/address_dropdown.dart';
import 'package:wasteful/features/add_schedule/widgets/date_time.dart';
import 'package:wasteful/features/add_schedule/widgets/waste_type.dart';

class AddScheduleScreen extends ConsumerStatefulWidget {
  const AddScheduleScreen({super.key});

  @override
  ConsumerState<AddScheduleScreen> createState() => _AddScheduleScreenState();
}

class _AddScheduleScreenState extends ConsumerState<AddScheduleScreen> {
  int? _selectedDay;
  RepeatInterval? _selectedInterval;
  BinType? _selectedBinType;
  DateTime? _selectedStartDate = DateTime.now();
  String? _selectedAddressId;

  String? _addressError;
  String? _binTypeError;
  String? _dayError;
  String? _intervalError;
  String? _startDateError;
  TimeOfDay? _notificationTime;

  bool _isSaving = false;

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

    final schedule = Schedule(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      binTypes: [_selectedBinType!],
      collectionWeekday: _selectedDay!,
      repeatInterval: _selectedInterval!,
      startDate: _selectedStartDate ?? DateTime.now(),
      notificationTime: _notificationTime,
      isArchived: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    setState(() => _isSaving = true);

    try {
      final repository = ref.read(scheduleRepositoryProvider);
      await repository.addSchedule(_selectedAddressId!, schedule);

      ref.invalidate(addressesProvider);

      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save schedule: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: "What are we tracking",
        showBack: false,
        actionWidget: SizedBox(width: 10),
      ),
      body: Padding(
        padding: context.padding(PaddingSize.medium),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              formAddress(
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
                "Waste type",
                hintText: _selectedBinType == null ? "Please seleect a bin type" : "",
                SizedBox(
                  width: double.infinity,
                  child: WasteTypeSelector(
                    entries: BinType.values,
                    onSelected: (type) {
                      setState(() {
                        _selectedBinType = type;
                      });
                    },
                  ),
                ),
              ),
              formAddress(
                "Collection day",
                AddScheduleDropdown<int>(
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
                "Repeat every",
                AddScheduleDropdown<RepeatInterval>(
                  initialValue: _selectedInterval,
                  icon: Icons.repeat_outlined,
                  items: RepeatInterval.values
                      .map((r) => AddScheduleItem(value: r, label: r.label))
                      .toList(),
                  onSelected: (interval) => setState(() {
                    _selectedInterval = interval!;
                    _intervalError = null;
                  }),
                  errorText: _intervalError,
                ),
              ),
              formAddress(
                "Start date",
                DateField(
                  label: _selectedStartDate == null
                      ? 'Select a date'
                      : getOrdinalDate(_selectedStartDate!),
                  icon: Icons.calendar_month_outlined,
                  errorText: _startDateError,
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _selectedStartDate ?? DateTime.now(),
                      firstDate: DateTime.now().subtract(const Duration(days: 30)),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (picked != null) {
                      setState(() {
                        _selectedStartDate = picked;
                        _startDateError = null;
                      });
                    }
                  },
                ),
              ),
              formAddress(
                "Reminder",
                hintText:
                    'By default, reminders fire the evening before at 8:00 PM. Set a time below to override just this schedule.',
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
                    if (picked != null) {
                      setState(() => _notificationTime = picked);
                    }
                  },
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: context.padding(PaddingSize.large).top),
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ButtonStyle(
                    elevation: WidgetStatePropertyAll<double>(5),
                    backgroundColor: WidgetStatePropertyAll<Color>(context.colors.accent),
                    padding: WidgetStatePropertyAll<EdgeInsetsGeometry>(
                        EdgeInsets.symmetric(vertical: context.padding(PaddingSize.small).vertical)),
                  ),
                  onPressed: _isSaving ? null : _handleSubmit,
                  icon: _isSaving
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : Icon(Icons.add_card_outlined, color: Colors.white),
                  label: Text(
                    _isSaving ? "Saving..." : "Add schedule",
                    style: Theme.of(context).textTheme.titleSmall!.copyWith(color: Colors.white),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget formAddress(String title, Widget widget, {String hintText = ""}) {
    return Container(
      margin: EdgeInsets.only(top: context.padding(PaddingSize.large).top),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium,
          ),
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
          widget
        ],
      ),
    );
  }
}