import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import '../models/promo_model.dart';

/// Official-style dark store badge buttons with crisp vector icons and
/// explicit "For iPhone" (App Store) and "For Android" (Google Play) labels.
class SaukiStoreBadgeRow extends StatelessWidget {
  final ValueChanged<SaukiStorePlatform> onSelectStore;
  final String iPhoneOverline;
  final String androidOverline;
  final bool compact;

  const SaukiStoreBadgeRow({
    super.key,
    required this.onSelectStore,
    required this.iPhoneOverline,
    required this.androidOverline,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: StoreBadgeButton(
            key: ValueKey(
              compact ? 'sauki_home_app_store_badge' : 'sauki_modal_app_store_badge',
            ),
            platform: SaukiStorePlatform.ios,
            overline: iPhoneOverline,
            storeTitle: 'App Store',
            compact: compact,
            onTap: () => onSelectStore(SaukiStorePlatform.ios),
          ),
        ),
        SizedBox(width: compact ? 8 : 10),
        Expanded(
          child: StoreBadgeButton(
            key: ValueKey(
              compact
                  ? 'sauki_home_play_store_badge'
                  : 'sauki_modal_play_store_badge',
            ),
            platform: SaukiStorePlatform.android,
            overline: androidOverline,
            storeTitle: 'Google Play',
            compact: compact,
            onTap: () => onSelectStore(SaukiStorePlatform.android),
          ),
        ),
      ],
    );
  }
}

class StoreBadgeButton extends StatelessWidget {
  final SaukiStorePlatform platform;
  final String overline;
  final String storeTitle;
  final bool compact;
  final VoidCallback onTap;

  const StoreBadgeButton({
    super.key,
    required this.platform,
    required this.overline,
    required this.storeTitle,
    required this.onTap,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = CupertinoTheme.brightnessOf(context) == Brightness.dark;
    final height = compact ? 42.0 : 46.0;
    final iconSize = compact ? 18.0 : 20.0;

    return CupertinoButton(
      padding: EdgeInsets.zero,
      minimumSize: Size.zero,
      pressedOpacity: 0.78,
      onPressed: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: Container(
        height: height,
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: compact ? 10 : 12),
        decoration: BoxDecoration(
          color: const Color(0xFF0C100E),
          borderRadius: BorderRadius.circular(compact ? 11 : 12),
          border: Border.all(
            color: isDark
                ? const Color(0xFF33423A)
                : const Color(0xFF25302A),
            width: 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: CupertinoColors.black.withValues(alpha: isDark ? 0.28 : 0.12),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: iconSize,
                  height: iconSize,
                  child: platform == SaukiStorePlatform.ios
                      ? const CustomPaint(painter: _AppleLogoPainter())
                      : const CustomPaint(painter: _GooglePlayLogoPainter()),
                ),
                const SizedBox(width: 8),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      overline,
                      style: TextStyle(
                        fontSize: compact ? 8.5 : 9.0,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFFB7C4BC),
                        letterSpacing: 0.35,
                        height: 1.05,
                        decoration: TextDecoration.none,
                      ),
                    ),
                    const SizedBox(height: 1.5),
                    Text(
                      storeTitle,
                      style: TextStyle(
                        fontSize: compact ? 13.5 : 14.5,
                        fontWeight: FontWeight.w600,
                        color: CupertinoColors.white,
                        letterSpacing: -0.2,
                        height: 1.05,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Crisp vector Apple silhouette mark for the App Store badge.
class _AppleLogoPainter extends CustomPainter {
  const _AppleLogoPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final paint = Paint()
      ..color = CupertinoColors.white
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    // Top leaf
    final leaf = Path()
      ..moveTo(w * 0.52, h * 0.24)
      ..cubicTo(w * 0.52, h * 0.12, w * 0.63, h * 0.03, w * 0.72, h * 0.02)
      ..cubicTo(w * 0.73, h * 0.14, w * 0.63, h * 0.24, w * 0.52, h * 0.24)
      ..close();
    canvas.drawPath(leaf, paint);

    // Classic Apple body silhouette with right bite
    final body = Path()
      ..moveTo(w * 0.50, h * 0.30)
      ..cubicTo(w * 0.42, h * 0.30, w * 0.35, h * 0.25, w * 0.27, h * 0.26)
      ..cubicTo(w * 0.14, h * 0.27, w * 0.06, h * 0.39, w * 0.07, h * 0.55)
      ..cubicTo(w * 0.08, h * 0.73, w * 0.19, h * 0.94, w * 0.30, h * 0.95)
      ..cubicTo(w * 0.37, h * 0.95, w * 0.41, h * 0.90, w * 0.50, h * 0.90)
      ..cubicTo(w * 0.59, h * 0.90, w * 0.62, h * 0.95, w * 0.70, h * 0.95)
      ..cubicTo(w * 0.80, h * 0.94, w * 0.88, h * 0.81, w * 0.92, h * 0.70)
      ..cubicTo(w * 0.79, h * 0.64, w * 0.78, h * 0.44, w * 0.90, h * 0.37)
      ..cubicTo(w * 0.84, h * 0.29, w * 0.76, h * 0.25, w * 0.68, h * 0.26)
      ..cubicTo(w * 0.60, h * 0.26, w * 0.55, h * 0.30, w * 0.50, h * 0.30)
      ..close();
    canvas.drawPath(body, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Crisp 4-segment multicolor vector Google Play prism mark.
class _GooglePlayLogoPainter extends CustomPainter {
  const _GooglePlayLogoPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final clipTriangle = Path()
      ..moveTo(w * 0.12, h * 0.07)
      ..lineTo(w * 0.92, h * 0.50)
      ..lineTo(w * 0.12, h * 0.93)
      ..close();

    canvas.save();
    canvas.clipPath(clipTriangle);

    final center = Offset(w * 0.54, h * 0.50);

    // Left sky-blue facet
    final bluePaint = Paint()
      ..color = const Color(0xFF00D2FF)
      ..style = PaintingStyle.fill;
    final bluePath = Path()
      ..moveTo(w * 0.08, h * 0.02)
      ..lineTo(center.dx, center.dy)
      ..lineTo(w * 0.08, h * 0.98)
      ..close();
    canvas.drawPath(bluePath, bluePaint);

    // Top emerald-green facet
    final greenPaint = Paint()
      ..color = const Color(0xFF00F076)
      ..style = PaintingStyle.fill;
    final greenPath = Path()
      ..moveTo(w * 0.08, h * 0.02)
      ..lineTo(w * 0.74, h * 0.38)
      ..lineTo(center.dx, center.dy)
      ..close();
    canvas.drawPath(greenPath, greenPaint);

    // Bottom crimson-red facet
    final redPaint = Paint()
      ..color = const Color(0xFFFF3A44)
      ..style = PaintingStyle.fill;
    final redPath = Path()
      ..moveTo(w * 0.08, h * 0.98)
      ..lineTo(center.dx, center.dy)
      ..lineTo(w * 0.74, h * 0.62)
      ..close();
    canvas.drawPath(redPath, redPaint);

    // Right warm-gold nose facet
    final yellowPaint = Paint()
      ..color = const Color(0xFFFFBC00)
      ..style = PaintingStyle.fill;
    final yellowPath = Path()
      ..moveTo(center.dx, center.dy)
      ..lineTo(w * 0.74, h * 0.36)
      ..lineTo(w * 0.98, h * 0.50)
      ..lineTo(w * 0.74, h * 0.64)
      ..close();
    canvas.drawPath(yellowPath, yellowPaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
