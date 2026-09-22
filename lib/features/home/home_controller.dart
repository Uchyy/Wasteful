// features/home/home_controller.dart
import 'package:flutter_riverpod/legacy.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wasteful/data/model/address.dart';
import 'package:wasteful/data/model/schedule.dart';
import 'package:wasteful/data/repository/schdeule_provider.dart';

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

  Future<void> updateSchedule(String addressId, Schedule schedule) async {
    final repository = ref.read(scheduleRepositoryProvider);
    await repository.updateSchedule(addressId, schedule);
    await _loadFromDb();
  }

  Future<void> removeScheduleFromAddress(String addressId, String scheduleId) async {
    final repository = ref.read(scheduleRepositoryProvider);
    await repository.deleteSchedule(scheduleId);
    await _loadFromDb();
  }

  Future<void> addSchedule( String addressId, Schedule schedule, ) async {
    final repository = ref.read(scheduleRepositoryProvider);
    await repository.addSchedule( addressId, schedule,);
    await _loadFromDb();
  }
}

final addressesProvider = StateNotifierProvider<AddressesNotifier, List<Address>>(
  (ref) => AddressesNotifier(ref),
);