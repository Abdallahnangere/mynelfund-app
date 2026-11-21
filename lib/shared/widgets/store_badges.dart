import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

/// Side-by-side App Store and Google Play download badge pair for the Sauki Go
/// companion utility app.
class SaukiStoreBadgeRow extends StatelessWidget {
  /// Creates a [SaukiStoreBadgeRow].
  const SaukiStoreBadgeRow({
    super.key,
    required this.onAppStoreTap,
    required this.onPlayStoreTap,
    this.appStoreKey,
    this.playStoreKey,
    this.iphoneOverline = 'FOR IPHONE',
    this.androidOverline = 'FOR ANDROID',
    this.compact = false,
  });

  /// Handler invoked when the Apple App Store badge is tapped.
  final VoidCallback onAppStoreTap;

  /// Handler invoked when the Google Play Store badge is tapped.
  final VoidCallback onPlayStoreTap;

  /// Optional test key assigned to the App Store badge.
  final Key? appStoreKey;

  /// Optional test key assigned to the Google Play badge.
  final Key? playStoreKey;

  /// Localized overline caption displayed above `'App Store'`.
  final String iphoneOverline;

  /// Localized overline caption displayed above `'Google Play'`.
  final String androidOverline;

  /// Reduces vertical padding for denser inline layouts when true.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: AppStoreBadge(
            key: appStoreKey,
            compact: compact,
            overline: iphoneOverline,
            onTap: onAppStoreTap,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: GooglePlayBadge(
            key: playStoreKey,
            compact: compact,
            overline: androidOverline,
            onTap: onPlayStoreTap,
          ),
        ),
      ],
    );
  }
}

/// Official-style dark pill badge linking to the iOS App Store listing.
class AppStoreBadge extends StatefulWidget {
  /// Creates an [AppStoreBadge].
  const AppStoreBadge({
    super.key,
    required this.onTap,
    this.overline = 'FOR IPHONE',
    this.compact = false,
  });

  /// Invoked when the badge is pressed.
  final VoidCallback onTap;

  /// Uppercase overline displayed above `'App Store'`.
  final String overline;

  /// Uses tighter vertical padding when true.
  final bool compact;

  @override
  State<AppStoreBadge> createState() => _AppStoreBadgeState();
}

class _AppStoreBadgeState extends State<AppStoreBadge> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Download on the App Store',
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        onTap: () {
          HapticFeedback.lightImpact();
          widget.onTap();
        },
        child: AnimatedScale(
          scale: _pressed ? 0.97 : 1.0,
          duration: const Duration(milliseconds: 110),
          curve: Curves.easeOut,
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: 10,
              vertical: widget.compact ? 8 : 10,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFF0C0F14),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0x33FFFFFF), width: 0.75),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x26000000),
                  blurRadius: 8,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const RepaintBoundary(
                  child: CustomPaint(
                    size: Size(18, 22),
                    painter: _AppleLogoPainter(),
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.overline,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xB8FFFFFF),
                          fontSize: 8.0,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                          height: 1.05,
                        ),
                      ),
                      const SizedBox(height: 1),
                      const Text(
                        'App Store',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: CupertinoColors.white,
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.2,
                          height: 1.1,
                        ),
                      ),
                    ],
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

/// Official-style dark pill badge linking to the Google Play Store listing.
class GooglePlayBadge extends StatefulWidget {
  /// Creates a [GooglePlayBadge].
  const GooglePlayBadge({
    super.key,
    required this.onTap,
    this.overline = 'FOR ANDROID',
    this.compact = false,
  });

  /// Invoked when the badge is pressed.
  final VoidCallback onTap;

  /// Uppercase overline displayed above `'Google Play'`.
  final String overline;

  /// Uses tighter vertical padding when true.
  final bool compact;

  @override
  State<GooglePlayBadge> createState() => _GooglePlayBadgeState();
}

