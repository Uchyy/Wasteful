// features/settings/content_sections_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wasteful/core/theme/app_colors.dart';
import 'package:wasteful/core/widgets/app_bar.dart';
import 'package:wasteful/data/model/content_section.dart';

class ContentSectionsScreen extends ConsumerWidget {
  final String title;
  final FutureProvider<List<ContentSection>> provider;

  const ContentSectionsScreen({super.key, required this.title, required this.provider});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final sectionsAsync = ref.watch(provider);

    return Scaffold(
      appBar: CustomAppBar(showBack: true, title: title),
      body: sectionsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Couldn\'t load content', style: TextStyle(color: colors.textMuted))),
        data: (sections) => ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: sections.length,
          separatorBuilder: (_, __) => const SizedBox(height: 20),
          itemBuilder: (context, i) {
            final section = sections[i];
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(section.heading, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 6),
                Text(
                  section.body,
                  style: TextStyle(fontSize: 13, color: colors.textSecondary, height: 1.5),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}