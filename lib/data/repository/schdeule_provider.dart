// data/repositories/schedule_repository_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wasteful/data/repository/schedule_repository.dart';


final scheduleRepositoryProvider = Provider<ScheduleRepository>(
  (ref) => ScheduleRepository(),
);

