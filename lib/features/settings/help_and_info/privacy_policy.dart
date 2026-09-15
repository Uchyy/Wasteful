// features/settings/privacy_policy_screen.dart
import 'package:flutter/material.dart';
import 'package:wasteful/features/settings/controllers/settings_content_controller.dart';
import 'package:wasteful/features/settings/widget/content_sections_screen.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ContentSectionsScreen(
      title: "Privacy policy",
      provider: privacyPolicyProvider,
    );
  }
}