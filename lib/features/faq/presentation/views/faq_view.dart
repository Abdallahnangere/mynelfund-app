import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../../app/app.dart';
import '../../../../core/localization/app_locale.dart';
import '../../../../core/localization/app_translations.dart';
import '../../../../core/localization/locale_provider.dart';
import '../../../../core/theme/nelfund_colors.dart';
import '../../../../shared/widgets/liquid_glass_header.dart';
import '../providers/faq_provider.dart';
import '../widgets/faq_accordion_tile.dart';
import '../widgets/faq_category_filter.dart';
import '../widgets/faq_refund_spotlight_card.dart';
import '../widgets/faq_search_bar.dart';
import '../widgets/faq_states.dart';

/// Bilingual, offline-capable Official FAQ browser backed by statutory Students
/// Loans Act 2024 references and Firestore real-time synchronization.
class FaqView extends StatelessWidget {
  /// Creates a [FaqView].
  const FaqView({super.key});

  @override
  Widget build(BuildContext context) {
    final localeProv = AppProviders.maybeRead<LocaleProvider>(context);
    final faqProv = AppProviders.maybeRead<FaqProvider>(context);

    if (localeProv == null || faqProv == null) {
      return MultiProvider(
        providers: [
          if (localeProv == null)
            ChangeNotifierProvider<LocaleProvider>(
              create: (_) => LocaleProvider(),
            ),
          if (faqProv == null)
            ChangeNotifierProvider<FaqProvider>(create: (_) => FaqProvider()),
        ],
        child: const _FaqViewContent(),
      );
    }

    return const _FaqViewContent();
  }
}

class _FaqViewContent extends StatefulWidget {
  const _FaqViewContent();

  @override
  State<_FaqViewContent> createState() => _FaqViewContentState();
}

class _FaqViewContentState extends State<_FaqViewContent> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _resetFilters(FaqProvider faqProv) {
    _searchController.clear();
    faqProv.resetFilters();
  }

  @override
  Widget build(BuildContext context) {
    final tr = AppTranslations.of(context);
    final lang = context.select<LocaleProvider, AppLanguage>(
      (p) => p.currentLanguage,
    );
    final faqProv = context.watch<FaqProvider>();
    final items = faqProv.filteredItems;

    return CupertinoPageScaffold(
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            LiquidGlassHeader(
              title: tr.faqHeaderTitle,
              subtitle: tr.isHausa
                  ? 'Ka\'idojin Dokar Lamuni ta 2024'
                  : 'Students Loans Act 2024 Reference',
              leading: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: NelfundColors.emerald.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  CupertinoIcons.question_circle_fill,
                  color: NelfundColors.emerald,
                  size: 20,
                ),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: NelfundColors.emerald.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: NelfundColors.emerald.withValues(alpha: 0.3),
                        width: 0.75,
                      ),
                    ),
                    child: Text(
                      '${faqProv.allItems.length} ${tr.isHausa ? 'Batutuwa' : 'Topics'}',
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: NelfundColors.emerald,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  CupertinoButton(
                    padding: const EdgeInsets.all(6),
                    minimumSize: const Size(34, 34),
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      faqProv.refresh();
                    },
                    child: const Icon(
                      CupertinoIcons.arrow_clockwise,
                      color: NelfundColors.emerald,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                slivers: [
                  SliverToBoxAdapter(
                    child: FaqSearchBar(
                      controller: _searchController,
                      placeholder: tr.faqSearchPlaceholder,
                      onChanged: faqProv.setSearchQuery,
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: FaqCategoryFilter(
                      selectedCategory: faqProv.selectedCategory,
                      language: lang,
                      onSelected: faqProv.setCategory,
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: FaqRefundSpotlightCard(isHausa: tr.isHausa),
                  ),
                  if (faqProv.isLoading && items.isEmpty)
                    SliverToBoxAdapter(
                      child: FaqLoadingView(isHausa: tr.isHausa),
                    )
                  else if (items.isEmpty)
                    SliverToBoxAdapter(
                      child: FaqEmptyView(
                        title: tr.faqNoResultsTitle,
                        description: tr.faqNoResultsDesc,
                        resetLabel: tr.buttonReset,
                        onReset: () => _resetFilters(faqProv),
                      ),
                    )
                  else
                    SliverList.builder(
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final item = items[index];
                        return FaqAccordionTile(
                          item: item,
                          isExpanded: faqProv.isExpanded(item.id),
                          language: lang,
                          onToggle: () => faqProv.toggleExpansion(item.id),
                        );
                      },
                    ),
                  const SliverToBoxAdapter(child: SizedBox(height: 96)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
