// features/home/home_controller.dart
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wasteful/data/model/address.dart';
import 'package:wasteful/data/model/schedule.dart';
import 'package:wasteful/data/repository/schedule_provider.dart';

class AddressesNotifier extends StateNotifier<List<Address>> {
  final Ref ref;

  AddressesNotifier(this.ref) : super([]) {
    _loadFromDb();
  }

  Future<void> _loadFromDb() async {
    final repository = ref.read(scheduleRepositoryProvider);
    state = await repository.getAddresses();
  }

  Future<void> refresh() => _loadFromDb();

  Future<void> add(Address address) async {
    final repository = ref.read(scheduleRepositoryProvider);
    await repository.addAddress(address);
    await _loadFromDb();
  }

  Future<void> remove(String addressId) async {
    final repository = ref.read(scheduleRepositoryProvider);
    await repository.deleteAddress(addressId);
    await _loadFromDb();
  }

 Future<void> updateSchedule(
  String addressId,
  Schedule schedule,
) async {
  debugPrint('=== ADDRESSES NOTIFIER: UPDATE SCHEDULE ===');
  debugPrint('Address ID: $addressId');
  debugPrint('Schedule ID: ${schedule.id}');
  debugPrint('Notification time: ${schedule.notificationTime}');
  debugPrint('Reminder timing: ${schedule.reminderTiming}');

  final service = ref.read(scheduleServiceProvider);

  await service.updateSchedule(
    addressId,
    schedule,
  );

  debugPrint('=== ADDRESSES NOTIFIER: UPDATE COMPLETE ===');

  await _loadFromDb();

  debugPrint('=== ADDRESSES NOTIFIER: STATE RELOADED ===');
}

  Future<void> removeScheduleFromAddress(String addressId, String scheduleId) async {
    final service = ref.read(scheduleServiceProvider);
    await service.deleteSchedule(scheduleId);
    await _loadFromDb();
  }

  Future<void> addSchedule( String addressId, Schedule schedule, ) async {
    final service = ref.read(scheduleServiceProvider);
    await service.addSchedule( addressId, schedule,);
    await _loadFromDb();
  }
}

final addressesProvider = StateNotifierProvider<AddressesNotifier, List<Address>>(
  (ref) => AddressesNotifier(ref),
);