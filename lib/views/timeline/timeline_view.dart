import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/theme/nelfund_colors.dart';
import '../../core/theme/nelfund_typography.dart';
import '../../models/timeline_model.dart';
import '../../providers/timeline_provider.dart';
import '../../widgets/apple_frosted_card.dart';

class TimelineView extends StatelessWidget {
  const TimelineView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TimelineProvider(),
      child: const _TimelineContent(),
    );
  }
}

class _TimelineContent extends StatelessWidget {
  const _TimelineContent();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TimelineProvider>();
    final eval = provider.evaluation;

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Timeline & SLA Tracker'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: provider.reset,
          child: const Text('Reset'),
        ),
        backgroundColor: CupertinoDynamicColor.resolve(
          const CupertinoDynamicColor.withBrightness(
            color: Color(0xCCF8FAF8),
            darkColor: Color(0xCC161718),
          ),
          context,
        ),
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 14),
          children: [
            _buildIntroHeader(context),
            const SizedBox(height: 12),
            _buildSectionHeader('Interactive On-Track Evaluator'),
            _buildEvaluatorInputCard(context, provider),
            const SizedBox(height: 12),
            _buildHealthResultCard(context, eval),
            const SizedBox(height: 20),
            _buildSectionHeader('Official Statutory Turnaround Journey (Section 4.2)'),
            ...SlaStageInfo.allStages.map((info) => _buildJourneyStageCard(context, info)),
            const SizedBox(height: 16),
            _buildSectionHeader('Official Grievance & Escalation Directory'),
            _buildGrievanceCard(context),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildIntroHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Official Service Level Agreements (SLAs)',
            style: NelfundTypography.title2.copyWith(
              color: NelfundColors.emeraldTint,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Section 4.2 of the Guidelines mandates strict processing deadlines across 5 stages (~47 working days maximum cycle). Test whether your application is on track below.',
            style: NelfundTypography.body.copyWith(
              color: CupertinoDynamicColor.resolve(
                  NelfundColors.secondaryLabel, context),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: Text(
        title,
        style: NelfundTypography.title3.copyWith(
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildEvaluatorInputCard(
      BuildContext context, TimelineProvider provider) {
    final dateFormat = DateFormat('MMM d, yyyy');
    final formattedDate = dateFormat.format(provider.submissionDate);

    return AppleFrostedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Submission Date:',
                style: NelfundTypography.headline.copyWith(fontSize: 14),
              ),
              CupertinoButton(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                onPressed: () => _showDatePickerModal(context, provider),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: NelfundColors.emerald.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(CupertinoIcons.calendar,
                          size: 14, color: NelfundColors.emerald),
                      const SizedBox(width: 6),
                      Text(
                        formattedDate,
                        style: NelfundTypography.captionBold.copyWith(
                          color: NelfundColors.emerald,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildDatePresetChip(
                '3 Days Ago',
                () => provider.setSubmissionDate(
                    DateTime.now().subtract(const Duration(days: 3))),
              ),
              _buildDatePresetChip(
                '10 Days Ago',
                () => provider.setSubmissionDate(
                    DateTime.now().subtract(const Duration(days: 10))),
              ),
              _buildDatePresetChip(
                '25 Days Ago',
                () => provider.setSubmissionDate(
                    DateTime.now().subtract(const Duration(days: 25))),
              ),
              _buildDatePresetChip(
                '40 Days Ago',
                () => provider.setSubmissionDate(
                    DateTime.now().subtract(const Duration(days: 40))),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            'Current Application Stage:',
            style: NelfundTypography.headline.copyWith(fontSize: 14),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: SlaStage.values.map((stage) {
                final isSelected = provider.currentStage == stage;
                final stageInfo = SlaStageInfo.getFor(stage);

                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: CupertinoButton(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    onPressed: () => provider.setCurrentStage(stage),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? NelfundColors.emerald
                            : const Color(0x0F000000),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Stage ${stageInfo.stageNumber}: ${stageInfo.durationLabel}',
                        style: NelfundTypography.captionBold.copyWith(
                          fontSize: 11,
                          color: isSelected
                              ? CupertinoColors.white
                              : CupertinoDynamicColor.resolve(
                                  NelfundColors.label, context),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  void _showDatePickerModal(BuildContext context, TimelineProvider provider) {
    showCupertinoModalPopup(
      context: context,
      builder: (_) => Container(
        height: 250,
        color: CupertinoDynamicColor.resolve(
          CupertinoColors.systemBackground,
          context,
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CupertinoButton(
                  child: const Text('Done'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            Expanded(
              child: CupertinoDatePicker(
                initialDateTime: provider.submissionDate,
                mode: CupertinoDatePickerMode.date,
                maximumDate: DateTime.now(),
                minimumDate:
                    DateTime.now().subtract(const Duration(days: 365)),
                onDateTimeChanged: provider.setSubmissionDate,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDatePresetChip(String label, VoidCallback onTap) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      minimumSize: Size.zero,
      onPressed: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0x0C000000),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          style: NelfundTypography.captionBold.copyWith(fontSize: 10),
        ),
      ),
    );
  }

  Widget _buildHealthResultCard(
      BuildContext context, SlaEvaluationResult eval) {
    final Color statusColor;
    final IconData statusIcon;
    final Color bgColor;

    switch (eval.healthStatus) {
      case SlaHealthStatus.onTrack:
        statusColor = NelfundColors.emerald;
        statusIcon = CupertinoIcons.checkmark_seal_fill;
        bgColor = const Color(0xF2F0FBF5);
        break;
      case SlaHealthStatus.approachingDeadline:
        statusColor = CupertinoColors.systemOrange;
        statusIcon = CupertinoIcons.hourglass;
        bgColor = const Color(0xF2FFFBF0);
        break;
      case SlaHealthStatus.overdue:
        statusColor = CupertinoColors.systemRed;
        statusIcon = CupertinoIcons.exclamationmark_triangle_fill;
        bgColor = const Color(0xF2FFF4F4);
        break;
    }

    return AppleFrostedCard(
      backgroundColor: CupertinoDynamicColor.resolve(
        CupertinoDynamicColor.withBrightness(
          color: bgColor,
          darkColor: const Color(0xD01E2022),
        ),
        context,
      ),
      borderColor: statusColor.withValues(alpha: 0.4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(statusIcon, color: statusColor, size: 24),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  eval.statusTitle,
                  style: NelfundTypography.headline.copyWith(
                    color: statusColor,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            eval.diagnosis,
            style: NelfundTypography.body.copyWith(
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: CupertinoDynamicColor.resolve(
                const CupertinoDynamicColor.withBrightness(
                  color: CupertinoColors.white,
                  darkColor: Color(0xFF252628),
                ),
                context,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Working Days Elapsed',
                        style: NelfundTypography.captionBold.copyWith(
                          color: CupertinoColors.secondaryLabel,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${eval.elapsedWorkingDays} Days',
                        style: NelfundTypography.headline.copyWith(fontSize: 14),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 1,
                  height: 30,
                  color: const Color(0x1F000000),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Statutory Limit',
                        style: NelfundTypography.captionBold.copyWith(
                          color: CupertinoColors.secondaryLabel,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        eval.stageInfo.durationLabel,
                        style: NelfundTypography.headline.copyWith(fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                CupertinoIcons.arrow_right_circle_fill,
                size: 16,
                color: statusColor,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Recommended Action: ${eval.actionableAdvice}',
                  style: NelfundTypography.footnote.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildJourneyStageCard(BuildContext context, SlaStageInfo info) {
    return AppleFrostedCard(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: NelfundColors.emerald.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '${info.stageNumber}',
                    style: NelfundTypography.captionBold.copyWith(
                      color: NelfundColors.emerald,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      info.title,
                      style: NelfundTypography.headline.copyWith(fontSize: 15),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      info.actor,
                      style: NelfundTypography.captionBold.copyWith(
                        color: CupertinoColors.secondaryLabel,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: NelfundColors.emerald.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  info.durationLabel,
                  style: NelfundTypography.captionBold.copyWith(
                    color: NelfundColors.emerald,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            info.description,
            style: NelfundTypography.footnote.copyWith(fontSize: 12),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(CupertinoIcons.flag_fill,
                  size: 12, color: NelfundColors.emerald),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  'Milestone: ${info.milestone}',
                  style: NelfundTypography.captionBold.copyWith(
                    color: NelfundColors.emerald,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGrievanceCard(BuildContext context) {
    return AppleFrostedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(CupertinoIcons.speaker_2_fill,
                  color: NelfundColors.emerald, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Official Support & Complaints Channels',
                  style: NelfundTypography.headline.copyWith(fontSize: 15),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Under Section 6.0 of the Act, if your application exceeds statutory turnaround times without written explanation, lodge an official inquiry with your Application ID:',
            style: NelfundTypography.footnote.copyWith(
              color: CupertinoDynamicColor.resolve(
                  NelfundColors.secondaryLabel, context),
            ),
          ),
          const SizedBox(height: 12),
          _buildDirectoryItem(
            icon: CupertinoIcons.globe,
            title: 'Official Portal',
            value: 'nelf.gov.ng',
          ),
          _buildDirectoryItem(
            icon: CupertinoIcons.mail_solid,
            title: 'Grievance Email',
            value: 'support@nelf.gov.ng',
          ),
          _buildDirectoryItem(
            icon: CupertinoIcons.building_2_fill,
            title: 'Campus Support',
            value: 'Dean of Student Affairs / NELFUND Desk Officer',
          ),
        ],
      ),
    );
  }

  Widget _buildDirectoryItem({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: NelfundColors.emerald),
          const SizedBox(width: 8),
          Text(
            '$title: ',
            style: NelfundTypography.captionBold.copyWith(fontSize: 12),
          ),
          Expanded(
            child: Text(
              value,
              style: NelfundTypography.footnote.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
