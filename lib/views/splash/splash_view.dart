import 'dart:async';
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
      duration: const Duration(milliseconds: 1800),
    );

    // 1. Emblem entrance: Scale from 0.85 -> 1.0 & Fade 0.0 -> 1.0 (0% - 55%)
    _logoScaleAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.55, curve: Curves.easeOutCubic),
      ),
    );
    _logoFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.45, curve: Curves.easeIn),
      ),
    );

    // 2. Republic Badge entrance: Slide up & Fade (25% - 65%)
    _badgeSlideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.4),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.25, 0.65, curve: Curves.easeOutBack),
      ),
    );
    _badgeFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.25, 0.60, curve: Curves.easeIn),
      ),
    );

    // 3. App Title & Subtitle: Fade (45% - 80%)
    _titleFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.45, 0.80, curve: Curves.easeOut),
      ),
    );

    // 4. Continue Button: Fade & gentle scale up (55% - 90%)
    _buttonFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.55, 0.90, curve: Curves.easeIn),
      ),
    );
    _buttonScaleAnimation = Tween<double>(begin: 0.90, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.55, 0.90, curve: Curves.easeOutBack),
      ),
    );

    // 5. Activity Indicator & Footer (70% - 100%)
    _footerFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.70, 1.0, curve: Curves.easeIn),
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
            const MainTabScaffold(),
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

                    // Staggered Stage 1: Official Emblem with Frosted Frame
                    ScaleTransition(
                      scale: _logoScaleAnimation,
                      child: FadeTransition(
                        opacity: _logoFadeAnimation,
                        child: AppleFrostedCard(
                          padding: const EdgeInsets.all(22),
                          margin: EdgeInsets.zero,
                          borderRadius: 28,
                          borderColor: NelfundColors.emerald.withValues(alpha: 0.3),
                          backgroundColor: CupertinoDynamicColor.resolve(
                            const CupertinoDynamicColor.withBrightness(
                              color: Color(0xF2FFFFFF),
                              darkColor: Color(0xF018241C),
                            ),
                            context,
                          ),
                          child: Image.asset(
                            'assets/images/nelfund_logo.png',
                            width: 108,
                            height: 108,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

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
                              fontWeight: FontWeight.w800,
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
                              fontWeight: FontWeight.w500,
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
