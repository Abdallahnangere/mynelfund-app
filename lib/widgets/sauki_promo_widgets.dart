import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../core/localization/app_translations.dart';
import '../core/localization/locale_provider.dart';
import '../core/services/analytics_service.dart';
import '../core/theme/nelfund_colors.dart';
import '../core/theme/nelfund_typography.dart';
import '../models/promo_model.dart';
import '../providers/promo_provider.dart';
import 'apple_frosted_card.dart';
import 'store_badges.dart';

PromoProvider? _maybeWatchPromoProvider(BuildContext context) {
  try {
    return Provider.of<PromoProvider?>(context);
  } catch (_) {
    return null;
  }
}

PromoProvider? _maybeReadPromoProvider(BuildContext context) {
  try {
    return Provider.of<PromoProvider?>(context, listen: false);
  } catch (_) {
    return null;
  }
}

bool _resolveIsHausa(BuildContext context) {
  try {
    final localeProv = Provider.of<LocaleProvider?>(context);
    return localeProv?.isHausa ?? false;
  } catch (_) {
    return false;
  }
}

/// Compact, always-visible "[ ⚡ Get Data ]" pill placed beside the notification
/// bell in HomeView's LiquidGlassHeader.
class GetDataHeaderButton extends StatelessWidget {
  const GetDataHeaderButton({super.key});

