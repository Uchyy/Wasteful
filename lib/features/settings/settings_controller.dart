// features/settings/settings_controller.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:wasteful/data/repository/settings_repository.dart';
import '../../core/constants/reminder_timing.dart';

final settingsRepositoryProvider = Provider((ref) => SettingsRepository());

class ReminderTimingNotifier extends StateNotifier<ReminderTiming> {
  final SettingsRepository _repository;

  ReminderTimingNotifier(this._repository) : super(ReminderTiming.eveningBefore) {
    _load();
  }

  Future<void> _load() async {
    state = await _repository.getReminderTiming();
  }

  Future<void> update(ReminderTiming timing) async {
    state = timing;
    await _repository.setReminderTiming(timing);
  }
}

final reminderTimingProvider = StateNotifierProvider<ReminderTimingNotifier, ReminderTiming>(
  (ref) => ReminderTimingNotifier(ref.read(settingsRepositoryProvider)),
);