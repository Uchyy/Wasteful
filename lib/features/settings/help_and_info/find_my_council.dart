// features/help/find_my_council_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:searchfield/searchfield.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wasteful/core/extensions/responsive_font.dart';
import 'package:wasteful/core/extensions/responsive_padding.dart';
import 'package:wasteful/core/theme/app_colors.dart';
import 'package:wasteful/core/widgets/app_bar.dart';
import 'package:wasteful/data/model/council.dart';
import 'package:wasteful/features/settings/controllers/council_controller.dart';

class FindMyCouncilScreen extends ConsumerStatefulWidget {
  const FindMyCouncilScreen({super.key});

  @override
  ConsumerState<FindMyCouncilScreen> createState() => _FindMyCouncilScreenState();
}

class _FindMyCouncilScreenState extends ConsumerState<FindMyCouncilScreen> {
  final _focusNode = FocusNode();
  Council? _selectedCouncil;

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _openCouncilPage(Council council) async {
    final uri = Uri.parse(council.url);
    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);

    if (!launched && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Couldn\'t open ${council.council}\'s website')),
      );
    }
  }

  @override
  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      appBar: CustomAppBar(showBack: true, title: 'Find My Council'),
      body: FutureBuilder<List<Council>>(
        future: ref.read(councilRepositoryProvider).getCouncils(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError || !snapshot.hasData) {
            return Center(
              child: Text('Couldn\'t load council list', style: TextStyle(color: colors.textMuted)),
            );
          }

          final councils = snapshot.data!;

          return Padding(
            padding: context.padding(PaddingSize.medium),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Search your council to find their bin collection page.',
                  style: Theme.of(context).textTheme.bodySmall!.copyWith(
                    color: colors.textMuted,
                    fontSize: context.fontSize(FontSize.normal)
                  )
                ),
                const SizedBox(height: 12),
                SearchField<Council>(
                  key: const Key('council_search_field'),
                  focusNode: _focusNode,
                  itemHeight: context.fontSize(FontSize.extraLarge) * 5,
                  suggestionState: Suggestion.expand,
                  searchInputDecoration: SearchInputDecoration(
                    hintText: "Search your council",
                    hintStyle: TextStyle(color: colors.textMuted),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: colors.accent),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: colors.inverseBackground),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: colors.accent),
                    ),
                  ),
                  suggestionsDecoration: SuggestionDecoration(
                    padding: context.padding(PaddingSize.small),
                    border: Border.all(color: colors.border),
                    borderRadius: BorderRadius.circular(12),
                    color: colors.surface,
                  ),
                  suggestions: councils.map((council) => SearchFieldListItem<Council>(
                    '${council.council} (${council.country})',
                    item: council,
                    child: Padding(
                      padding: context.padding(PaddingSize.small),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                          Expanded(
                            child: ListTile(
                            trailing: Icon(Icons.arrow_forward_ios_outlined, color: colors.inverseBackground,),
                            title: Text(council.council, style: Theme.of(context).textTheme.titleMedium),
                            subtitle: Text(
                              council.country,
                              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                color: colors.textMuted
                              )
                            ),
                          ) 
                          )         
                        ],
                      ),
                    ),
                  )).toList(),
                  onSuggestionTap: (SearchFieldListItem<Council> item) {
                    setState(() => _selectedCouncil = item.item);
                    _focusNode.unfocus();
                  },
                ),
                const SizedBox(height: 20),

                if (_selectedCouncil != null)
                  Container(
                    padding: context.padding(PaddingSize.small),
                    decoration: BoxDecoration(
                      color: colors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: colors.border),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(_selectedCouncil!.council, style: Theme.of(context).textTheme.titleMedium),
                              const SizedBox(height: 2),
                              Text(
                                _selectedCouncil!.country,
                                style: TextStyle(fontSize: 12, color: colors.textMuted),
                              ),
                            ],
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: () => _openCouncilPage(_selectedCouncil!),
                          icon: const Icon(Icons.open_in_new, size: 16, color: Colors.white),
                          label: const Text('Open', style: TextStyle(color: Colors.white)),
                          style: ElevatedButton.styleFrom(backgroundColor: colors.accent),
                        ),
                      ],
                    ),
                  ),
                const Spacer(),

                Text(
                  'Can\'t find yours? Search "bin collection days" plus your area or postcode.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall!.copyWith(
                    color: colors.textPrimary,
                    fontSize: context.fontSize(FontSize.normal)
                  )
                ),
                
              ],
            ),
          );
        },
      ),
    );
  }
}