  @override
  Widget build(BuildContext context) {
    final promoProv = _maybeWatchPromoProvider(context);
    final config = promoProv?.config ?? SaukiPromoConfig.defaults;
    if (!config.enabled) return const SizedBox.shrink();

    final isDark = CupertinoTheme.brightnessOf(context) == Brightness.dark;
    final tr = AppTranslations.of(context);

    return CupertinoButton(
      key: const ValueKey('header_get_data_button'),
      padding: EdgeInsets.zero,
      minimumSize: Size.zero,
      pressedOpacity: 0.75,
      onPressed: () {
        HapticFeedback.lightImpact();
        SaukiPromoModal.show(context, trigger: 'header_get_data');
      },
      child: Container(
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 11),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? const [Color(0xFF173826), Color(0xFF1F2B22)]
                : const [Color(0xFFEAF6EF), Color(0xFFF7F4EA)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: NelfundColors.emerald.withValues(alpha: isDark ? 0.45 : 0.30),
            width: 1.0,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                color: NelfundColors.emerald.withValues(alpha: 0.16),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(
                  CupertinoIcons.bolt_fill,
                  size: 11,
                  color: NelfundColors.emerald,
                ),
              ),
            ),
            const SizedBox(width: 5),
            Text(
              tr.getDataHeaderLabel,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: isDark
                    ? const Color(0xFF68D391)
                    : NelfundColors.emeraldDark,
                letterSpacing: -0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Minimal, non-intrusive inline companion-app card positioned on HomeView
/// between Program Overview and Key Loan Pillars.
class SaukiPromoHomeCard extends StatefulWidget {
  const SaukiPromoHomeCard({super.key});

  @override
  State<SaukiPromoHomeCard> createState() => _SaukiPromoHomeCardState();
}

class _SaukiPromoHomeCardState extends State<SaukiPromoHomeCard> {
  bool _loggedImpression = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_loggedImpression) {
      _loggedImpression = true;
      unawaited(
        AnalyticsService.instance.logSaukiPromoImpression(
          placement: 'home_card',
        ),
      );
    }
  }

  Future<void> _handleStoreTap(
    BuildContext context,
    SaukiStorePlatform platform,
  ) async {
    final promoProv = _maybeReadPromoProvider(context);
    if (promoProv != null) {
      await promoProv.openStore(platform, placement: 'home_card');
    }
  }

  @override
  Widget build(BuildContext context) {
    final promoProv = _maybeWatchPromoProvider(context);
    final config = promoProv?.config ?? SaukiPromoConfig.defaults;
    if (!config.enabled) return const SizedBox.shrink();

    final isHausa = _resolveIsHausa(context);
    final tr = AppTranslations.of(context);
    final isDark = CupertinoTheme.brightnessOf(context) == Brightness.dark;

    return AppleFrostedCard(
      key: const ValueKey('sauki_promo_home_card'),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.fromLTRB(14, 13, 14, 13),
      borderRadius: 16,
      borderColor: NelfundColors.emerald.withValues(alpha: isDark ? 0.35 : 0.22),
      onTap: () => SaukiPromoModal.show(context, trigger: 'home_card'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row: Sauki Go Brand Mark + Headline + Monthly Pill
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const _SaukiBrandEmblem(size: 36),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            config.appName,
                            style: NelfundTypography.headline.copyWith(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 1.5,
                            ),
                            decoration: BoxDecoration(
                              color: NelfundColors.goldAccent.withValues(
                                alpha: isDark ? 0.20 : 0.14,
                              ),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              tr.saukiTrustedTag,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                                color: isDark
                                    ? const Color(0xFFE9C46A)
                                    : const Color(0xFF8C6518),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      config.headline(isHausa),
                      style: NelfundTypography.footnote.copyWith(
                        fontSize: 12.5,
                        height: 1.28,
                        color: CupertinoDynamicColor.resolve(
                          NelfundColors.secondaryLabel,
                          context,
                        ),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 96),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: NelfundColors.emerald.withValues(
                      alpha: isDark ? 0.18 : 0.10,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      config.monthlyTag(isHausa),
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w500,
                        color: isDark
                            ? const Color(0xFF68D391)
                            : NelfundColors.emeraldDark,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Compact Plan Snippets Row (1GB ₦400 | 5GB ₦1,500 Monthly)
          Row(
            children: [
              Expanded(
                child: _CompactPlanPill(
                  dataAmount: config.plan1Data,
                  price: config.plan1Price,
                  period: config.plan1Period(isHausa),
                  isHighlighted: false,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _CompactPlanPill(
                  dataAmount: config.plan2Data,
                  price: config.plan2Price,
                  period: config.plan2Period(isHausa),
                  isHighlighted: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Direct 1-Tap Official Store Badges (App Store • For iPhone | Google Play • For Android)
          SaukiStoreBadgeRow(
            compact: true,
            iPhoneOverline: tr.saukiForIphoneLabel,
            androidOverline: tr.saukiForAndroidLabel,
            onSelectStore: (platform) => _handleStoreTap(context, platform),
          ),
        ],
      ),
    );
  }
}

class _CompactPlanPill extends StatelessWidget {
  final String dataAmount;
  final String price;
  final String period;
  final bool isHighlighted;

  const _CompactPlanPill({
    required this.dataAmount,
    required this.price,
    required this.period,
    required this.isHighlighted,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = CupertinoTheme.brightnessOf(context) == Brightness.dark;
    final bgColor = isHighlighted
        ? NelfundColors.emerald.withValues(alpha: isDark ? 0.18 : 0.08)
        : CupertinoDynamicColor.resolve(
            const CupertinoDynamicColor.withBrightness(
              color: Color(0xFFF3F6F4),
              darkColor: Color(0xFF222925),
            ),
            context,
          );
    final borderColor = isHighlighted
        ? NelfundColors.emerald.withValues(alpha: isDark ? 0.40 : 0.25)
        : CupertinoDynamicColor.resolve(
            const CupertinoDynamicColor.withBrightness(
              color: Color(0xFFE0E7E2),
              darkColor: Color(0xFF313A34),
            ),
            context,
          );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderColor, width: 0.8),
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.centerLeft,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              dataAmount,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isHighlighted
                    ? (isDark ? const Color(0xFF68D391) : NelfundColors.emeraldDark)
                    : CupertinoDynamicColor.resolve(NelfundColors.label, context),
              ),
            ),
            Text(
              ' • ',
              style: TextStyle(
                fontSize: 12,
                color: CupertinoDynamicColor.resolve(
                  NelfundColors.tertiaryLabel,
                  context,
                ),
              ),
            ),
            Text(
              price,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: CupertinoDynamicColor.resolve(NelfundColors.label, context),
              ),
            ),
            const SizedBox(width: 4),
            Text(
              '($period)',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w400,
                color: CupertinoDynamicColor.resolve(
                  NelfundColors.secondaryLabel,
                  context,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Minimal, airy Liquid Glass modal dialog for Sauki Go (startup & on-demand).
class SaukiPromoModal extends StatelessWidget {
  final String trigger;

  const SaukiPromoModal({
    super.key,
    required this.trigger,
  });

  static Future<void> show(
    BuildContext context, {
    required String trigger,
  }) async {
    if (!context.mounted) return;
    final promoProv = _maybeReadPromoProvider(context);
    if (trigger == 'startup') {
      await promoProv?.markModalShown();
    }
    unawaited(
      AnalyticsService.instance.logSaukiPromoImpression(
        placement: 'modal_$trigger',
      ),
    );

    if (!context.mounted) return;
    await showCupertinoDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (dialogCtx) => SaukiPromoModal(trigger: trigger),
    );
  }

  void _dismiss(BuildContext context) {
    HapticFeedback.lightImpact();
    unawaited(
      AnalyticsService.instance.logSaukiPromoDismissed(trigger: trigger),
    );
    Navigator.of(context).pop();
  }

  Future<void> _selectStore(
    BuildContext context,
    SaukiStorePlatform platform,
  ) async {
    final promoProv = _maybeReadPromoProvider(context);
    Navigator.of(context).pop();
    if (promoProv != null) {
      await promoProv.openStore(platform, placement: 'modal_$trigger');
    }
  }

  @override
  Widget build(BuildContext context) {
    final promoProv = _maybeWatchPromoProvider(context);
    final config = promoProv?.config ?? SaukiPromoConfig.defaults;
    final isHausa = _resolveIsHausa(context);
    final tr = AppTranslations.of(context);
    final isDark = CupertinoTheme.brightnessOf(context) == Brightness.dark;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 28),
        child: Container(
          key: const ValueKey('sauki_promo_modal'),
          constraints: const BoxConstraints(maxWidth: 380),
          decoration: BoxDecoration(
            color: CupertinoDynamicColor.resolve(
              const CupertinoDynamicColor.withBrightness(
                color: Color(0xFCFFFFFF),
                darkColor: Color(0xFA1A211D),
              ),
              context,
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: NelfundColors.emerald.withValues(alpha: isDark ? 0.35 : 0.22),
              width: 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: CupertinoColors.black.withValues(alpha: isDark ? 0.50 : 0.16),
                blurRadius: 28,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: CupertinoPopupSurface(
            isSurfacePainted: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Top Bar: Subtle Trusted Badge + Close Button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: NelfundColors.emerald.withValues(alpha: 0.10),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: NelfundColors.emerald.withValues(alpha: 0.24),
                              width: 0.8,
                            ),
                          ),
                          child: Text(
                            config.badge(isHausa),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? const Color(0xFF68D391)
                                  : NelfundColors.emeraldDark,
                              letterSpacing: 0.4,
                              decoration: TextDecoration.none,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      CupertinoButton(
                        key: const ValueKey('sauki_modal_close_button'),
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        onPressed: () => _dismiss(context),
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: CupertinoDynamicColor.resolve(
                              const CupertinoDynamicColor.withBrightness(
                                color: Color(0xFFF0F3F1),
                                darkColor: Color(0xFF28302B),
                              ),
                              context,
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            CupertinoIcons.xmark,
                            size: 13,
                            color: CupertinoDynamicColor.resolve(
                              NelfundColors.secondaryLabel,
                              context,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Emblem + Brand Name + Headline + Clean Subtitle
                  const _SaukiBrandEmblem(size: 52),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Text(
                          config.appName,
                          style: NelfundTypography.headline.copyWith(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? const Color(0xFF68D391)
                                : NelfundColors.emeraldDark,
                            decoration: TextDecoration.none,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: NelfundColors.goldAccent.withValues(
                            alpha: isDark ? 0.22 : 0.14,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          config.monthlyTag(isHausa),
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w500,
                            color: isDark
                                ? const Color(0xFFE9C46A)
                                : const Color(0xFF8C6518),
                            decoration: TextDecoration.none,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    config.headline(isHausa),
                    textAlign: TextAlign.center,
                    style: NelfundTypography.title2.copyWith(
                      fontSize: 17.5,
                      fontWeight: FontWeight.w600,
                      height: 1.25,
                      letterSpacing: -0.3,
                      decoration: TextDecoration.none,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    config.subtitle(isHausa),
                    textAlign: TextAlign.center,
                    style: NelfundTypography.footnote.copyWith(
                      fontSize: 12.5,
                      height: 1.35,
                      color: CupertinoDynamicColor.resolve(
                        NelfundColors.secondaryLabel,
                        context,
                      ),
                      decoration: TextDecoration.none,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Plan Snippets Grid (1GB ₦400 | 5GB ₦1,500 • All Monthly)
                  Row(
                    children: [
                      Expanded(
                        child: _ModalPlanCard(
                          dataAmount: config.plan1Data,
                          price: config.plan1Price,
                          period: config.plan1Period(isHausa),
                          isFeatured: false,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _ModalPlanCard(
                          dataAmount: config.plan2Data,
                          price: config.plan2Price,
                          period: config.plan2Period(isHausa),
                          isFeatured: true,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Dual Direct Store Badges (App Store • For iPhone | Google Play • For Android)
                  SaukiStoreBadgeRow(
                    compact: false,
                    iPhoneOverline: tr.saukiModalIphoneOverline,
                    androidOverline: tr.saukiModalAndroidOverline,
                    onSelectStore: (platform) => _selectStore(context, platform),
                  ),
                  const SizedBox(height: 10),

                  // Minimal Non-Intrusive Dismiss Link
                  CupertinoButton(
                    key: const ValueKey('sauki_modal_later_button'),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    minimumSize: Size.zero,
                    onPressed: () => _dismiss(context),
                    child: Text(
                      tr.saukiMaybeLaterLabel,
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w500,
                        color: CupertinoDynamicColor.resolve(
                          NelfundColors.secondaryLabel,
                          context,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ModalPlanCard extends StatelessWidget {
  final String dataAmount;
  final String price;
  final String period;
  final bool isFeatured;

  const _ModalPlanCard({
    required this.dataAmount,
    required this.price,
    required this.period,
    required this.isFeatured,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = CupertinoTheme.brightnessOf(context) == Brightness.dark;
    final bgColor = isFeatured
        ? NelfundColors.emerald.withValues(alpha: isDark ? 0.18 : 0.08)
        : CupertinoDynamicColor.resolve(
            const CupertinoDynamicColor.withBrightness(
              color: Color(0xFFF6F9F7),
              darkColor: Color(0xFF222925),
            ),
            context,
          );
    final borderColor = isFeatured
        ? NelfundColors.emerald.withValues(alpha: isDark ? 0.45 : 0.30)
        : CupertinoDynamicColor.resolve(
            const CupertinoDynamicColor.withBrightness(
              color: Color(0xFFE3EAE5),
              darkColor: Color(0xFF323B35),
            ),
            context,
          );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor, width: 1.0),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            dataAmount,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: isFeatured
                  ? (isDark ? const Color(0xFF68D391) : NelfundColors.emeraldDark)
                  : CupertinoDynamicColor.resolve(NelfundColors.label, context),
              letterSpacing: -0.3,
              decoration: TextDecoration.none,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            price,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: CupertinoDynamicColor.resolve(NelfundColors.label, context),
              decoration: TextDecoration.none,
            ),
          ),
          const SizedBox(height: 3),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
            decoration: BoxDecoration(
              color: isFeatured
                  ? NelfundColors.goldAccent.withValues(alpha: isDark ? 0.22 : 0.14)
                  : CupertinoColors.systemGrey5.resolveFrom(context),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              period,
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w500,
                color: isFeatured
                    ? (isDark ? const Color(0xFFE9C46A) : const Color(0xFF8C6518))
                    : CupertinoDynamicColor.resolve(
                        NelfundColors.secondaryLabel,
                        context,
                      ),
                decoration: TextDecoration.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SaukiBrandEmblem extends StatelessWidget {
  final double size;

  const _SaukiBrandEmblem({required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [NelfundColors.emerald, NelfundColors.emeraldDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(size * 0.28),
        boxShadow: [
          BoxShadow(
            color: NelfundColors.emerald.withValues(alpha: 0.24),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(
            CupertinoIcons.wifi,
            size: size * 0.48,
            color: CupertinoColors.white,
          ),
          Positioned(
            right: size * 0.14,
            bottom: size * 0.14,
            child: Container(
              width: size * 0.28,
              height: size * 0.28,
              decoration: const BoxDecoration(
                color: Color(0xFFE0A82E),
                shape: BoxShape.circle,
              ),
              child: Icon(
                CupertinoIcons.bolt_fill,
                size: size * 0.18,
                color: CupertinoColors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
