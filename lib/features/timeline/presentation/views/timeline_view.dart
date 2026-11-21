import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../../app/app.dart';
import '../../../../core/localization/app_locale.dart';
import '../../../../core/localization/app_translations.dart';
import '../../../../core/localization/locale_provider.dart';
import '../../../../core/theme/nelfund_colors.dart';
import '../../../../core/theme/nelfund_typography.dart';
import '../../../../shared/widgets/liquid_glass_header.dart';
import '../../../../shared/widgets/section_header.dart';
import '../../domain/timeline_model.dart';
import '../providers/timeline_provider.dart';
import '../widgets/grievance_directory_card.dart';
import '../widgets/sla_evaluator_card.dart';
import '../widgets/sla_health_result_card.dart';
import '../widgets/sla_stage_card.dart';

/// 5-stage statutory SLA tracker evaluating application processing progress
/// against official turnaround benchmarks and Section 6.0 escalation rules.
class TimelineView extends StatelessWidget {
  /// Creates a [TimelineView].
  const TimelineView({super.key});

  @override
  Widget build(BuildContext context) {
    final localeProv = AppProviders.maybeRead<LocaleProvider>(context);
    final timelineProv = AppProviders.maybeRead<TimelineProvider>(context);

    if (localeProv == null || timelineProv == null) {
      return MultiProvider(
        providers: [
          if (localeProv == null)
            ChangeNotifierProvider<LocaleProvider>(
              create: (_) => LocaleProvider(),
            ),
          if (timelineProv == null)
            ChangeNotifierProvider<TimelineProvider>(
              create: (_) => TimelineProvider(),
            ),
        ],
        child: const _TimelineViewContent(),
      );
    }

    return const _TimelineViewContent();
  }
}

class _TimelineViewContent extends StatelessWidget {
  const _TimelineViewContent();

  @override
  Widget build(BuildContext context) {
    final tr = AppTranslations.of(context);
    final lang = context.select<LocaleProvider, AppLanguage>(
      (p) => p.currentLanguage,
    );
    final timelineProv = context.watch<TimelineProvider>();
    final evaluation = timelineProv.getEvaluation(lang);
    final secondaryColor = CupertinoDynamicColor.resolve(
      NelfundColors.secondaryLabel,
      context,
    );

    return CupertinoPageScaffold(
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            LiquidGlassHeader(
              title: tr.timelineHeaderTitle,
              subtitle: tr.isHausa
                  ? "Wa'adin Doka na Matakai 5"
                  : '5-Stage Statutory SLA Guide',
              showBackButton: Navigator.canPop(context),
              trailing: CupertinoButton(
                padding: const EdgeInsets.all(6),
                minimumSize: const Size(34, 34),
                onPressed: () {
                  HapticFeedback.lightImpact();
                  timelineProv.reset();
                },
                child: const Icon(
                  CupertinoIcons.refresh,
                  color: NelfundColors.emerald,
                  size: 20,
                ),
              ),
            ),
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.fromLTRB(0, 12, 0, 96),
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 4,
                    ),
                    child: Text(
                      tr.timelineIntroDesc,
                      style: NelfundTypography.footnote.copyWith(
                        fontSize: 12.5,
                        height: 1.4,
                        color: secondaryColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  SlaEvaluatorCard(
                    currentStage: timelineProv.currentStage,
                    submissionDate: timelineProv.submissionDate,
                    language: lang,
                    tr: tr,
                    onStageSelected: timelineProv.setCurrentStage,
                    onSubmissionDateChanged: timelineProv.setSubmissionDate,
                  ),
                  SlaHealthResultCard(
                    evaluation: evaluation,
                    language: lang,
                    tr: tr,
                  ),
                  const SizedBox(height: 8),
                  SectionHeader(
                    title: tr.isHausa
                        ? 'Matakai 5 na Hukuma'
                        : 'Official 5-Stage Journey',
                  ),
                  ...SlaStageInfo.allStages.map(
                    (info) => SlaStageCard(
                      info: info,
                      language: lang,
                      tr: tr,
                      isActive: info.stage == timelineProv.currentStage,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SectionHeader(title: tr.grievanceDirectoryTitle),
                  GrievanceDirectoryCard(tr: tr),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
