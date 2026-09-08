// features/home/home_controller.dart
import 'package:flutter_riverpod/legacy.dart';
import 'package:wasteful/data/model/address.dart';
import 'package:wasteful/data/model/schedule.dart';
import 'package:wasteful/data/sample/addressses.dart';

class AddressesNotifier extends StateNotifier<List<Address>> {
  AddressesNotifier() : super(SampleAddresses.multiple()); // swap to .single()/.empty() to test other states

  void add(Address address) {
    state = [...state, address];
  }

  void remove(String addressId) {
    state = state.where((a) => a.id != addressId).toList();
  }

  void update(Address updated) {
    state = [
      for (final a in state) a.id == updated.id ? updated : a,
    ];
  }

  void addScheduleToAddress(String addressId, Schedule schedule) {
    state = [
      for (final a in state)
        if (a.id == addressId)
          a.copyWith(schedules: [...a.schedules, schedule])
        else
          a,
    ];
  }

  void removeScheduleFromAddress(String addressId, String scheduleId) {
    state = [
      for (final a in state)
        if (a.id == addressId)
          a.copyWith(schedules: a.schedules.where((s) => s.id != scheduleId).toList())
        else
          a,
    ];
  }

  void updateSchedule(String addressId, Schedule updatedSchedule) {
    state = [
      for (final a in state)
        if (a.id == addressId)
          a.copyWith(
            schedules: [
              for (final s in a.schedules)
                s.id == updatedSchedule.id ? updatedSchedule : s,
            ],
          )
        else
          a,
    ];
  }
}

final addressesProvider = StateNotifierProvider<AddressesNotifier, List<Address>>(
  (ref) => AddressesNotifier(),
);