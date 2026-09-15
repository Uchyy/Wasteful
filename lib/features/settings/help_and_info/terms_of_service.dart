// features/settings/terms_of_service_screen.dart
import 'package:flutter/material.dart';
import 'package:wasteful/features/settings/controllers/settings_content_controller.dart';
import 'package:wasteful/features/settings/widget/content_sections_screen.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ContentSectionsScreen(
      title: "Terms of service",
      provider: termsOfServiceProvider,
    );
  }
}