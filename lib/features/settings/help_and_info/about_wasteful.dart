// features/settings/about_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wasteful/core/constants/constants.dart';
import 'package:wasteful/core/extensions/responsive_padding.dart';
import 'package:wasteful/core/theme/app_colors.dart';
import 'package:wasteful/core/widgets/app_bar.dart';
import 'package:wasteful/router/app_router.dart';
import 'package:wasteful/features/settings/controllers/settings_content_controller.dart';

class AboutWastefulScreen extends ConsumerWidget {
  const AboutWastefulScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final aboutAsync = ref.watch(aboutInfoProvider);
    final h = MediaQuery.heightOf(context);
    
    return Scaffold(
      appBar: CustomAppBar(showBack: true, title: "About Wasteful"),
      body: aboutAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Text('Couldn\'t load info', style: TextStyle(color: colors.textMuted)),
        ),
        data: (info) => SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            vertical: context.padding(PaddingSize.large).vertical,
            horizontal: context.padding(PaddingSize.small).horizontal,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Logo + name hero
              Center(
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      height: h * 0.4,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: colors.surface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: colors.border),
                      ),
                      child: Image.asset(
                        'assets/images/splash-1.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(height: 14),

                    Text(info.appName, style: Theme.of(context).textTheme.headlineSmall),

                    const SizedBox(height: 4),
                    Text(info.tagline, style: TextStyle(color: colors.textMuted, fontSize: 13)),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // Description card
              Container(
                padding: context.padding(PaddingSize.medium),
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: colors.border),
                ),
                child: Text(
                  info.description,
                  style: TextStyle(fontSize: 13, color: colors.textSecondary, height: 1.6),
                ),
              ),

              const SizedBox(height: 20),

              // Quick links
              Container(
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: colors.border),
                ),
                child: Column(
                  children: [

                    _AboutLinkTile(
                      icon: Icons.shield_outlined,
                      label: 'Privacy policy',
                      onTap: () => context.push(AppRoutes.privacy),
                    ),
                    Divider(height: 1, color: colors.border, indent: 16, endIndent: 16),

                    _AboutLinkTile(
                      icon: Icons.description_outlined,
                      label: 'Terms of service',
                      onTap: () => context.push(AppRoutes.termsOfService),
                    ),
                    Divider(height: 1, color: colors.border, indent: 16, endIndent: 16),

                    _AboutLinkTile(
                      icon: Icons.star_border,
                      label: 'Rate the app',
                      onTap: () {
                        // TODO: replace with real store URL once published
                        launchUrl(Uri.parse('https://play.google.com/store'));
                      },
                    ),
                    Divider(height: 1, color: colors.border, indent: 16, endIndent: 16),

                    _AboutLinkTile(
                      icon: Icons.mail_outline,
                      label: 'Contact us',
                      onTap: () {
                        launchUrl(Uri.parse('mailto:${AppConstants.contactEmail}'));
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              Center(
                child: Text(
                  'Version ${info.version}',
                  style: TextStyle(fontSize: 12, color: colors.textMuted),
                ),
              ),
              const SizedBox(height: 4),
              Center(
                child: Text(
                  'Made with care in the UK 🇬🇧',
                  style: TextStyle(fontSize: 11, color: colors.textMuted),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AboutLinkTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _AboutLinkTile({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, size: 20, color: colors.textPrimary),
      title: Text(label, style: Theme.of(context).textTheme.bodyMedium),
      trailing: Icon(Icons.chevron_right, size: 18, color: colors.textMuted),
    );
  }
}