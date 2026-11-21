import 'package:flutter/cupertino.dart';

import '../../../../core/theme/nelfund_colors.dart';
import '../../../../core/theme/nelfund_typography.dart';

/// Shared selectable checklist row used across Core Statutory Criteria, KYC
/// Readiness, and Statutory Disqualification sections.
class EligibilityCheckRow extends StatelessWidget {
  /// Creates an [EligibilityCheckRow].
  const EligibilityCheckRow({
    super.key,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    this.isDestructive = false,
    this.isLast = false,
  });

  /// Primary criterion or disqualifier title.
  final String title;

  /// Supporting statutory detail beneath [title].
  final String subtitle;

  /// Current checked state.
  final bool value;

  /// Invoked when toggled via tap or checkbox interaction.
  final ValueChanged<bool> onChanged;

  /// Styles active state as a statutory disqualification alert when true.
  final bool isDestructive;

  /// Omits the bottom hairline separator when true.
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final activeColor = isDestructive
        ? CupertinoColors.systemRed
        : NelfundColors.emerald;

    return Semantics(
      toggled: value,
      label: title,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => onChanged(!value),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            border: !isLast
                ? const Border(
                    bottom: BorderSide(color: Color(0x14000000), width: 0.5),
                  )
                : null,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: CupertinoCheckbox(
                  value: value,
                  activeColor: activeColor,
                  onChanged: (checked) {
                    if (checked != null) {
                      onChanged(checked);
                    }
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: NelfundTypography.headline.copyWith(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w600,
                        color: (isDestructive && value)
                            ? CupertinoColors.systemRed
                            : null,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: NelfundTypography.footnote.copyWith(
                        fontSize: 12.5,
                        color: CupertinoDynamicColor.resolve(
                          NelfundColors.secondaryLabel,
                          context,
                        ),
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
