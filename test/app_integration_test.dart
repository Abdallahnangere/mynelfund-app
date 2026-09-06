import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_nelfund/main.dart';

void main() {
  testWidgets('Full End-to-End User Journey Across All 5 Tabs',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    // 1. Launch Application
    await tester.pumpWidget(const MyNelfundApp());
    await tester.pumpAndSettle();

    // ==========================================
    // TAB 0: HOME
    // ==========================================
    expect(find.text('My NELFund'), findsAtLeastNWidgets(1));
    expect(find.text('Federal Republic of Nigeria'), findsOneWidget);
    expect(find.text('Portal Currently Open'), findsOneWidget);
    expect(find.text('0% Zero Interest'), findsOneWidget);
    expect(find.text('Direct Tuition Disbursement'), findsOneWidget);
    expect(find.text('₦20,000 Monthly Upkeep'), findsOneWidget);

    // Tap quick action to navigate to Eligibility
    await tester.tap(find.text('Eligibility Checker').first);
    await tester.pumpAndSettle();

    // ==========================================
    // TAB 1: ELIGIBILITY CHECKER
    // ==========================================
    expect(find.text('Official Eligibility Audit'), findsOneWidget);
    expect(find.text('Likely Eligible for NELFUND Loan'), findsOneWidget);

    // Switch academic stream
    await tester.tap(find.text('Direct Entry'));
    await tester.pumpAndSettle();

    // Trigger disqualification switch
    final switches = find.byType(CupertinoSwitch);
    expect(switches, findsWidgets);
    await tester.tap(switches.last);
    await tester.pumpAndSettle();

    // Verify diagnostic changes
    expect(find.text('May Be Disqualified Under NELFUND Rules'), findsOneWidget);

    // Reset checker
    await tester.tap(find.text('Reset'));
    await tester.pumpAndSettle();
    expect(find.text('Likely Eligible for NELFUND Loan'), findsOneWidget);

    // ==========================================
    // TAB 2: REPAYMENT CALCULATOR
    // ==========================================
    await tester.tap(find.byIcon(CupertinoIcons.chart_pie));
    await tester.pumpAndSettle();

    expect(find.text('Statutory 10% Repayment Model'), findsOneWidget);
    expect(find.text('₦15,000'), findsOneWidget);

    // Switch to Self-Employed mode
    await tester.tap(find.text('Self-Employed (Direct)'));
    await tester.pumpAndSettle();
    expect(find.text('STATUTORY MONTHLY DEDUCTION'), findsOneWidget);
    expect(find.textContaining('10% of monthly business profit'),
        findsOneWidget);

    // Verify Moratorium & Default visualizer
    expect(find.text('2-Year Post-NYSC Grace Period'), findsOneWidget);
    expect(find.text('Default Escalation Timeline (Section 5.3)'),
        findsOneWidget);

    // ==========================================
    // TAB 3: FAQ KNOWLEDGE BASE
    // ==========================================
    await tester.tap(find.byIcon(CupertinoIcons.question_circle));
    await tester.pumpAndSettle();

    expect(find.text('Official FAQ'), findsOneWidget);
    expect(find.text('30-Day Institutional Refund Rule (Sec. 4.1.2)'),
        findsOneWidget);
    expect(find.text('Global Standing Instruction (GSI) Alert (Sec. 5.3)'),
        findsOneWidget);

    // Test real-time search
    await tester.enterText(find.byType(CupertinoSearchTextField), 'GSI');
    await tester.pumpAndSettle();

    // Expand search result
    await tester.tap(find.text('What is the Global Standing Instruction (GSI) mandate?'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Section 5.3'), findsWidgets);

    // Clear search
    await tester.tap(find.byIcon(CupertinoIcons.clear_thick_circled));
    await tester.pumpAndSettle();

    // ==========================================
    // TAB 4: TIMELINE & SLA TRACKER
    // ==========================================
    await tester.tap(find.byIcon(CupertinoIcons.clock));
    await tester.pumpAndSettle();

    expect(find.text('Official Service Level Agreements (SLAs)'),
        findsOneWidget);
    expect(find.text('Interactive On-Track Evaluator'), findsOneWidget);
    expect(find.text('Official Grievance & Escalation Directory'),
        findsOneWidget);

    // Tap 40 Days Ago preset to trigger overdue diagnosis
    await tester.tap(find.text('40 Days Ago'));
    await tester.pumpAndSettle();
    expect(find.text('SLA Deadline Exceeded'), findsOneWidget);

    // Tap 3 Days Ago preset to return to on track
    await tester.tap(find.text('3 Days Ago'));
    await tester.pumpAndSettle();
    expect(find.text('Processing On Schedule'), findsOneWidget);

    // Tap Reset
    await tester.tap(find.text('Reset'));
    await tester.pumpAndSettle();

    // Return to Home tab
    await tester.tap(find.byIcon(CupertinoIcons.house));
    await tester.pumpAndSettle();
    expect(find.text('Portal Currently Open'), findsOneWidget);
  });
}
