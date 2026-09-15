// features/settings/settings_content_controller.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:wasteful/data/model/about_info.dart';
import 'package:wasteful/data/model/content_section.dart';
import 'package:wasteful/data/repository/content_repository.dart';


final contentRepositoryProvider = Provider((ref) => ContentRepository());

final privacyPolicyProvider = FutureProvider<List<ContentSection>>((ref) {
  return ref.read(contentRepositoryProvider).getSections('assets/data/privacy_policy.json');
});

final termsOfServiceProvider = FutureProvider<List<ContentSection>>((ref) {
  return ref.read(contentRepositoryProvider).getSections('assets/data/terms_of_service.json');
});

final aboutInfoProvider = FutureProvider<AboutInfo>((ref) async {
  final raw = await rootBundle.loadString('assets/data/about.json');
  return AboutInfo.fromJson(jsonDecode(raw) as Map<String, dynamic>);
});