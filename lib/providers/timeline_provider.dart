import 'package:flutter/foundation.dart';
import '../models/timeline_model.dart';

class TimelineProvider extends ChangeNotifier {
  DateTime _submissionDate = DateTime.now().subtract(const Duration(days: 10));
  SlaStage _currentStage = SlaStage.etiVerification;

  DateTime get submissionDate => _submissionDate;
  SlaStage get currentStage => _currentStage;

  void setSubmissionDate(DateTime date) {
    _submissionDate = date;
    notifyListeners();
  }

  void setCurrentStage(SlaStage stage) {
    _currentStage = stage;
    notifyListeners();
  }

  void reset() {
    _submissionDate = DateTime.now().subtract(const Duration(days: 10));
    _currentStage = SlaStage.etiVerification;
    notifyListeners();
  }

  static int calculateWorkingDays(DateTime start, DateTime end) {
    if (end.isBefore(start)) return 0;
    int workingDays = 0;
    DateTime current = DateTime(start.year, start.month, start.day);
    final finish = DateTime(end.year, end.month, end.day);

    while (!current.isAfter(finish)) {
      if (current.weekday != DateTime.saturday &&
          current.weekday != DateTime.sunday) {
        workingDays++;
      }
      current = current.add(const Duration(days: 1));
    }
    // Return working days elapsed after start day
    return (workingDays - 1).clamp(0, 9999);
  }

  SlaEvaluationResult get evaluation {
    final now = DateTime.now();
    final elapsedCalendar =
        now.difference(DateTime(_submissionDate.year, _submissionDate.month, _submissionDate.day)).inDays;
    final elapsedWorking = calculateWorkingDays(_submissionDate, now);

    final stageInfo = SlaStageInfo.getFor(_currentStage);
    final relevantElapsed =
        stageInfo.isWorkingDays ? elapsedWorking : elapsedCalendar;

    final SlaHealthStatus health;
    final String statusTitle;
    final String diagnosis;

    if (relevantElapsed > stageInfo.allowedDays) {
      health = SlaHealthStatus.overdue;
      statusTitle = 'SLA Deadline Exceeded';
      final daysOver = relevantElapsed - stageInfo.allowedDays;
      diagnosis =
          'This stage is $daysOver ${stageInfo.isWorkingDays ? 'working' : 'calendar'} days past the statutory limit of ${stageInfo.durationLabel}. Escalation is recommended.';
    } else if (relevantElapsed >= (stageInfo.allowedDays * 0.75).floor()) {
      health = SlaHealthStatus.approachingDeadline;
      statusTitle = 'Approaching Statutory Deadline';
      final remaining = stageInfo.allowedDays - relevantElapsed;
      diagnosis =
          'Your application has been in this stage for $relevantElapsed of ${stageInfo.allowedDays} allowed ${stageInfo.isWorkingDays ? 'working' : 'calendar'} days. Approximately $remaining days remain.';
    } else {
      health = SlaHealthStatus.onTrack;
      statusTitle = 'Processing On Schedule';
      final remaining = stageInfo.allowedDays - relevantElapsed;
      diagnosis =
          'Your application is well within the official ${stageInfo.durationLabel} window ($relevantElapsed elapsed, $remaining remaining). Processing is proceeding normally.';
    }

    return SlaEvaluationResult(
      submissionDate: _submissionDate,
      stageInfo: stageInfo,
      elapsedCalendarDays: elapsedCalendar,
      elapsedWorkingDays: elapsedWorking,
      healthStatus: health,
      statusTitle: statusTitle,
      diagnosis: diagnosis,
      actionableAdvice: stageInfo.escalationAction,
    );
  }
}
