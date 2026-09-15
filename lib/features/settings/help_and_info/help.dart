// features/help/help_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wasteful/core/constants/constants.dart';
import 'package:wasteful/core/theme/app_colors.dart';
import 'package:wasteful/core/widgets/app_bar.dart';
import 'package:wasteful/core/widgets/app_snackbar.dart';
import 'package:wasteful/core/widgets/section_wrapper.dart';
import 'package:wasteful/features/settings/controllers/faq_controller.dart';
import 'package:wasteful/router/app_router.dart';

class HelpScreen extends ConsumerWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final faqAsync = ref.watch(faqListProvider);

    return Scaffold(
      appBar: CustomAppBar(showBack: true, title: "Help"),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: colors.border),
              ),
              child: ListTile(
                leading: Icon(Icons.search_outlined, color: colors.textPrimary),
                title: const Text('Find my council'),
                subtitle: Text(
                  'Search for your council\'s bin collection page',
                  style: TextStyle(fontSize: 12, color: colors.textMuted),
                ),
                trailing: Icon(Icons.chevron_right, color: colors.textMuted),
                onTap: () => context.push(AppRoutes.findCouncil),
              ),
            ),
            const SizedBox(height: 24),

            faqAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: SectionCard(
                  title: 'Frequently asked questions',
                  children: [ CircularProgressIndicator()]
                )
              ),
              error: (err, _) => Text(
                'Couldn\'t load FAQs',
                style: TextStyle(color: colors.textMuted),
              ),
              data: (faqs) => SectionCard(
                title: 'Frequently asked questions',
                children: [ 
                  
                  for (final faq in faqs)
                    Theme(
                      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                      child: ExpansionTile(
                        tilePadding: EdgeInsets.zero,
                        title: Text(
                          faq.question,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        childrenPadding: const EdgeInsets.only(bottom: 12),
                        expandedCrossAxisAlignment: CrossAxisAlignment.start,
                        iconColor: colors.accent,
                        children: [
                          Text(
                            faq.answer,
                            style: TextStyle(fontSize: 13, color: colors.textSecondary, height: 1.4),
                          ),
                        ],
                      ),
                    ),
                ]
              )
            ),

            const SizedBox(height: 24),
            Text('Still stuck?', style: Theme.of(context).textTheme.titleMedium),

            const SizedBox(height: 8),

            Container(
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: colors.border),
              ),
              child: ListTile(
                leading: Icon(Icons.mail_outline, color: colors.textPrimary),
                title: const Text('Contact us'),
                subtitle: Text('Send feedback or report an issue', style: TextStyle(fontSize: 12, color: colors.textMuted)),
                trailing: Icon(Icons.chevron_right, color: colors.textMuted),
                onTap: () async {
                  final uri = Uri(
                    scheme: 'mailto',
                    path: AppConstants.contactEmail, // replace with your real support address
                    query: 'subject=Wasteful support request',
                  );

                  final launched = await launchUrl(uri);

                  if (!launched && context.mounted) {
                    showAppSnackBar(
                      context,
                      message: 'Couldn\'t open your email app',
                      type: SnackType.error,
                    );
                  }
                },
              ),
            ),

          ],
        ),
      ),
    );
  }
}