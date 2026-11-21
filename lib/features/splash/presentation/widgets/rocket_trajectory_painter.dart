import 'dart:ui' show PathMetric;

import 'package:flutter/cupertino.dart';

import '../../../../core/theme/nelfund_colors.dart';

/// Paints a smooth dashed parabolic arc between the ABU Zaria crest and the
/// NELFUND crest, revealing a luminous trail behind the traveling rocket.
class RocketTrajectoryPainter extends CustomPainter {
  /// Creates a [RocketTrajectoryPainter] driven by normalized [progress]
  /// (`0.0` to `1.0`).
  const RocketTrajectoryPainter({required this.progress});

  /// Current animation progress along the quadratic Bezier trajectory.
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final start = Offset(14, size.height * 0.72);
    final control = Offset(size.width * 0.50, -size.height * 0.25);
    final end = Offset(size.width - 14, size.height * 0.72);

    final fullPath = Path()
      ..moveTo(start.dx, start.dy)
      ..quadraticBezierTo(control.dx, control.dy, end.dx, end.dy);

    final guidePaint = Paint()
      ..color = NelfundColors.emerald.withValues(alpha: 0.22)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round;

    _drawDashedPath(canvas, fullPath, guidePaint, dashWidth: 5, dashGap: 5);

    final clampedProgress = progress.clamp(0.0, 1.0);
    if (clampedProgress <= 0) {
      return;
    }

    for (final PathMetric metric in fullPath.computeMetrics()) {
      final activePath = metric.extractPath(0, metric.length * clampedProgress);
      final glowPaint = Paint()
        ..color = NelfundColors.emerald.withValues(alpha: 0.24)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5.0
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

      final trailPaint = Paint()
        ..color = NelfundColors.emerald
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.2
        ..strokeCap = StrokeCap.round;

      canvas.drawPath(activePath, glowPaint);
      canvas.drawPath(activePath, trailPaint);
    }
  }

  void _drawDashedPath(
    Canvas canvas,
    Path path,
    Paint paint, {
    required double dashWidth,
    required double dashGap,
  }) {
    for (final PathMetric metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final next = (distance + dashWidth).clamp(0.0, metric.length);
        canvas.drawPath(metric.extractPath(distance, next), paint);
        distance += dashWidth + dashGap;
      }
    }
  }

  /// Evaluates the screen-space point along the arc at [t] (`0.0` to `1.0`).
  static Offset pointAt(Size size, double t) {
    final start = Offset(14, size.height * 0.72);
    final control = Offset(size.width * 0.50, -size.height * 0.25);
    final end = Offset(size.width - 14, size.height * 0.72);

    final u = 1.0 - t;
    final dx = u * u * start.dx + 2 * u * t * control.dx + t * t * end.dx;
    final dy = u * u * start.dy + 2 * u * t * control.dy + t * t * end.dy;
    return Offset(dx, dy);
  }

  @override
  bool shouldRepaint(covariant RocketTrajectoryPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
