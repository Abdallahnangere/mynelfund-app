import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../../core/services/analytics_service.dart';
import '../../core/theme/nelfund_colors.dart';
import '../../core/theme/nelfund_typography.dart';
import '../../models/faq_model.dart';
import '../../providers/faq_provider.dart';
import '../../widgets/apple_frosted_card.dart';

class FaqView extends StatelessWidget {
  const FaqView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => FaqProvider(),
      child: const _FaqContent(),
    );
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
    final provider = context.watch<FaqProvider>();
    final items = provider.filteredItems;

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Official FAQ'),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: NelfundColors.emerald.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            '${items.length} ${items.length == 1 ? 'Topic' : 'Topics'}',
            style: NelfundTypography.captionBold.copyWith(
              color: NelfundColors.emerald,
            ),
          ),
        ),
        backgroundColor: CupertinoDynamicColor.resolve(
          const CupertinoDynamicColor.withBrightness(
            color: Color(0xCCF8FAF8),
            darkColor: Color(0xCC161718),
          ),
          context,
        ),
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 14),
          children: [
            _buildSearchBox(context, provider),
            const SizedBox(height: 10),
            _buildCategoryFilterStrip(context, provider),
            const SizedBox(height: 12),
            if (provider.searchQuery.isEmpty &&
                provider.selectedCategory == FaqCategory.all) ...[
              _buildSpotlightCarousel(context),
              const SizedBox(height: 12),
            ],
            if (items.isEmpty)
              _buildEmptySearchState(context, provider)
            else
              ...items.map((item) => _buildFaqTile(context, provider, item)),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBox(BuildContext context, FaqProvider provider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: CupertinoSearchTextField(
        controller: _searchController,
        placeholder: 'Search questions, GSI, refund, moratorium...',
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

  Widget _buildCategoryFilterStrip(BuildContext context, FaqProvider provider) {
    return SingleChildScrollView(
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
              onPressed: () => provider.setCategory(cat),
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
                  cat.shortLabel,
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

  Widget _buildSpotlightCarousel(BuildContext context) {
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
                  '30-Day Institutional Refund Rule (Sec. 4.1.2)',
                  style: NelfundTypography.headline.copyWith(
                    fontSize: 14,
                    color: NelfundColors.emerald,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'If you already paid tuition before your loan approval, your tertiary institution is mandated by law to refund your payment within 30 days of receiving NELFUND funds.',
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
      BuildContext context, FaqProvider provider, FaqItem item) {
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
                        item.category.shortLabel.toUpperCase(),
                        style: NelfundTypography.captionBold.copyWith(
                          color: NelfundColors.emerald,
                          fontSize: 10,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      item.question,
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
              item.answer,
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
                  item.statutoryReference,
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

  Widget _buildEmptySearchState(BuildContext context, FaqProvider provider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: const Color(0x0F000000),
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
            'No Questions Found',
            style: NelfundTypography.headline.copyWith(fontSize: 17),
          ),
          const SizedBox(height: 6),
          Text(
            'Try searching for terms like "refund", "moratorium", "upkeep", or "GSI".',
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
            child: const Text('Reset Search Filters',
                style: TextStyle(fontSize: 14)),
          ),
        ],
      ),
    );
  }
}
