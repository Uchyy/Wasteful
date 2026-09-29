// data/sample/sample_addresses.dart
import 'package:flutter/material.dart' show TimeOfDay;
import 'package:wasteful/core/constants/bin_types.dart';
import 'package:wasteful/core/constants/repeat_interval.dart';
import 'package:wasteful/data/model/address.dart';
import 'package:wasteful/data/model/schedule.dart';

/// Demo data for manually testing Home-screen states.
class SampleAddresses {
  SampleAddresses._();

  static final _now = DateTime.now();
  static final tomorrow = _now.add(const Duration(days: 1));

  /// Empty — no addresses at all.
  static List<Address> empty() => [];

  /// Single address with three schedules.
  static List<Address> single() => [
        Address(
          id: 'addr-1',
          label: 'Portsmouth Home',
          isDefault: true,
          createdAt: _now,
          schedules: [
            Schedule(
              id: 'sch-1',
              addressId: 'addr-1',
              binTypes: BinType.recycling,
              collectionWeekday: DateTime.tuesday,
              repeatInterval: RepeatInterval.everyTwoWeeks,
              startDate: _now.subtract(const Duration(days: 3)),
              notificationTime: null,
              isArchived: false,
              createdAt: _now,
              updatedAt: _now,
            ),
            Schedule(
              id: 'sch-2',
              addressId: 'addr-1',
              binTypes: BinType.garden,
              collectionWeekday: DateTime.friday,
              repeatInterval: RepeatInterval.everyThreeWeeks,
              startDate: _now.add(const Duration(days: 1)),
              notificationTime: const TimeOfDay(hour: 18, minute: 0),
              isArchived: false,
              createdAt: _now,
              updatedAt: _now,
            ),
            Schedule(
              id: 'sch-3',
              addressId: 'addr-1',
              binTypes: BinType.general,
              collectionWeekday: tomorrow.weekday,
              repeatInterval: RepeatInterval.weekly,
              startDate: _now.subtract(const Duration(days: 7)),
              notificationTime: null,
              isArchived: false,
              createdAt: _now,
              updatedAt: _now,
            ),
          ],
        ),
      ];

  /// Multiple addresses with several schedules.
  static List<Address> multiple() => [
        ...single(),
        Address(
          id: 'addr-2',
          label: 'Leicester Flat',
          isDefault: false,
          createdAt: _now,
          schedules: [
            Schedule(
              id: 'sch-4',
              addressId: 'addr-2',
              binTypes: BinType.food,
              collectionWeekday: DateTime.friday,
              repeatInterval: RepeatInterval.weekly,
              startDate: _now.subtract(const Duration(days: 1)),
              notificationTime: const TimeOfDay(hour: 20, minute: 0),
              isArchived: false,
              createdAt: _now,
              updatedAt: _now,
            ),
            Schedule(
              id: 'sch-5',
              addressId: 'addr-2',
              binTypes: BinType.recycling,
              collectionWeekday: tomorrow.weekday,
              repeatInterval: RepeatInterval.weekly,
              startDate: _now.subtract(const Duration(days: 7)),
              notificationTime: const TimeOfDay(hour: 20, minute: 0),
              isArchived: false,
              createdAt: _now,
              updatedAt: _now,
            ),
            Schedule(
              id: 'sch-6',
              addressId: 'addr-2',
              binTypes: BinType.general,
              collectionWeekday: tomorrow.weekday,
              repeatInterval: RepeatInterval.everyTwoWeeks,
              startDate: _now.subtract(const Duration(days: 7)),
              notificationTime: const TimeOfDay(hour: 20, minute: 0),
              isArchived: false,
              createdAt: _now,
              updatedAt: _now,
            ),
          ],
        ),
      ];
}