class _GooglePlayBadgeState extends State<GooglePlayBadge> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Get it on Google Play',
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        onTap: () {
          HapticFeedback.lightImpact();
          widget.onTap();
        },
        child: AnimatedScale(
          scale: _pressed ? 0.97 : 1.0,
          duration: const Duration(milliseconds: 110),
          curve: Curves.easeOut,
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: 10,
              vertical: widget.compact ? 8 : 10,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFF0F1915),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0x33FFFFFF), width: 0.75),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x26000000),
                  blurRadius: 8,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const RepaintBoundary(
                  child: CustomPaint(
                    size: Size(18, 20),
                    painter: _PlayTrianglePainter(),
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.overline,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xB8FFFFFF),
                          fontSize: 8.0,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                          height: 1.05,
                        ),
                      ),
                      const SizedBox(height: 1),
                      const Text(
                        'Google Play',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: CupertinoColors.white,
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.2,
                          height: 1.1,
                        ),
                      ),
                    ],
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

class _AppleLogoPainter extends CustomPainter {
  const _AppleLogoPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = CupertinoColors.white
      ..style = PaintingStyle.fill;

    final w = size.width;
    final h = size.height;

    final leaf = Path()
      ..moveTo(w * 0.56, h * 0.04)
      ..quadraticBezierTo(w * 0.66, h * 0.16, w * 0.50, h * 0.27)
      ..quadraticBezierTo(w * 0.42, h * 0.15, w * 0.56, h * 0.04)
      ..close();
    canvas.drawPath(leaf, paint);

    final body = Path()
      ..moveTo(w * 0.50, h * 0.30)
      ..cubicTo(w * 0.72, h * 0.25, w * 0.90, h * 0.36, w * 0.88, h * 0.44)
      ..cubicTo(w * 0.75, h * 0.50, w * 0.74, h * 0.68, w * 0.89, h * 0.74)
      ..cubicTo(w * 0.82, h * 0.93, w * 0.66, h * 0.99, w * 0.52, h * 0.94)
      ..quadraticBezierTo(w * 0.46, h * 0.91, w * 0.39, h * 0.95)
      ..cubicTo(w * 0.24, h * 1.00, w * 0.08, h * 0.84, w * 0.08, h * 0.56)
      ..cubicTo(w * 0.08, h * 0.31, w * 0.31, h * 0.24, w * 0.50, h * 0.30)
      ..close();
    canvas.drawPath(body, paint);
  }

  @override
  bool shouldRepaint(covariant _AppleLogoPainter oldDelegate) => false;
}

class _PlayTrianglePainter extends CustomPainter {
  const _PlayTrianglePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final center = Offset(w * 0.60, h * 0.50);

    canvas.drawPath(
      Path()
        ..moveTo(0, 0)
        ..lineTo(center.dx, center.dy)
        ..lineTo(0, h)
        ..close(),
      Paint()..color = const Color(0xFF00C4FF),
    );
    canvas.drawPath(
      Path()
        ..moveTo(0, 0)
        ..lineTo(w * 0.76, h * 0.36)
        ..lineTo(center.dx, center.dy)
        ..close(),
      Paint()..color = const Color(0xFF00E676),
    );
    canvas.drawPath(
      Path()
        ..moveTo(center.dx, center.dy)
        ..lineTo(w * 0.76, h * 0.36)
        ..lineTo(w, h * 0.50)
        ..lineTo(w * 0.76, h * 0.64)
        ..close(),
      Paint()..color = const Color(0xFFFFD54F),
    );
    canvas.drawPath(
      Path()
        ..moveTo(0, h)
        ..lineTo(center.dx, center.dy)
        ..lineTo(w * 0.76, h * 0.64)
        ..close(),
      Paint()..color = const Color(0xFFFF5252),
    );
  }

  @override
  bool shouldRepaint(covariant _PlayTrianglePainter oldDelegate) => false;
}
