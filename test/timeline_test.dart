import 'package:flutter_test/flutter_test.dart';
import 'package:my_nelfund/features/timeline/domain/timeline_model.dart';
import 'package:my_nelfund/features/timeline/presentation/providers/timeline_provider.dart';

void main() {
  group('TimelineProvider & SLA Statutory Evaluator Tests', () {
    late TimelineProvider provider;

    setUp(() {
      provider = TimelineProvider();
    });

    test('All 5 statutory turnaround stages match Section 4.2 definitions', () {
      expect(SlaStageInfo.allStages.length, 5);

      final stage1 = SlaStageInfo.getFor(SlaStage.etiVerification);
      expect(stage1.allowedDays, 20);
      expect(stage1.isWorkingDays, isTrue);

      final stage2 = SlaStageInfo.getFor(SlaStage.nelfundEvaluation);
      expect(stage2.allowedDays, 15);
      expect(stage2.isWorkingDays, isFalse);

      final stage3 = SlaStageInfo.getFor(SlaStage.approval);
      expect(stage3.allowedDays, 10);
      expect(stage3.isWorkingDays, isTrue);

      final stage4 = SlaStageInfo.getFor(SlaStage.disbursement);
      expect(stage4.allowedDays, 10);
      expect(stage4.isWorkingDays, isTrue);

      final stage5 = SlaStageInfo.getFor(SlaStage.etiReceipt);
      expect(stage5.allowedDays, 7);
      expect(stage5.isWorkingDays, isTrue);
    });

    test('Working days calculation skips Saturdays and Sundays accurately', () {
      // Wednesday to next Wednesday (7 calendar days, 5 working days elapsed)
      final start = DateTime(2026, 9, 2); // Wednesday
      final end = DateTime(2026, 9, 9); // Next Wednesday
      final workingDays = TimelineProvider.calculateWorkingDays(start, end);
      expect(workingDays, 5);
    });

    test('Evaluator diagnoses application within SLA as onTrack', () {
      provider.setCurrentStage(SlaStage.etiVerification);
      provider.setSubmissionDate(
        DateTime.now().subtract(const Duration(days: 3)),
      );

      final eval = provider.evaluation;
      expect(eval.healthStatus, SlaHealthStatus.onTrack);
      expect(eval.statusTitle, contains('On Schedule'));
    });

    test(
      'Evaluator flags application exceeding limit as overdue with actionable escalation',
      () {
        provider.setCurrentStage(SlaStage.etiVerification);
        // 40 calendar days ago is ~28 working days, well over 20 allowed
        provider.setSubmissionDate(
          DateTime.now().subtract(const Duration(days: 40)),
        );

        final eval = provider.evaluation;
        expect(eval.healthStatus, SlaHealthStatus.overdue);
        expect(eval.statusTitle, contains('SLA Deadline Exceeded'));
        expect(eval.actionableAdvice, contains('Student Affairs'));
      },
    );

    test('Reset restores default submission date and initial stage', () {
      provider.setCurrentStage(SlaStage.disbursement);
      provider.setSubmissionDate(
        DateTime.now().subtract(const Duration(days: 60)),
      );
      provider.reset();

      expect(provider.currentStage, SlaStage.etiVerification);
    });
  });
}
