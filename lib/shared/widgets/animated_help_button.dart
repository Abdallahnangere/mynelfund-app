import 'package:flutter/cupertino.dart';

import '../../core/theme/nelfund_colors.dart';

/// Pulsing emerald help pill button used inside feature navigation headers to
/// launch step-by-step student guidance modals.
class AnimatedHelpButton extends StatefulWidget {
  /// Creates an [AnimatedHelpButton].
  const AnimatedHelpButton({
    super.key,
    required this.onTap,
    required this.isHausa,
  });

  /// Handler invoked when the pill button is tapped.
  final VoidCallback onTap;

  /// Displays `'Jagora'` in Hausa mode or `'Help Guide'` in English mode.
  final bool isHausa;

  @override
  State<AnimatedHelpButton> createState() => _AnimatedHelpButtonState();
}

class _AnimatedHelpButtonState extends State<AnimatedHelpButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.0,
          end: 1.08,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 25,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.08,
          end: 0.95,
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 25,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 0.95,
          end: 1.05,
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 25,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.05,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeIn)),
        weight: 25,
      ),
    ]).animate(_pulseController);

    _pulseController.forward();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final label = widget.isHausa ? 'Jagora' : 'Help Guide';

    return Semantics(
      button: true,
      label: label,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: CupertinoButton(
          padding: EdgeInsets.zero,
          minimumSize: Size.zero,
          onPressed: () {
            _pulseController.forward(from: 0.0);
            widget.onTap();
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: NelfundColors.emerald.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: NelfundColors.emerald.withValues(alpha: 0.38),
                width: 0.8,
              ),
              boxShadow: [
                BoxShadow(
                  color: NelfundColors.emerald.withValues(alpha: 0.15),
                  blurRadius: 8,
                  spreadRadius: 0.5,
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  CupertinoIcons.question_circle_fill,
                  color: NelfundColors.emerald,
                  size: 14,
                ),
                const SizedBox(width: 4),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: NelfundColors.emerald,
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
