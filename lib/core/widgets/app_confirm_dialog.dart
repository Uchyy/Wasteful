// core/widgets/app_confirm_dialog.dart
import 'package:flutter/material.dart';
import 'package:wasteful/core/extensions/responsive_padding.dart';
import '../theme/app_colors.dart';

enum ConfirmDialogType { danger, info, warning }

class AppConfirmDialog extends StatefulWidget {
  final String title;
  final String message;
  final String confirmLabel;
  final String cancelLabel;
  final ConfirmDialogType type;
  final IconData icon;
  /// Optional — if provided, runs when the confirm button is tapped,
  /// and the dialog shows a loading state until it completes before closing.
  final Future<void> Function()? onConfirm;

  const AppConfirmDialog({
    super.key,
    required this.title,
    required this.message,
    this.confirmLabel = 'Confirm',
    this.cancelLabel = 'Cancel',
    this.type = ConfirmDialogType.danger,
    this.icon = Icons.delete_outline,
    this.onConfirm,
  });

  static Future<bool> show(
    BuildContext context, {
    required String title,
    required String message,
    String confirmLabel = 'Confirm',
    String cancelLabel = 'Cancel',
    ConfirmDialogType type = ConfirmDialogType.danger,
    IconData icon = Icons.delete_outline,
    Future<void> Function()? onConfirm,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: !( onConfirm != null),
      builder: (context) => AppConfirmDialog(
        title: title,
        message: message,
        confirmLabel: confirmLabel,
        cancelLabel: cancelLabel,
        type: type,
        icon: icon,
        onConfirm: onConfirm,
      ),
    );
    return result ?? false;
  }

  @override
  State<AppConfirmDialog> createState() => _AppConfirmDialogState();
}

class _AppConfirmDialogState extends State<AppConfirmDialog> {
  bool _isProcessing = false;

  Future<void> _handleConfirm() async {
    if (widget.onConfirm == null) {
      Navigator.pop(context, true);
      return;
    }

    setState(() => _isProcessing = true);
    try {
      await widget.onConfirm!();
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        setState(() => _isProcessing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Something went wrong: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    final accentColor = switch (widget.type) {
      ConfirmDialogType.danger => Colors.redAccent,
      ConfirmDialogType.warning => Colors.orange,
      ConfirmDialogType.info => colors.accent,
    };

    return Dialog(
      backgroundColor: colors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: context.padding(PaddingSize.medium),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(color: accentColor.withAlpha(30), shape: BoxShape.circle),
              child: Icon(widget.icon, color: accentColor, size: 32),
            ),
            const SizedBox(height: 18),

            Text(
              widget.title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),

            Text(
              widget.message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w300),
            ),
            const SizedBox(height: 24),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isProcessing ? null : () => Navigator.pop(context, false),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: colors.border),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: Text(widget.cancelLabel, style: TextStyle(color: colors.textPrimary)),
                  ),
                ),
                const SizedBox(width: 12),

                Expanded(
                  child: ElevatedButton(
                    onPressed: _isProcessing ? null : _handleConfirm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accentColor,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: _isProcessing
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : Text(widget.confirmLabel, style: const TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),

          ],
        ),
      ),
    );
  }
}