import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/nelfund_colors.dart';
import '../../../../core/theme/nelfund_typography.dart';

/// Bottom CTA button and version caption displayed on [SplashView].
class SplashActionFooter extends StatelessWidget {
  /// Creates a [SplashActionFooter].
  const SplashActionFooter({
    super.key,
    required this.onProceed,
    required this.buttonFade,
    required this.buttonScale,
    required this.footerFade,
  });

  /// Called when the user taps the Proceed CTA button.
  final VoidCallback onProceed;

  /// Fade curve for the primary CTA button.
  final Animation<double> buttonFade;

  /// Scale curve for the primary CTA button.
  final Animation<double> buttonScale;

  /// Fade curve for the version metadata caption.
  final Animation<double> footerFade;

  @override
  Widget build(BuildContext context) {
    final secondaryColor = CupertinoDynamicColor.resolve(
      NelfundColors.secondaryLabel,
      context,
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FadeTransition(
            opacity: buttonFade,
            child: ScaleTransition(
              scale: buttonScale,
              child: Semantics(
                button: true,
                label: 'Proceed to App',
                child: SizedBox(
                  width: double.infinity,
                  child: CupertinoButton(
                    color: NelfundColors.emerald,
                    borderRadius: BorderRadius.circular(16),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    onPressed: () {
                      HapticFeedback.mediumImpact();
                      onProceed();
                    },
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Proceed to App',
                          style: TextStyle(
                            color: CupertinoColors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.2,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(
                          CupertinoIcons.arrow_right_circle_fill,
                          color: CupertinoColors.white,
                          size: 19,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          FadeTransition(
            opacity: footerFade,
            child: Text(
              'Version 1.0.0',
              style: NelfundTypography.captionBold.copyWith(
                fontSize: 11.5,
                color: secondaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
