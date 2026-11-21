import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../../../../app/app.dart';
import '../../../../core/localization/app_translations.dart';
import '../../../../core/localization/locale_provider.dart';
import '../../../../shared/widgets/section_header.dart';
import '../../../promo/presentation/providers/promo_provider.dart';
import '../../../promo/presentation/widgets/sauki_promo_home_card.dart';
import '../../../promo/presentation/widgets/sauki_promo_modal.dart';
import '../widgets/act_overview_card.dart';
import '../widgets/core_pillars_section.dart';
import '../widgets/home_header.dart';
import '../widgets/quick_access_grid.dart';

/// Primary dashboard tab presenting the Act 2024 overview, Sauki Go promo
/// integration, key statutory pillars, and quick-launch tool navigation.
class HomeView extends StatelessWidget {
  /// Creates a [HomeView].
  const HomeView({super.key, this.showStartupPromo = false});

  /// Whether startup promo modal eligibility should be evaluated on mount.
  final bool showStartupPromo;

  @override
  Widget build(BuildContext context) {
    final localeProv = AppProviders.maybeRead<LocaleProvider>(context);
    final promoProv = AppProviders.maybeRead<PromoProvider>(context);

    final content = _HomeViewContent(showStartupPromo: showStartupPromo);

    if (localeProv == null || promoProv == null) {
      return MultiProvider(
        providers: [
          if (localeProv == null)
            ChangeNotifierProvider<LocaleProvider>(
              create: (_) => LocaleProvider(),
            ),
          if (promoProv == null)
            ChangeNotifierProvider<PromoProvider>(
              create: (_) => PromoProvider(),
            ),
        ],
        child: content,
      );
    }

    return content;
  }
}

class _HomeViewContent extends StatefulWidget {
  const _HomeViewContent({required this.showStartupPromo});

  final bool showStartupPromo;

  @override
  State<_HomeViewContent> createState() => _HomeViewContentState();
}

class _HomeViewContentState extends State<_HomeViewContent> {
  @override
  void initState() {
    super.initState();
    if (widget.showStartupPromo) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _checkStartupPromoModal();
      });
    }
  }

  Future<void> _checkStartupPromoModal() async {
    try {
      final promoProv = AppProviders.maybeRead<PromoProvider>(context);
      final shouldShow =
          await (promoProv?.shouldAutoShowModal() ?? Future<bool>.value(false));
      if (shouldShow && mounted) {
        await SaukiPromoModal.show(context, trigger: 'startup');
      }
    } catch (error) {
      debugPrint('[HomeView] Startup promo modal check note: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    final tr = AppTranslations.of(context);

    return CupertinoPageScaffold(
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const HomeHeader(),
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.fromLTRB(0, 12, 0, 88),
                children: [
                  SectionHeader(title: tr.programOverviewTitle),
                  const ActOverviewCard(),
                  const SizedBox(height: 8),
                  const SaukiPromoHomeCard(),
                  const SizedBox(height: 16),
                  SectionHeader(title: tr.keyLoanPillarsTitle),
                  const CorePillarsSection(),
                  const SizedBox(height: 16),
                  SectionHeader(title: tr.exploreToolsTitle),
                  const QuickAccessGrid(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
