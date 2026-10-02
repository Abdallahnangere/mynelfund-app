import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/localization/app_locale.dart';
import '../../core/localization/app_translations.dart';
import '../../core/localization/locale_provider.dart';
import '../../core/services/analytics_service.dart';
import '../../core/theme/nelfund_colors.dart';
import '../../core/theme/nelfund_typography.dart';
import '../../models/faq_model.dart';
import '../../providers/faq_provider.dart';
import '../../widgets/apple_frosted_card.dart';
import '../../widgets/liquid_glass_header.dart';

class FaqView extends StatelessWidget {
  const FaqView({super.key});

  @override
  Widget build(BuildContext context) {
    LocaleProvider? localeProv;
    try {
      localeProv = Provider.of<LocaleProvider?>(context, listen: false);
    } catch (_) {}

    FaqProvider? existingFaqProv;
    try {
      existingFaqProv = Provider.of<FaqProvider?>(context, listen: false);
    } catch (_) {}

    final Widget content = existingFaqProv != null
        ? const _FaqContent()
        : ChangeNotifierProvider(
            create: (_) => FaqProvider(),
            child: const _FaqContent(),
          );

    if (localeProv == null) {
      return ChangeNotifierProvider(
        create: (_) => LocaleProvider(),
        child: content,
      );
    }
    return content;
  }
}

class _FaqContent extends StatefulWidget {
  const _FaqContent();

  @override
  State<_FaqContent> createState() => _FaqContentState();
}

