import 'dart:async';

import 'package:flutter/cupertino.dart';

import '../../../../app/app_shell.dart';
import '../../../../core/theme/nelfund_colors.dart';
import '../widgets/dual_crest_hero.dart';
import '../widgets/splash_action_footer.dart';

/// Animated entry splash view presenting the ABU Zaria and NELFUND dual-crest
/// bridge before transitioning smoothly into [MainTabScaffold].
class SplashView extends StatefulWidget {
  /// Creates a [SplashView].
  const SplashView({
    super.key,
    this.autoNavigate = false,
    this.duration = const Duration(seconds: 4),
    this.showStartupPromo = true,
  });

  /// Whether to transition automatically after [duration].
  final bool autoNavigate;

  /// Delay used when [autoNavigate] is true.
  final Duration duration;

  /// Forwarded to [MainTabScaffold] when advancing into the app.
  final bool showStartupPromo;

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _rocketAnimation;
  late final Animation<double> _buttonFadeAnimation;
  late final Animation<double> _buttonScaleAnimation;
  late final Animation<double> _footerFadeAnimation;
  Timer? _navigationTimer;
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );

    _rocketAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.05, 0.75, curve: Curves.easeInOutCubic),
    );
    _buttonFadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.45, 0.85, curve: Curves.easeOut),
    );
    _buttonScaleAnimation = Tween<double>(begin: 0.92, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.45, 0.85, curve: Curves.easeOutBack),
      ),
    );
    _footerFadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.60, 1.0, curve: Curves.easeIn),
    );

    _controller.forward();

    if (widget.autoNavigate) {
      _navigationTimer = Timer(widget.duration, _navigateToHome);
    }
  }

  void _navigateToHome() {
    if (!mounted || _hasNavigated) {
      return;
    }
    _hasNavigated = true;
    _navigationTimer?.cancel();

    Navigator.of(context).pushReplacement(
      PageRouteBuilder<void>(
        transitionDuration: const Duration(milliseconds: 550),
        pageBuilder: (context, animation, secondaryAnimation) =>
            MainTabScaffold(showStartupPromo: widget.showStartupPromo),
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
    final isDark = CupertinoTheme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _navigateToHome,
      child: CupertinoPageScaffold(
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: isDark
                  ? const [
                      Color(0xFF0A140F),
                      Color(0xFF0A0D0B),
                      Color(0xFF09100C),
                    ]
                  : [
                      NelfundColors.emerald.withValues(alpha: 0.08),
                      const Color(0xFFF6FAF7),
                      const Color(0xFFFFFFFF),
                    ],
            ),
          ),
          child: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const SizedBox(height: 24),
                        DualCrestHero(rocketAnimation: _rocketAnimation),
                        const SizedBox(height: 28),
                        SplashActionFooter(
                          onProceed: _navigateToHome,
                          buttonFade: _buttonFadeAnimation,
                          buttonScale: _buttonScaleAnimation,
                          footerFade: _footerFadeAnimation,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
