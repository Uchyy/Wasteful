import 'package:flutter/material.dart';
import 'package:wasteful/core/constants/bin_types.dart';
import 'package:wasteful/core/constants/repeat_interval.dart';

class Schedule {
  final String id;                    // unique id, not a BinType
  final List<BinType> binTypes;       // a schedule can cover multiple bin types
  final int collectionWeekday;        // 1 = Monday ... 7 = Sunday (DateTime convention)
  final RepeatInterval repeatInterval;
  final DateTime startDate;
  final TimeOfDay? notificationTime;  // null = use global default
  final bool isArchived;
  final DateTime createdAt;
  final DateTime updatedAt;

  Schedule({
    required this.id,
    required this.binTypes,
    required this.collectionWeekday,
    required this.repeatInterval,
    required this.startDate,
    this.notificationTime,
    required this.isArchived,
    required this.createdAt,
    required this.updatedAt,
  });

  Schedule copyWith({
    String? id,
    List<BinType>? binTypes,
    int? collectionWeekday,
    RepeatInterval? repeatInterval,
    DateTime? startDate,
    TimeOfDay? notificationTime,
    bool? isArchived,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Schedule(
      id: id ?? this.id,
      binTypes: binTypes ?? this.binTypes,
      collectionWeekday: collectionWeekday ?? this.collectionWeekday,
      repeatInterval: repeatInterval ?? this.repeatInterval,
      startDate: startDate ?? this.startDate,
      notificationTime: notificationTime ?? this.notificationTime,
      isArchived: isArchived ?? this.isArchived,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

   /// Maps to the `schedules` table row.
  /// NOTE: `binTypes` is NOT included here — it lives in a separate
  /// `schedule_bin_types` join table, since a schedule can have several.
  /// The repository writes those rows separately.
  /// `address_id` is also not included here (this model has no addressId
  /// field) — the repository sets it explicitly on insert/update.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'collection_weekday': collectionWeekday,
      'repeat_interval': repeatInterval.name,
      'start_date': startDate.toIso8601String(),
      'notification_time': notificationTime != null
          ? '${notificationTime!.hour}:${notificationTime!.minute}'
          : null,
      'is_archived': isArchived ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Builds a Schedule from a `schedules` table row.
  /// [binTypes] must be fetched separately from `schedule_bin_types`
  /// and passed in — this method doesn't touch the database itself.
  factory Schedule.fromMap(Map<String, dynamic> map, List<BinType> binTypes) {
    TimeOfDay? parseTime(String? raw) {
      if (raw == null) return null;
      final parts = raw.split(':');
      return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    }

    return Schedule(
      id: map['id'] as String,
      binTypes: binTypes,
      collectionWeekday: map['collection_weekday'] as int,
      repeatInterval: RepeatInterval.values
          .firstWhere((r) => r.name == map['repeat_interval']),
      startDate: DateTime.parse(map['start_date'] as String),
      notificationTime: parseTime(map['notification_time'] as String?),
      isArchived: (map['is_archived'] as int) == 1,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  @override
  String toString() {
    return 'Schedule('
        'id: $id, '
        'binTypes: ${binTypes.map((b) => b.name).join(", ")}, '
        'collectionWeekday: $collectionWeekday, '
        'repeatInterval: ${repeatInterval.name}, '
        'startDate: ${startDate.toIso8601String()}, '
        'notificationTime: ${notificationTime?.format24Hour() ?? "default"}, '
        'isArchived: $isArchived'
        ')';
  }
}

extension TimeOfDayX on TimeOfDay {
  String format24Hour() =>
      '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
}

extension ScheduleX on Schedule {
  DateTime nextCollectionDate([DateTime? from]) {
    final today = from ?? DateTime.now();

    if (repeatInterval == RepeatInterval.monthly) {
      // Determine which occurrence of the weekday startDate was
      // (1st, 2nd, 3rd, 4th Tuesday of that month, etc.)
      final occurrence = ((startDate.day - 1) ~/ 7) + 1;

      var candidateMonth = DateTime(today.year, today.month, 1);
      DateTime findNthWeekday(DateTime monthStart, int weekday, int n) {
        var date = monthStart;
        while (date.weekday != weekday) {
          date = date.add(const Duration(days: 1));
        }
        return date.add(Duration(days: 7 * (n - 1)));
      }

      var candidate = findNthWeekday(candidateMonth, collectionWeekday, occurrence);
      if (candidate.isBefore(today)) {
        candidateMonth = DateTime(today.year, today.month + 1, 1);
        candidate = findNthWeekday(candidateMonth, collectionWeekday, occurrence);
      }
      return candidate;
    }

    // Weekly-based intervals (1, 2, or 3 weeks)
    final weeks = switch (repeatInterval) {
      RepeatInterval.weekly => 1,
      RepeatInterval.everyTwoWeeks => 2,
      RepeatInterval.everyThreeWeeks => 3,
      RepeatInterval.monthly => throw StateError('handled above'),
    };
    final cycleLength = weeks * 7;

    final daysSinceStart = DateTime(today.year, today.month, today.day)
        .difference(DateTime(startDate.year, startDate.month, startDate.day))
        .inDays;
    final daysIntoCycle = daysSinceStart % cycleLength;
    final daysUntilNextCycleStart = daysIntoCycle == 0 ? 0 : cycleLength - daysIntoCycle;

    var candidate = DateTime(today.year, today.month, today.day)
        .add(Duration(days: daysUntilNextCycleStart));
    while (candidate.weekday != collectionWeekday || candidate.isBefore(today)) {
      candidate = candidate.add(const Duration(days: 1));
    }
    return candidate;
  }

  bool get isDueTonight {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    final next = nextCollectionDate();
    return next.year == tomorrow.year &&
        next.month == tomorrow.month &&
        next.day == tomorrow.day;
  }
}