class _FaqContentState extends State<_FaqContent> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localeProv = context.watch<LocaleProvider>();
    final lang = localeProv.currentLanguage;
    final tr = AppTranslations.of(context);
    final provider = context.watch<FaqProvider>();
    final items = provider.filteredItems;

    return CupertinoPageScaffold(
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildFintechHeader(context, items.length, tr),
            Expanded(
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                slivers: [
                  CupertinoSliverRefreshControl(
                    onRefresh: () async {
                      HapticFeedback.lightImpact();
                      await provider.refresh();
                    },
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(0, 12, 0, 88),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        _buildSearchBox(context, provider, tr),
                        const SizedBox(height: 10),
                        _buildCategoryFilterStrip(context, provider, lang),
                        const SizedBox(height: 12),
                        if (provider.searchQuery.isEmpty &&
                            provider.selectedCategory == FaqCategory.all) ...[
                          _buildSpotlightCarousel(context, tr),
                          const SizedBox(height: 12),
                        ],
                        if (items.isEmpty)
                          _buildEmptySearchState(context, provider, tr)
                        else
                          ...items.map((item) => _buildFaqTile(context, provider, item, lang)),
                        const SizedBox(height: 24),
                      ]),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFintechHeader(BuildContext context, int count, AppTranslations tr) {
    final countLabel = tr.isHausa
        ? '$count Tambayoyi'
        : '$count ${count == 1 ? 'Topic' : 'Topics'}';

    return LiquidGlassHeader(
      title: tr.faqHeaderTitle,
      subtitle: tr.isHausa ? 'Bincika Tambayoyi da Amsoshi' : 'Official Legal & Policy Knowledge Base',
      leading: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: NelfundColors.emerald.withValues(alpha: 0.15),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          CupertinoIcons.bubble_left_bubble_right_fill,
          color: NelfundColors.emerald,
          size: 19,
        ),
      ),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: NelfundColors.emerald.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: NelfundColors.emerald.withValues(alpha: 0.3),
            width: 0.8,
          ),
        ),
        child: Text(
          countLabel,
          style: NelfundTypography.captionBold.copyWith(
            color: NelfundColors.emerald,
            fontSize: 11.5,
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBox(BuildContext context, FaqProvider provider, AppTranslations tr) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: CupertinoSearchTextField(
        controller: _searchController,
        placeholder: tr.faqSearchPlaceholder,
        onChanged: provider.setSearchQuery,
        onSubmitted: (query) {
          AnalyticsService.instance.logFaqSearch(
            query: query,
            matchCount: provider.filteredItems.length,
          );
        },
        onSuffixTap: () {
          _searchController.clear();
          provider.setSearchQuery('');
        },
      ),
    );
  }

  Widget _buildCategoryFilterStrip(
    BuildContext context,
    FaqProvider provider,
    AppLanguage lang,
  ) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: FaqCategory.values.map((cat) {
          final isSelected = provider.selectedCategory == cat;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: CupertinoButton(
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              onPressed: () {
                HapticFeedback.selectionClick();
                provider.setCategory(cat);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  color: isSelected
                      ? NelfundColors.emerald
                      : CupertinoDynamicColor.resolve(
                          const CupertinoDynamicColor.withBrightness(
                            color: Color(0x0F000000),
                            darkColor: Color(0x1F2FD18B),
                          ),
                          context,
                        ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  cat.getShortLabel(lang),
                  style: NelfundTypography.captionBold.copyWith(
                    color: isSelected
                        ? CupertinoColors.white
                        : CupertinoDynamicColor.resolve(
                            NelfundColors.label, context),
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSpotlightCarousel(BuildContext context, AppTranslations tr) {
    final isHa = tr.isHausa;

    return AppleFrostedCard(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.all(12),
      backgroundColor: CupertinoDynamicColor.resolve(
        const CupertinoDynamicColor.withBrightness(
          color: Color(0xF2F0FBF5),
          darkColor: Color(0xD0132B1D),
        ),
        context,
      ),
      borderColor: NelfundColors.emerald.withValues(alpha: 0.3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            CupertinoIcons.arrow_2_circlepath_circle_fill,
            color: NelfundColors.emerald,
            size: 22,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isHa
                      ? 'Dokar Mayar da Kuɗi Cikin Kwanaki 30 (Sashe na 4.1.2)'
                      : '30-Day Institutional Refund Rule (Sec. 4.1.2)',
                  style: NelfundTypography.headline.copyWith(
                    fontSize: 14,
                    color: NelfundColors.emerald,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  isHa
                      ? 'Idan ka riga ka biya kuɗin makaranta kafin amincewar bashinka, doka ta tilasta wa makarantarku mayar maka da kuɗinka cikin kwanaki 30 bayan NELFUND ta tura musu kuɗin.'
                      : 'If you already paid tuition before your loan approval, your tertiary institution is mandated by law to refund your payment within 30 days of receiving NELFUND funds.',
                  style: NelfundTypography.footnote.copyWith(fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFaqTile(
    BuildContext context,
    FaqProvider provider,
    FaqItem item,
    AppLanguage lang,
  ) {
    final isExpanded = provider.isExpanded(item.id);

    return AppleFrostedCard(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      padding: const EdgeInsets.all(14),
      onTap: () => provider.toggleExpansion(item.id),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: NelfundColors.emerald.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        item.category.getShortLabel(lang).toUpperCase(),
                        style: NelfundTypography.captionBold.copyWith(
                          color: NelfundColors.emerald,
                          fontSize: 10,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      item.getQuestion(lang),
                      style: NelfundTypography.headline.copyWith(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                isExpanded
                    ? CupertinoIcons.chevron_up
                    : CupertinoIcons.chevron_down,
                size: 18,
                color: CupertinoColors.secondaryLabel,
              ),
            ],
          ),
          if (isExpanded) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              height: 0.5,
              color: const Color(0x14000000),
            ),
            const SizedBox(height: 10),
            Text(
              item.getAnswer(lang),
              style: NelfundTypography.body.copyWith(
                fontSize: 14,
                color: CupertinoDynamicColor.resolve(
                    NelfundColors.secondaryLabel, context),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(
                  CupertinoIcons.bookmark_fill,
                  size: 13,
                  color: NelfundColors.emerald,
                ),
                const SizedBox(width: 6),
                Text(
                  item.getStatutoryReference(lang),
                  style: NelfundTypography.captionBold.copyWith(
                    color: NelfundColors.emerald,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptySearchState(BuildContext context, FaqProvider provider, AppTranslations tr) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: const BoxDecoration(
              color: Color(0x0F000000),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Icon(
                CupertinoIcons.search,
                size: 30,
                color: CupertinoColors.secondaryLabel,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            tr.faqNoResultsTitle,
            style: NelfundTypography.headline.copyWith(fontSize: 17),
          ),
          const SizedBox(height: 6),
          Text(
            tr.faqNoResultsDesc,
            textAlign: TextAlign.center,
            style: NelfundTypography.footnote.copyWith(
              color: CupertinoDynamicColor.resolve(
                  NelfundColors.secondaryLabel, context),
            ),
          ),
          const SizedBox(height: 16),
          CupertinoButton(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: NelfundColors.emerald,
            onPressed: () {
              _searchController.clear();
              provider.resetFilters();
            },
            child: Text(
              tr.isHausa ? 'Sake Farawa' : 'Reset Search Filters',
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
