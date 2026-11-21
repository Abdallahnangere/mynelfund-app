import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../app/app.dart';
import '../../../../core/localization/app_translations.dart';
import '../../../../core/localization/locale_provider.dart';
import '../../../../core/services/analytics_service.dart';
import '../../../../shared/widgets/store_badges.dart';
import '../../domain/promo_model.dart';
import '../providers/promo_provider.dart';
import 'compact_plan_pill.dart';

/// Modal sheet highlighting the Sauki Go companion app with analytics tracking,
/// remote copy configuration, and direct App Store / Google Play links.
class SaukiPromoModal extends StatelessWidget {
  /// Creates a [SaukiPromoModal] opened via [trigger].
  const SaukiPromoModal({super.key, this.trigger = 'startup'});

  /// Origin placement identifier (`'startup'`, `'header_get_data'`, etc.).
  final String trigger;

  /// Presents [SaukiPromoModal] inside a Cupertino dialog overlay.
  static Future<void> show(
    BuildContext context, {
    String trigger = 'startup',
  }) async {
    if (!context.mounted) {
      return;
    }
    final promoProv = AppProviders.maybeRead<PromoProvider>(context);
    if (trigger == 'startup') {
      await promoProv?.markModalShown();
    }
    unawaited(
      AnalyticsService.instance.logSaukiPromoImpression(
        placement: 'modal_$trigger',
      ),
    );

    if (!context.mounted) {
      return;
    }
    await showCupertinoDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (_) => SaukiPromoModal(trigger: trigger),
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
    SaukiPromoConfig config,
  ) async {
    final promoProv = AppProviders.maybeRead<PromoProvider>(context);
    Navigator.of(context).pop();
    if (promoProv != null) {
      await promoProv.openStore(platform, placement: 'modal_$trigger');
    } else {
      final url = platform == SaukiStorePlatform.ios
          ? config.appStoreUrl
          : config.playStoreUrl;
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final promoProv = AppProviders.maybeRead<PromoProvider>(context) != null
        ? context.watch<PromoProvider>()
        : null;
    final config = promoProv?.config ?? SaukiPromoConfig.defaults;
    final isHausa = AppProviders.maybeRead<LocaleProvider>(context) != null
        ? context.watch<LocaleProvider>().isHausa
        : false;
    final tr = AppTranslations.of(context);

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
        child: CupertinoPopupSurface(
          isSurfacePainted: false,
          child: Container(
            key: const ValueKey('sauki_promo_modal'),
            width: double.infinity,
            constraints: const BoxConstraints(maxWidth: 400),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF0D593C),
                  Color(0xFF073A26),
                  Color(0xFF0A1F17),
                ],
              ),
              border: Border.all(color: const Color(0x526EE7B7), width: 0.9),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x5C000000),
                  blurRadius: 28,
                  offset: Offset(0, 14),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0x286EE7B7),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            config.badge(isHausa),
                            style: const TextStyle(
                              color: Color(0xFF6EE7B7),
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Semantics(
                      button: true,
                      label: tr.buttonDone,
                      child: CupertinoButton(
                        key: const ValueKey('sauki_modal_close_button'),
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(32, 32),
                        onPressed: () => _dismiss(context),
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: const BoxDecoration(
                            color: Color(0x26FFFFFF),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            CupertinoIcons.xmark,
                            color: CupertinoColors.white,
                            size: 15,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      config.appName,
                      style: const TextStyle(
                        color: CupertinoColors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.4,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0x20FFFFFF),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        config.monthlyTag(isHausa),
                        style: const TextStyle(
                          color: CupertinoColors.white,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  config.headline(isHausa),
                  style: const TextStyle(
                    color: CupertinoColors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  config.subtitle(isHausa),
                  style: const TextStyle(
                    color: Color(0xC8FFFFFF),
                    fontSize: 12.5,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    CompactPlanPill(
                      dataLabel: config.plan1Data,
                      priceLabel: config.plan1Price,
                      periodLabel: config.plan1Period(isHausa),
                    ),
                    CompactPlanPill(
                      dataLabel: config.plan2Data,
                      priceLabel: config.plan2Price,
                      periodLabel: config.plan2Period(isHausa),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                SaukiStoreBadgeRow(
                  appStoreKey: const ValueKey('sauki_modal_app_store_badge'),
                  playStoreKey: const ValueKey('sauki_modal_play_store_badge'),
                  iphoneOverline: tr.saukiModalIphoneOverline,
                  androidOverline: tr.saukiModalAndroidOverline,
                  onAppStoreTap: () =>
                      _selectStore(context, SaukiStorePlatform.ios, config),
                  onPlayStoreTap: () =>
                      _selectStore(context, SaukiStorePlatform.android, config),
                ),
                const SizedBox(height: 10),
                Center(
                  child: CupertinoButton(
                    key: const ValueKey('sauki_modal_later_button'),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    onPressed: () => _dismiss(context),
                    child: Text(
                      tr.saukiMaybeLaterLabel,
                      style: const TextStyle(
                        color: Color(0xC8FFFFFF),
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
