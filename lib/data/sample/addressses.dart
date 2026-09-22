// data/sample/sample_addresses.dart
import 'package:flutter/material.dart' show TimeOfDay;
import 'package:wasteful/core/constants/repeat_interval.dart';
import 'package:wasteful/data/model/address.dart';
import 'package:wasteful/data/model/schedule.dart';
import '../../core/constants/bin_types.dart';

/// Demo data for manually testing each Home-screen state.
/// Swap which one `sampleAddresses` returns to preview each case.
class SampleAddresses {
  SampleAddresses._();

  static final _now = DateTime.now();
  static final tomorrow = _now.add(const Duration(days: 1));

  /// 1. Empty — no addresses at all (first-ever open)
  static List<Address> empty() => [];

  /// 2. Single address, two schedules (recycling+general on one
  ///    rotation, garden on a separate one)
  static List<Address> single() => [
        Address(
          id: 'addr-1',
          label: 'Portsmouth Home',
          isDefault: true,
          createdAt: _now,
          schedules: [
            Schedule(
              id: 'sch-1',
              addressId: 'adr-1',
              binTypes:BinType.recycling,
              collectionWeekday: DateTime.tuesday,
              repeatInterval: RepeatInterval.everyTwoWeeks,
              startDate: _now.subtract(const Duration(days: 3)),
              notificationTime: null, // uses global default
              isArchived: false,
              createdAt: _now,
              updatedAt: _now,
            ),
            Schedule(
              id: 'sch-2',
              addressId: 'adr-1',
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
              addressId: 'adr-1',
              binTypes: BinType.general,
              collectionWeekday: tomorrow.weekday, // matches tomorrow exactly
              repeatInterval: RepeatInterval.weekly,                      // weekly, so it always lands correctly
              startDate: _now.subtract(const Duration(days: 7)), // any past date works with repeatWeeks: 1
              notificationTime: null,
              isArchived: false,
              createdAt: _now,
              updatedAt: _now,
            ),
          ],
        ),
      ];

  /// 3. Multiple addresses — Portsmouth (2 schedules) + Leicester (1)
  static List<Address> multiple() => [
        ...single(), // reuse Portsmouth Home from above
        Address(
          id: 'addr-2',
          label: 'Leicester Flat',
          isDefault: false,
          createdAt: _now,
          schedules: [
            Schedule(
              id: 'sch-5',
              addressId: 'adr-2',
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
              id: 'sch-6',
              addressId: 'adr-2',
              binTypes: BinType.recycling,
              collectionWeekday: tomorrow.weekday, // matches tomorrow exactly
              repeatInterval: RepeatInterval.weekly,                      // weekly, so it always lands correctly
              startDate: _now.subtract(const Duration(days: 7)), // any past date works with repeatWeeks: 1
              notificationTime: const TimeOfDay(hour: 20, minute: 0),
              isArchived: false,
              createdAt: _now,
              updatedAt: _now,
            ),

             Schedule(
              id: 'sch-6',
              addressId: 'adr-2',
              binTypes: BinType.general,
              collectionWeekday: tomorrow.weekday, // matches tomorrow exactly
              repeatInterval: RepeatInterval.everyTwoWeeks,                      // weekly, so it always lands correctly
              startDate: _now.subtract(const Duration(days: 7)), // any past date works with repeatWeeks: 1
              notificationTime: const TimeOfDay(hour: 20, minute: 0),
              isArchived: false,
              createdAt: _now,
              updatedAt: _now,
            ),
          ],
        ),
      ];
}