import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../../app/app.dart';
import '../../../../core/localization/app_translations.dart';
import '../../../../core/theme/nelfund_colors.dart';
import '../../domain/promo_model.dart';
import '../providers/promo_provider.dart';
import 'sauki_promo_modal.dart';

/// Compact glass pill placed beside the notification bell in the Home header,
/// automatically hiding when the remote kill-switch disables promotions.
class GetDataHeaderButton extends StatelessWidget {
  /// Creates a [GetDataHeaderButton].
  const GetDataHeaderButton({
    super.key = const ValueKey('header_get_data_button'),
  });

  @override
  Widget build(BuildContext context) {
    final promoProv = AppProviders.maybeRead<PromoProvider>(context) != null
        ? context.watch<PromoProvider>()
        : null;
    final config = promoProv?.config ?? SaukiPromoConfig.defaults;
    if (!config.enabled) {
      return const SizedBox.shrink();
    }

    final tr = AppTranslations.of(context);

    return Semantics(
      button: true,
      label: tr.getDataHeaderLabel,
      child: CupertinoButton(
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
            color: NelfundColors.emerald.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: NelfundColors.emerald.withValues(alpha: 0.4),
              width: 0.75,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                CupertinoIcons.bolt_fill,
                size: 13,
                color: NelfundColors.emerald,
              ),
              const SizedBox(width: 4),
              Text(
                tr.getDataHeaderLabel,
                style: const TextStyle(
                  color: NelfundColors.emerald,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
