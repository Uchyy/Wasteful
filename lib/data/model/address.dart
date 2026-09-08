// data/models/address.dart
import 'schedule.dart';

class Address {
  final String id;
  final String label;
  final bool isDefault;
  final List<Schedule> schedules;
  final DateTime createdAt;

  Address({
    required this.id,
    required this.label,
    required this.isDefault,
    required this.schedules,
    required this.createdAt,
  });

  Address copyWith({
    String? id,
    String? label,
    bool? isDefault,
    List<Schedule>? schedules,
    DateTime? createdAt,
  }) {
    return Address(
      id: id ?? this.id,
      label: label ?? this.label,
      isDefault: isDefault ?? this.isDefault,
      schedules: schedules ?? this.schedules,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Maps to the `addresses` table row. `schedules` is NOT included —
  /// they're a separate table, fetched/inserted independently.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'label': label,
      'is_default': isDefault ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Builds an Address from an `addresses` table row.
  /// [schedules] must be fetched separately and passed in.
  factory Address.fromMap(Map<String, dynamic> map, List<Schedule> schedules) {
    return Address(
      id: map['id'] as String,
      label: map['label'] as String,
      isDefault: (map['is_default'] as int) == 1,
      schedules: schedules,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }
}
