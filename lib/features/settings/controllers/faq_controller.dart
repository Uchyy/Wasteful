// features/help/help_controller.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wasteful/data/model/faq.dart';
import 'package:wasteful/data/repository/faq_repository.dart';

final faqRepositoryProvider = Provider((ref) => FaqRepository());

final faqListProvider = FutureProvider<List<FaqItem>>((ref) {
  return ref.read(faqRepositoryProvider).getAll();
});