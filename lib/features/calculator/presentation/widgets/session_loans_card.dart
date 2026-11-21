import 'package:flutter/cupertino.dart';

import '../../../../core/localization/app_translations.dart';
import '../../../../core/theme/nelfund_colors.dart';
import '../../../../core/theme/nelfund_typography.dart';
import '../../../../shared/widgets/apple_frosted_card.dart';
import '../../domain/repayment_model.dart';

/// Displays configured academic session loans with tap-to-edit and removal
/// actions, or a helpful empty prompt when none are added yet.
class SessionLoansCard extends StatelessWidget {
  /// Creates a [SessionLoansCard].
  const SessionLoansCard({
    super.key,
    required this.sessions,
    required this.tr,
    required this.onEditSession,
    required this.onRemoveSession,
  });

  /// Configured academic session loan records.
  final List<AcademicSessionLoan> sessions;

  /// Active translation bundle.
  final AppTranslations tr;

  /// Invoked when tapping a session card to edit it.
  final ValueChanged<AcademicSessionLoan> onEditSession;

  /// Invoked when removing a session by academic level (`100..600`).
  final ValueChanged<int> onRemoveSession;

  @override
  Widget build(BuildContext context) {
    if (sessions.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: AppleFrostedCard(
          margin: EdgeInsets.zero,
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              const Icon(
                CupertinoIcons.info,
                color: CupertinoColors.systemOrange,
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  tr.noSessionsAdded,
                  style: NelfundTypography.footnote.copyWith(
                    color: CupertinoDynamicColor.resolve(
                      NelfundColors.secondaryLabel,
                      context,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${tr.configuredSessionsTitle} (${sessions.length})',
                style: NelfundTypography.captionBold.copyWith(
                  color: CupertinoDynamicColor.resolve(
                    NelfundColors.secondaryLabel,
                    context,
                  ),
                  fontSize: 12.5,
                ),
              ),
              Text(
                tr.tapToEdit,
                style: NelfundTypography.caption.copyWith(
                  color: CupertinoDynamicColor.resolve(
                    NelfundColors.tertiaryLabel,
                    context,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...sessions.map(
            (session) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => onEditSession(session),
                child: AppleFrostedCard(
                  margin: EdgeInsets.zero,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: NelfundColors.emerald.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          session.getLevelLabel(tr.language),
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: NelfundColors.emerald,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              session.formattedTotal,
                              style: NelfundTypography.headline.copyWith(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${tr.isHausa ? 'Kudin Makaranta' : 'Tuition'}: ${session.formattedTuition}'
                              '${session.includeUpkeep && session.upkeepAmount > 0 ? (tr.isHausa ? ' + Alawus (${session.upkeepMonthsCount} watanni): ${session.formattedUpkeep}' : ' + Upkeep (${session.upkeepMonthsCount} mos): ${session.formattedUpkeep}') : (tr.isHausa ? ' (Babu Alawus)' : ' (No Upkeep)')}',
                              style: NelfundTypography.caption.copyWith(
                                color: CupertinoDynamicColor.resolve(
                                  NelfundColors.secondaryLabel,
                                  context,
                                ),
                                fontSize: 11.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        onPressed: () => onRemoveSession(session.level),
                        child: const Icon(
                          CupertinoIcons.xmark_circle_fill,
                          color: CupertinoColors.systemGrey3,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
