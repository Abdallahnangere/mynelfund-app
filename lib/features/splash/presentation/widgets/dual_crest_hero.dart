import 'package:flutter/cupertino.dart';

import '../../../../core/theme/nelfund_colors.dart';
import '../../../../core/theme/nelfund_typography.dart';
import '../../../../shared/widgets/apple_frosted_card.dart';
import 'rocket_trajectory_painter.dart';

/// Displays the dual-crest splash bridge connecting ABU Zaria and NELFUND
/// along a finite parabolic rocket trajectory with Nigerian student identity
/// badges and statutory Act citation.
class DualCrestHero extends StatelessWidget {
  /// Creates a [DualCrestHero].
  const DualCrestHero({super.key, required this.rocketAnimation});

  /// Finite curved progress animation (`0.0` to `1.0`) driving the rocket flight.
  final Animation<double> rocketAnimation;

  @override
  Widget build(BuildContext context) {
    final secondaryColor = CupertinoDynamicColor.resolve(
      NelfundColors.secondaryLabel,
      context,
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const _PillBadge(
          text: 'For Students, By a Student',
          color: NelfundColors.emerald,
        ),
        const SizedBox(height: 16),
        AppleFrostedCard(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding: const EdgeInsets.fromLTRB(18, 22, 18, 20),
          borderColor: NelfundColors.emerald.withValues(alpha: 0.28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const _CrestEmblem(
                    assetPath: 'assets/images/abu_logo.png',
                    label: 'ABU Zaria',
                  ),
                  Flexible(
                    child: SizedBox(
                      width: 112,
                      height: 64,
                      child: AnimatedBuilder(
                        animation: rocketAnimation,
                        builder: (context, child) {
                          final t = Curves.easeInOutCubic.transform(
                            rocketAnimation.value.clamp(0.0, 1.0),
                          );
                          final pos = RocketTrajectoryPainter.pointAt(
                            const Size(112, 64),
                            t,
                          );
                          return Stack(
                            clipBehavior: Clip.none,
                            children: [
                              RepaintBoundary(
                                child: CustomPaint(
                                  size: const Size(112, 64),
                                  painter: RocketTrajectoryPainter(progress: t),
                                ),
                              ),
                              Positioned(
                                left: pos.dx - 11,
                                top: pos.dy - 12,
                                child: Transform.rotate(
                                  angle: (t - 0.5) * 0.65,
                                  child: child,
                                ),
                              ),
                            ],
                          );
                        },
                        child: const Text('🚀', style: TextStyle(fontSize: 19)),
                      ),
                    ),
                  ),
                  const _CrestEmblem(
                    assetPath: 'assets/images/nelfund_logo.png',
                    label: 'NELFUND',
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Federal Republic of Nigeria',
                textAlign: TextAlign.center,
                style: NelfundTypography.captionBold.copyWith(
                  color: NelfundColors.emerald,
                  fontSize: 11.5,
                  letterSpacing: 0.4,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'My NELFund',
                textAlign: TextAlign.center,
                style: NelfundTypography.headline.copyWith(
                  fontSize: 25,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Nigerian Education Loan Fund',
                textAlign: TextAlign.center,
                style: NelfundTypography.subhead.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: secondaryColor,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Students Loans (Access to Higher Education) Act 2024',
                textAlign: TextAlign.center,
                style: NelfundTypography.footnote.copyWith(
                  fontSize: 12,
                  color: secondaryColor,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 12),
              const _PillBadge(
                text: 'From ABU to the World 🌍',
                color: CupertinoColors.systemTeal,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CrestEmblem extends StatelessWidget {
  const _CrestEmblem({required this.assetPath, required this.label});

  final String assetPath;
  final String label;

  @override
  Widget build(BuildContext context) {
    final isDark = CupertinoTheme.of(context).brightness == Brightness.dark;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 68,
          height: 68,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isDark ? const Color(0xFF262B28) : CupertinoColors.white,
            border: Border.all(
              color: NelfundColors.emerald.withValues(alpha: 0.35),
              width: 1.0,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x14000000),
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: ClipOval(
            child: Image.asset(
              assetPath,
              fit: BoxFit.contain,
              errorBuilder: (_, _, _) => const Icon(
                CupertinoIcons.building_2_fill,
                color: NelfundColors.emerald,
                size: 28,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: NelfundTypography.captionBold.copyWith(
            fontSize: 12,
            letterSpacing: -0.1,
          ),
        ),
      ],
    );
  }
}

class _PillBadge extends StatelessWidget {
  const _PillBadge({required this.text, required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.35), width: 0.75),
      ),
      child: Text(
        text,
        style: NelfundTypography.captionBold.copyWith(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
