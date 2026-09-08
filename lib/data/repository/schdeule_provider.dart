// data/repositories/schedule_repository_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wasteful/data/model/address.dart';
import 'package:wasteful/data/repository/schedule_repository.dart';


final scheduleRepositoryProvider = Provider<ScheduleRepository>(
  (ref) => ScheduleRepository(),
);

final addressesProvider = FutureProvider<List<Address>>((ref) async {
  final repo = ref.watch(scheduleRepositoryProvider);
  return repo.getAddresses();
});