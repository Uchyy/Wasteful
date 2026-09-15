// data/repositories/content_repository.dart
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../model/content_section.dart';

class ContentRepository {
  Future<List<ContentSection>> getSections(String assetPath) async {
    final raw = await rootBundle.loadString(assetPath);
    final list = jsonDecode(raw) as List<dynamic>;
    return list.map((e) => ContentSection.fromJson(e as Map<String, dynamic>)).toList();
  }
}