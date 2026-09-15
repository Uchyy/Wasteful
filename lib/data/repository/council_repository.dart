// data/repositories/council_repository.dart
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:wasteful/data/model/council.dart';

class CouncilRepository {
  List<Council>? _cache;

  Future<List<Council>> getCouncils() async {
    if (_cache != null) return _cache!;
    final raw = await rootBundle.loadString('assets/data/uk_councils_bin_collection.json');
    final list = jsonDecode(raw) as List<dynamic>;
    _cache = list.map((e) => Council.fromJson(e as Map<String, dynamic>)).toList();
    return _cache!;
  }

  Future<List<Council>> search(String query) async {
    final all = await getCouncils();
    if (query.isEmpty) return all;
    final lower = query.toLowerCase();
    return all.where((c) => c.council.toLowerCase().contains(lower)).toList();
  }
}