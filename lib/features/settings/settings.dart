// features/settings/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wasteful/core/extensions/responsive_font.dart';
import 'package:wasteful/core/extensions/responsive_padding.dart';
import 'package:wasteful/core/theme/app_colors.dart';
import 'package:wasteful/core/theme/app_text_styles.dart';
import 'package:wasteful/core/theme/theme_provider.dart';
import 'package:wasteful/core/widgets/app_bar.dart';
import 'package:wasteful/core/widgets/section_wrapper.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final currentThemeMode = ref.watch(themeModeProvider);
    
    return Scaffold(
      appBar: CustomAppBar(
        title: "Settings",
        showBack: false,
        actionWidget: null,
      ),
      body:Padding(
        padding: context.padding(PaddingSize.medium),
        child:  SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // Schedule
              SectionCard(
                backgroundColor: colors.background,
                title: "Schedules",
                children: [
                  SettingsItem(
                    title: "Manage Addresses and Schedule", 
                    leading: Icon(Icons.calendar_month_outlined, size: context.fontSize(FontSize.extraLarge) * 1.5),
                    onTap: () {},
                  ),
                  
                  SettingsItem(
                    title: "Add new Schedule", 
                    leading: Icon(Icons.add_circle_outline, size: context.fontSize(FontSize.extraLarge) * 1.5,), 
                    onTap: () {},
                  ),  
                ]
              ),

              // Help & Information
              SectionCard(
                backgroundColor: colors.background,
                title: "Help & Information",
                children: [
                  SettingsItem(
                    title: "Find my council", 
                    leading: Icon(Icons.search_outlined, size: context.fontSize(FontSize.extraLarge) * 1.5),
                    onTap: () {},
                  ),
                  
                  SettingsItem(
                    title: "Help", 
                    leading: Icon(Icons.help_outline, size: context.fontSize(FontSize.extraLarge) * 1.5,), 
                    onTap: () {},
                  ),  

                  SettingsItem(
                    title: "Privacy Policy", 
                    leading: Icon(Icons.article_outlined, size: context.fontSize(FontSize.extraLarge) * 1.5,), 
                    onTap: () {},
                  ),  

                  SettingsItem(
                    title: "Terms of Service", 
                    leading: Icon(Icons.article, size: context.fontSize(FontSize.extraLarge) * 1.5,), 
                    onTap: () {},
                  ),  

                  SettingsItem(
                    title: "About Wasteful", 
                    leading: Icon(Icons.info_outline, size: context.fontSize(FontSize.extraLarge) * 1.5,), 
                    onTap: () {},
                  ),  
                ]
              ),

               // App
              SectionCard(
                backgroundColor: colors.background,
                title: "App",
                children: [
                  RadioGroup<ThemeMode>(
                    groupValue: currentThemeMode,
                    onChanged: (ThemeMode? value) {
                      if (value != null) {
                        ref.read(themeModeProvider.notifier).setThemeMode(value);
                      }
                    },
                    child: Column(
                      children: [
                        SettingsItem(
                          title: "Light Mode",
                          leading: Icon(
                            Icons.light_mode_outlined,
                            size: context.fontSize(FontSize.extraLarge) * 1.5,
                          ),
                          trailing: const Radio<ThemeMode>(value: ThemeMode.light),
                          onTap: () {
                            ref.read(themeModeProvider.notifier).setThemeMode(ThemeMode.light);
                          },
                        ),
                        SettingsItem(
                          title: "Dark Mode",
                          leading: Icon(
                            Icons.dark_mode_outlined,
                            size: context.fontSize(FontSize.extraLarge) * 1.5,
                          ),
                          trailing: const Radio<ThemeMode>(value: ThemeMode.dark),
                          onTap: () {
                            ref.read(themeModeProvider.notifier).setThemeMode(ThemeMode.dark);
                          },
                        ),
                        SettingsItem(
                          title: "System Default",
                          leading: Icon(
                            Icons.settings_suggest_outlined,
                            size: context.fontSize(FontSize.extraLarge) * 1.5,
                          ),
                          trailing: const Radio<ThemeMode>(value: ThemeMode.system),
                          onTap: () {
                            ref.read(themeModeProvider.notifier).setThemeMode(ThemeMode.system);
                          },
                        ),
                      ],
                    ),
                  ),
                   
                  SettingsItem(
                    title: "Notifications", 
                    leading: Icon(Icons.notifications_outlined, size: context.fontSize(FontSize.extraLarge) * 1.5,), 
                    onTap: () {},
                  ),  
                ]
              ),

            ],
          )
        ),
      )
    );
  }

  Widget SettingsItem ( { required String title, required Widget leading, String? subtitle, Widget? trailing, required VoidCallback onTap}) {

    final colors = context.colors;
    return ListTile(
      contentPadding: context.padding(PaddingSize.small) * 0.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
      onTap: onTap,
      leading: leading,
      title: Text(
        title,
        style: context.textStyles.titleMedium!.copyWith(color: colors.textPrimary,  fontSize: context.fontSize(FontSize.normal) ),
      ),
      trailing: trailing != null ? trailing : Icon(Icons.arrow_forward_ios),
      subtitle: subtitle != null 
        ? Text(
          subtitle,
          style: context.textStyles.bodyMedium!.copyWith(color: colors.textSecondary, letterSpacing: 1.5, fontSize: context.fontSize(FontSize.normal) * 0.5),
        ) : null
    );
  }
}