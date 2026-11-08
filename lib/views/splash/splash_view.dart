import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import '../../core/theme/nelfund_colors.dart';
import '../../core/theme/nelfund_typography.dart';
import '../../widgets/apple_frosted_card.dart';
import '../main_tab_scaffold.dart';

class SplashView extends StatefulWidget {
  final Duration duration;
  final bool autoNavigate;

  const SplashView({
    super.key,
    this.duration = const Duration(milliseconds: 2400),
    this.autoNavigate = false,
  });

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _logoScaleAnimation;
  late final Animation<double> _logoFadeAnimation;
  late final Animation<double> _rocketAnimation;
  late final Animation<double> _taglineFadeAnimation;
  late final Animation<Offset> _badgeSlideAnimation;
  late final Animation<double> _badgeFadeAnimation;
  late final Animation<double> _titleFadeAnimation;
  late final Animation<double> _buttonFadeAnimation;
  late final Animation<double> _buttonScaleAnimation;
  late final Animation<double> _footerFadeAnimation;

  Timer? _navigationTimer;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    // 1. Dual Crest entrance: Scale from 0.85 -> 1.0 & Fade 0.0 -> 1.0 (0% - 45%)
    _logoScaleAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.45, curve: Curves.easeOutCubic),
      ),
    );
    _logoFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.35, curve: Curves.easeIn),
      ),
    );

    // 2. Rocket Flight Trajectory: Jets from ABU across to NELFUND (20% - 75%)
    _rocketAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.20, 0.75, curve: Curves.easeInOutCubic),
      ),
    );

    // 3. Student Tagline Pill entrance: Fade & gentle float (35% - 65%)
    _taglineFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.35, 0.65, curve: Curves.easeIn),
      ),
    );

    // 3. Republic Badge entrance: Slide up & Fade (45% - 70%)
    _badgeSlideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.4),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.45, 0.70, curve: Curves.easeOutBack),
      ),
    );
    _badgeFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.45, 0.68, curve: Curves.easeIn),
      ),
    );

    // 4. App Title & Subtitle: Fade (55% - 80%)
    _titleFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.55, 0.80, curve: Curves.easeOut),
      ),
    );

    // 5. Continue Button: Fade & gentle scale up (65% - 90%)
    _buttonFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.65, 0.90, curve: Curves.easeIn),
      ),
    );
    _buttonScaleAnimation = Tween<double>(begin: 0.90, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.65, 0.90, curve: Curves.easeOutBack),
      ),
    );

    // 6. Activity Indicator & Footer (75% - 100%)
    _footerFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.75, 1.0, curve: Curves.easeIn),
      ),
    );

    _controller.forward();

    if (widget.autoNavigate) {
      _navigationTimer = Timer(widget.duration, _navigateToHome);
    }
  }

  void _navigateToHome() {
    if (!mounted) return;
    _navigationTimer?.cancel();
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 550),
        pageBuilder: (context, animation, secondaryAnimation) =>
            const MainTabScaffold(showStartupPromo: true),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark =
        CupertinoTheme.of(context).brightness == Brightness.dark;

    return CupertinoPageScaffold(
      backgroundColor: CupertinoDynamicColor.resolve(
        const CupertinoDynamicColor.withBrightness(
          color: Color(0xFFFAFCFA),
          darkColor: Color(0xFF0F1411),
        ),
        context,
      ),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _navigateToHome,
        child: Stack(
          children: [
            // Ambient green glow background
            Positioned(
              top: -100,
              right: -100,
              child: Container(
                width: 320,
                height: 320,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: NelfundColors.emerald.withValues(
                    alpha: isDark ? 0.12 : 0.07,
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: -80,
              left: -80,
              child: Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: NelfundColors.emerald.withValues(
                    alpha: isDark ? 0.09 : 0.05,
                  ),
                ),
              ),
            ),

            // Centered Main Content
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(flex: 3),

                    // Staggered Stage 1: Dual Crest Station (ABU & NELFUND) with Rocket Bridge
                    ScaleTransition(
                      scale: _logoScaleAnimation,
                      child: FadeTransition(
                        opacity: _logoFadeAnimation,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Left Crest: ABU Ahmadu Bello University
                            AppleFrostedCard(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                              margin: EdgeInsets.zero,
                              borderRadius: 22,
                              borderColor: NelfundColors.emerald.withValues(alpha: 0.32),
                              backgroundColor: CupertinoDynamicColor.resolve(
                                const CupertinoDynamicColor.withBrightness(
                                  color: Color(0xF2FFFFFF),
                                  darkColor: Color(0xF018241C),
                                ),
                                context,
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Image.asset(
                                    'assets/images/abu_logo.png',
                                    width: 62,
                                    height: 62,
                                    fit: BoxFit.contain,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'ABU Zaria',
                                    style: NelfundTypography.captionBold.copyWith(
                                      fontSize: 10.5,
                                      color: NelfundColors.emerald,
                                      letterSpacing: 0.4,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Dynamic Flight Corridor: Animated Rocket Jetting from ABU to NELFUND
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 6),
                              child: _RocketFlightBridge(
                                animation: _rocketAnimation,
                                isDark: isDark,
                              ),
                            ),

                            // Right Crest: NELFUND Federal Education Loan Fund
                            AppleFrostedCard(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                              margin: EdgeInsets.zero,
                              borderRadius: 22,
                              borderColor: NelfundColors.emerald.withValues(alpha: 0.32),
                              backgroundColor: CupertinoDynamicColor.resolve(
                                const CupertinoDynamicColor.withBrightness(
                                  color: Color(0xF2FFFFFF),
                                  darkColor: Color(0xF018241C),
                                ),
                                context,
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Image.asset(
                                    'assets/images/nelfund_logo.png',
                                    width: 62,
                                    height: 62,
                                    fit: BoxFit.contain,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'NELFUND',
                                    style: NelfundTypography.captionBold.copyWith(
                                      fontSize: 10.5,
                                      color: NelfundColors.emerald,
                                      letterSpacing: 0.4,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Inspiring Student Innovation Tagline
                    FadeTransition(
                      opacity: _taglineFadeAnimation,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: NelfundColors.emerald.withValues(
                            alpha: isDark ? 0.16 : 0.08,
                          ),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: NelfundColors.emerald.withValues(
                              alpha: isDark ? 0.35 : 0.22,
                            ),
                            width: 0.8,
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  CupertinoIcons.sparkles,
                                  size: 13,
                                  color: NelfundColors.emerald,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'For Students, By a Student',
                                  style: NelfundTypography.captionBold.copyWith(
                                    color: NelfundColors.emerald,
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'From ABU to the World 🌍',
                              style: NelfundTypography.footnote.copyWith(
                                color: CupertinoDynamicColor.resolve(
                                  NelfundColors.secondaryLabel,
                                  context,
                                ),
                                fontSize: 11.5,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Staggered Stage 2: Federal Republic of Nigeria Pill Badge
                    SlideTransition(
                      position: _badgeSlideAnimation,
                      child: FadeTransition(
                        opacity: _badgeFadeAnimation,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: NelfundColors.emerald.withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: NelfundColors.emerald.withValues(alpha: 0.28),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: NelfundColors.emerald,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Federal Republic of Nigeria',
                                style: NelfundTypography.captionBold.copyWith(
                                  color: NelfundColors.emerald,
                                  letterSpacing: 0.6,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 14),

                    // Staggered Stage 3: Title & Subtitle & Act 2024 Citation
                    FadeTransition(
                      opacity: _titleFadeAnimation,
                      child: Column(
                        children: [
                          Text(
                            'My NELFund',
                            style: NelfundTypography.title1.copyWith(
                              fontSize: 32,
                              fontWeight: FontWeight.w600,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Nigerian Education Loan Fund',
                            textAlign: TextAlign.center,
                            style: NelfundTypography.headline.copyWith(
                              color: CupertinoDynamicColor.resolve(
                                NelfundColors.secondaryLabel,
                                context,
                              ),
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              'Students Loans (Access to Higher Education) Act 2024',
                              textAlign: TextAlign.center,
                              style: NelfundTypography.footnote.copyWith(
                                color: CupertinoDynamicColor.resolve(
                                  NelfundColors.secondaryLabel,
                                  context,
                                ).withValues(alpha: 0.8),
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 26),

                    // Stage 4: Manual "Continue" Action Button
                    FadeTransition(
                      opacity: _buttonFadeAnimation,
                      child: ScaleTransition(
                        scale: _buttonScaleAnimation,
                        child: CupertinoButton(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 28,
                            vertical: 13,
                          ),
                          color: NelfundColors.emerald,
                          borderRadius: BorderRadius.circular(22),
                          onPressed: () {
                            HapticFeedback.lightImpact();
                            _navigateToHome();
                          },
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Proceed to App',
                                style: NelfundTypography.headline.copyWith(
                                  color: CupertinoColors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(
                                CupertinoIcons.arrow_right,
                                color: CupertinoColors.white,
                                size: 18,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const Spacer(flex: 2),

                    // Staggered Stage 5: Version Status (no spinner)
                    FadeTransition(
                      opacity: _footerFadeAnimation,
                      child: Text(
                        'Version 1.0.0',
                        style: NelfundTypography.caption.copyWith(
                          color: CupertinoDynamicColor.resolve(
                            NelfundColors.secondaryLabel,
                            context,
                          ),
                          fontSize: 12,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RocketFlightBridge extends StatelessWidget {
  final Animation<double> animation;
  final bool isDark;

  const _RocketFlightBridge({
    required this.animation,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    const double width = 80;
    const double height = 52;
    const double arcHeight = 15;

    return SizedBox(
      width: width,
      height: height,
      child: AnimatedBuilder(
        animation: animation,
        builder: (context, child) {
          final progress = animation.value;
          final x = progress * (width - 24);
          final y = -math.sin(progress * math.pi) * arcHeight;
          final dx = width - 24;
          final dy = -math.pi * arcHeight * math.cos(progress * math.pi);
          // Angle of motion for the rocket
          final angle = math.atan2(dy, dx);

          return Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              CustomPaint(
                size: const Size(width, height),
                painter: _RocketTrajectoryPainter(
                  progress: progress,
                  arcHeight: arcHeight,
                  isDark: isDark,
                ),
              ),
              Positioned(
                left: x,
                top: (height / 2 - 12) + y,
                child: Transform.rotate(
                  angle: angle,
                  child: const Text(
                    '🚀',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _RocketTrajectoryPainter extends CustomPainter {
  final double progress;
  final double arcHeight;
  final bool isDark;

  _RocketTrajectoryPainter({
    required this.progress,
    required this.arcHeight,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;
    final startX = 2.0;
    final endX = width - 12.0;
    final midY = height / 2 + 4.0;

    // 1. Draw subtle dashed guide trajectory arc
    final guidePaint = Paint()
      ..color = NelfundColors.emerald.withValues(alpha: isDark ? 0.28 : 0.20)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    final path = Path();
    path.moveTo(startX, midY);
    path.quadraticBezierTo(
      (startX + endX) / 2,
      midY - arcHeight * 2.2,
      endX,
      midY,
    );

    final pathMetrics = path.computeMetrics().toList();
    if (pathMetrics.isEmpty) return;

    final metric = pathMetrics.first;
    double distance = 0.0;
    const dashLength = 4.0;
    const dashSpace = 3.5;

    while (distance < metric.length) {
      final extractLength = math.min(dashLength, metric.length - distance);
      final segment = metric.extractPath(distance, distance + extractLength);
      canvas.drawPath(segment, guidePaint);
      distance += dashLength + dashSpace;
    }

    // 2. Draw glowing jet thrust exhaust trail behind the rocket
    if (progress > 0.04) {
      final trailPaint = Paint()
        ..shader = LinearGradient(
          colors: [
            CupertinoColors.systemOrange.withValues(alpha: 0.0),
            CupertinoColors.systemYellow.withValues(alpha: 0.5),
            NelfundColors.emerald,
          ],
          stops: const [0.0, 0.4, 1.0],
        ).createShader(Rect.fromLTWH(0, 0, width, height))
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = 2.4;

      final currentLength = metric.length * progress;
      final trailStart = math.max(0.0, currentLength - 26.0);

      if (currentLength > trailStart) {
        final trailSegment = metric.extractPath(trailStart, currentLength);
        canvas.drawPath(trailSegment, trailPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _RocketTrajectoryPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.isDark != isDark ||
        oldDelegate.arcHeight != arcHeight;
  }
}
