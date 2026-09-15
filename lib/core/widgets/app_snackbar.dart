// core/widgets/app_snackbar.dart
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

enum SnackType { success, error, info }

void showAppSnackBar(
  BuildContext context, {
  required String message,
  SnackType type = SnackType.info,
}) {
  final colors = context.colors;

  final (bgColor, icon) = switch (type) {
    SnackType.success => (Colors.green.shade600, Icons.check_circle_outline),
    SnackType.error => (Colors.redAccent, Icons.error_outline),
    SnackType.info => (colors.accent, Icons.info_outline),
  };

  ScaffoldMessenger.of(context).hideCurrentSnackBar();
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      backgroundColor: bgColor,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 3),
      content: Row(
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(message, style: const TextStyle(color: Colors.white, fontSize: 13)),
          ),
        ],
      ),
    ),
  );
}


/*
  showAppSnackBar(context, message: 'Schedule saved', type: SnackType.success);
  showAppSnackBar(context, message: 'Failed to save schedule: $e', type: SnackType.error);
  showAppSnackBar(context, message: 'Using default reminder time', type: SnackType.info);
*/