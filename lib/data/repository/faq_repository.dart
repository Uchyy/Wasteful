// data/repositories/faq_repository.dart
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:wasteful/data/model/faq.dart';

class FaqRepository {
  Future<List<FaqItem>> getAll() async {
    final raw = await rootBundle.loadString('assets/data/faq.json');
    final list = jsonDecode(raw) as List<dynamic>;
    return list.map((e) => FaqItem.fromJson(e as Map<String, dynamic>)).toList();
  }
}