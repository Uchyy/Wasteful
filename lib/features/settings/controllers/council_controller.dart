// features/help/find_council_controller.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wasteful/data/model/council.dart';
import 'package:wasteful/data/repository/council_repository.dart';


final councilRepositoryProvider = Provider((ref) => CouncilRepository());

final councilSearchProvider = FutureProvider.family<List<Council>, String>((ref, query) {
  return ref.read(councilRepositoryProvider).search(query);
});