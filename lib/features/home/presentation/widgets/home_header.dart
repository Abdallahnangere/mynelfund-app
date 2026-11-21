import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../../app/app.dart';
import '../../../../core/localization/app_locale.dart';
import '../../../../core/localization/app_translations.dart';
import '../../../../core/localization/locale_provider.dart';
import '../../../../core/theme/nelfund_colors.dart';
import '../../../../shared/widgets/liquid_glass_header.dart';
import '../../../notifications/presentation/providers/notification_provider.dart';
import '../../../notifications/presentation/views/notifications_view.dart';
import '../../../promo/presentation/widgets/get_data_header_button.dart';

/// Frosted Home header with NELFUND emblem, Sauki Go header pill, live unread
/// notification badge, and integrated English/Hausa segmented toggle.
class HomeHeader extends StatelessWidget {
  /// Creates a [HomeHeader].
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final tr = AppTranslations.of(context);

    return LiquidGlassHeader(
      title: tr.appTitle,
      subtitle: tr.appSubtitle,
      leading: Container(
        width: 42,
        height: 42,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: CupertinoColors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: NelfundColors.emerald.withValues(alpha: 0.18),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
          border: Border.all(
            color: NelfundColors.emerald.withValues(alpha: 0.35),
            width: 1.2,
          ),
        ),
        child: ClipOval(
          child: Image.asset(
            'assets/images/nelfund_logo.png',
            fit: BoxFit.contain,
            errorBuilder: (_, _, _) => const Icon(
              CupertinoIcons.building_2_fill,
              color: NelfundColors.emerald,
              size: 20,
            ),
          ),
        ),
      ),
      trailing: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GetDataHeaderButton(),
          SizedBox(width: 8),
          _NotificationsBellButton(),
        ],
      ),
      bottom: const _HeaderLanguageToggle(),
    );
  }
}

class _NotificationsBellButton extends StatelessWidget {
  const _NotificationsBellButton();

  @override
  Widget build(BuildContext context) {
    final isDark = CupertinoTheme.of(context).brightness == Brightness.dark;
    final hasNotifProv =
        AppProviders.maybeRead<NotificationProvider>(context) != null;
    final hasUnread = hasNotifProv
        ? context.select<NotificationProvider, bool>((p) => p.hasUnread)
        : false;

    return Semantics(
      button: true,
      label: AppTranslations.of(context).officialBulletinsTitle,
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        minimumSize: Size.zero,
        onPressed: () {
          HapticFeedback.lightImpact();
          Navigator.of(context).push(
            CupertinoPageRoute<void>(builder: (_) => const NotificationsView()),
          );
        },
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: CupertinoDynamicColor.resolve(
                  const CupertinoDynamicColor.withBrightness(
                    color: Color(0xFFF0F4F1),
                    darkColor: Color(0xFF242C26),
                  ),
                  context,
                ),
                border: Border.all(
                  color: NelfundColors.emerald.withValues(alpha: 0.25),
                  width: 1,
                ),
              ),
              child: const Center(
                child: Icon(
                  CupertinoIcons.bell_fill,
                  size: 18,
                  color: NelfundColors.emerald,
                ),
              ),
            ),
            if (hasUnread)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE53935),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isDark
                          ? const Color(0xFF161718)
                          : CupertinoColors.white,
                      width: 1.8,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _HeaderLanguageToggle extends StatelessWidget {
  const _HeaderLanguageToggle();

  @override
  Widget build(BuildContext context) {
    final hasLocale = AppProviders.maybeRead<LocaleProvider>(context) != null;
    final localeProv = hasLocale ? context.watch<LocaleProvider>() : null;
    final isHausa = localeProv?.isHausa ?? false;
    final isDark = CupertinoTheme.of(context).brightness == Brightness.dark;

    return Container(
      height: 38,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: CupertinoDynamicColor.resolve(
          const CupertinoDynamicColor.withBrightness(
            color: Color(0xFFE8EFE9),
            darkColor: Color(0xFF222824),
          ),
          context,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: NelfundColors.emerald.withValues(alpha: isDark ? 0.25 : 0.15),
          width: 0.8,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _LanguageSegmentOption(
              flag: '🇬🇧',
              label: 'English',
              isSelected: !isHausa,
              isDark: isDark,
              onTap: () {
                if (isHausa) {
                  HapticFeedback.selectionClick();
                  localeProv?.setLanguage(AppLanguage.english);
                }
              },
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: _LanguageSegmentOption(
              flag: '🇳🇬',
              label: 'Harshen Hausa',
              isSelected: isHausa,
              isDark: isDark,
              onTap: () {
                if (!isHausa) {
                  HapticFeedback.selectionClick();
                  localeProv?.setLanguage(AppLanguage.hausa);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _LanguageSegmentOption extends StatelessWidget {
  const _LanguageSegmentOption({
    required this.flag,
    required this.label,
    required this.isSelected,
    required this.isDark,
    required this.onTap,
  });

  final String flag;
  final String label;
  final bool isSelected;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: isSelected,
      label: label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 6),
          decoration: BoxDecoration(
            color: isSelected
                ? (isDark ? const Color(0xFF153822) : CupertinoColors.white)
                : CupertinoColors.transparent,
            borderRadius: BorderRadius.circular(9),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: CupertinoColors.black.withValues(alpha: 0.08),
                      blurRadius: 4,
                      offset: const Offset(0, 1.5),
                    ),
                  ]
                : null,
          ),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(flag, style: const TextStyle(fontSize: 14)),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    color: isSelected
                        ? NelfundColors.emerald
                        : CupertinoDynamicColor.resolve(
                            NelfundColors.secondaryLabel,
                            context,
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
