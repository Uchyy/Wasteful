import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wasteful/core/constants/bin_types.dart';
import 'package:wasteful/core/constants/repeat_interval.dart';
import 'package:wasteful/data/model/schedule.dart';

void main() {
  final createdAt = DateTime(2026, 9, 1);

  Schedule createSchedule({
    required int weekday,
    required RepeatInterval repeat,
    required DateTime startDate,
  }) {
    return Schedule(
      id: 'test',
      addressId: '001',
      binTypes: BinType.general,
      collectionWeekday: weekday,
      repeatInterval: repeat,
      startDate: startDate,
      notificationTime: const TimeOfDay(hour: 20, minute: 0),
      isArchived: false,
      createdAt: createdAt,
      updatedAt: createdAt,
    );
  }

  group('Schedule date calculations', () {
    test('weekly schedule', () {
      final schedule = createSchedule(
        weekday: DateTime.tuesday,
        repeat: RepeatInterval.weekly,
        startDate: DateTime(2026, 9, 1),
      );

      final dates = schedule.upcomingCollectionDates(
        from: DateTime(2026, 9, 2),
        count: 4,
      );

      expect(
        dates,
        [
          DateTime(2026, 9, 8),
          DateTime(2026, 9, 15),
          DateTime(2026, 9, 22),
          DateTime(2026, 9, 29),
        ],
      );
    });

    test('every two weeks', () {
      final schedule = createSchedule(
        weekday: DateTime.tuesday,
        repeat: RepeatInterval.everyTwoWeeks,
        startDate: DateTime(2026, 9, 1),
      );

      final dates = schedule.upcomingCollectionDates(
        from: DateTime(2026, 9, 2),
        count: 4,
      );

      expect(
        dates,
        [
          DateTime(2026, 9, 15),
          DateTime(2026, 9, 29),
          DateTime(2026, 10, 13),
          DateTime(2026, 10, 27),
        ],
      );
    });

    test('every three weeks', () {
      final schedule = createSchedule(
        weekday: DateTime.tuesday,
        repeat: RepeatInterval.everyThreeWeeks,
        startDate: DateTime(2026, 9, 1),
      );

      final dates = schedule.upcomingCollectionDates(
        from: DateTime(2026, 9, 2),
        count: 4,
      );

      expect(
        dates,
        [
          DateTime(2026, 9, 22),
          DateTime(2026, 10, 13),
          DateTime(2026, 11, 3),
          DateTime(2026, 11, 24),
        ],
      );
    });

    test('monthly schedule - second Tuesday', () {
      final schedule = createSchedule(
        weekday: DateTime.tuesday,
        repeat: RepeatInterval.monthly,
        startDate: DateTime(2026, 9, 8),
      );

      final dates = schedule.upcomingCollectionDates(
        from: DateTime(2026, 9, 9),
        count: 4,
      );

      expect(
        dates,
        [
          DateTime(2026, 10, 13),
          DateTime(2026, 11, 10),
          DateTime(2026, 12, 8),
          DateTime(2027, 1, 12),
        ],
      );
    });

    test('future start date', () {
      final schedule = createSchedule(
        weekday: DateTime.friday,
        repeat: RepeatInterval.weekly,
        startDate: DateTime(2026, 9, 25),
      );

      final dates = schedule.upcomingCollectionDates(
        from: DateTime(2026, 9, 19),
        count: 3,
      );

      expect(
        dates,
        [
          DateTime(2026, 9, 25),
          DateTime(2026, 10, 2),
          DateTime(2026, 10, 9),
        ],
      );
    });
  });
}