import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../app/app.dart';
import '../../../../core/localization/app_translations.dart';
import '../../../../core/localization/locale_provider.dart';
import '../../../../shared/widgets/store_badges.dart';
import '../../domain/promo_model.dart';
import '../providers/promo_provider.dart';
import 'compact_plan_pill.dart';

/// Emerald gradient promotional card embedded on [HomeView] showcasing the
/// Sauki Go student data/airtime companion app when enabled remotely.
class SaukiPromoHomeCard extends StatelessWidget {
  /// Creates a [SaukiPromoHomeCard].
  const SaukiPromoHomeCard({
    super.key = const ValueKey('sauki_promo_home_card'),
  });

  @override
  Widget build(BuildContext context) {
    final promoProv = _watchOptionalPromoProvider(context);
    final config = promoProv?.config ?? SaukiPromoConfig.defaults;
    if (!config.enabled) {
      return const SizedBox.shrink();
    }

    final isHausa = _watchIsHausa(context);
    final tr = AppTranslations.of(context);

    return RepaintBoundary(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF0A4D34), Color(0xFF073A26), Color(0xFF0A241A)],
            ),
            border: Border.all(color: const Color(0x456EE7B7), width: 0.75),
            boxShadow: const [
              BoxShadow(
                color: Color(0x28064E3B),
                blurRadius: 18,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0x226EE7B7),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: const Color(0x4D6EE7B7),
                          width: 0.6,
                        ),
                      ),
                      child: Text(
                        tr.saukiTrustedTag,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF6EE7B7),
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.6,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0x1EFFFFFF),
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
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0x246EE7B7),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      CupertinoIcons.bolt_fill,
                      color: Color(0xFF6EE7B7),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          config.appName,
                          style: const TextStyle(
                            color: CupertinoColors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          config.headline(isHausa),
                          style: const TextStyle(
                            color: Color(0xE0FFFFFF),
                            fontSize: 12.5,
                            fontWeight: FontWeight.w500,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                config.subtitle(isHausa),
                style: const TextStyle(
                  color: Color(0xB8FFFFFF),
                  fontSize: 11.5,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
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
              const SizedBox(height: 14),
              SaukiStoreBadgeRow(
                compact: true,
                appStoreKey: const ValueKey('sauki_home_app_store_badge'),
                playStoreKey: const ValueKey('sauki_home_play_store_badge'),
                iphoneOverline: tr.saukiForIphoneLabel,
                androidOverline: tr.saukiForAndroidLabel,
                onAppStoreTap: () {
                  if (promoProv != null) {
                    promoProv.openStore(
                      SaukiStorePlatform.ios,
                      placement: 'home_card',
                    );
                  } else {
                    unawaited(
                      launchUrl(
                        Uri.parse(config.appStoreUrl),
                        mode: LaunchMode.externalApplication,
                      ),
                    );
                  }
                },
                onPlayStoreTap: () {
                  if (promoProv != null) {
                    promoProv.openStore(
                      SaukiStorePlatform.android,
                      placement: 'home_card',
                    );
                  } else {
                    unawaited(
                      launchUrl(
                        Uri.parse(config.playStoreUrl),
                        mode: LaunchMode.externalApplication,
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  PromoProvider? _watchOptionalPromoProvider(BuildContext context) {
    if (AppProviders.maybeRead<PromoProvider>(context) == null) {
      return null;
    }
    return context.watch<PromoProvider>();
  }

  bool _watchIsHausa(BuildContext context) {
    if (AppProviders.maybeRead<LocaleProvider>(context) == null) {
      return false;
    }
    return context.watch<LocaleProvider>().isHausa;
  }
}
