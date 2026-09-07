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
    await tester.pumpWidget(const MyNelfundApp(skipSplash: true));
    await tester.pumpAndSettle();

    // ==========================================
    // TAB 0: HOME
    // ==========================================
    expect(find.text('My NELFund'), findsAtLeastNWidgets(1));
    expect(find.text('Student Loan Guide'), findsOneWidget);
    expect(find.text('Program Overview'), findsOneWidget);
    expect(find.text('Key Loan Pillars'), findsOneWidget);
    expect(find.text('0% Zero Interest'), findsOneWidget);
    expect(find.text('Direct Tuition Disbursement'), findsOneWidget);
    expect(find.text('₦20,000 Monthly Upkeep'), findsOneWidget);
    expect(find.text('Explore Tools & Guides'), findsOneWidget);

    // Tap quick action to navigate to Eligibility
    await tester.tap(find.text('Eligibility Checker').first);
    await tester.pumpAndSettle();

    // ==========================================
    // TAB 1: ELIGIBILITY CHECKER
    // ==========================================
    expect(find.text('Student Eligibility Guide'), findsOneWidget);
    expect(find.textContaining('Follow through the following steps to check if you are eligible'), findsOneWidget);
    expect(find.text('Reset'), findsNothing);
    expect(find.text('Evaluate My Eligibility'), findsOneWidget);

    // Switch academic stream
    await tester.tap(find.text('Direct Entry'));
    await tester.pumpAndSettle();

    // Verify Checkboxes are present and toggle one
    final checkboxes = find.byType(CupertinoCheckbox);
    expect(checkboxes, findsWidgets);
    await tester.tap(checkboxes.first);
    await tester.pumpAndSettle();

    // Trigger disqualification checkbox (e.g. last checkbox)
    await tester.tap(checkboxes.last);
    await tester.pumpAndSettle();

    // Verify center modal dialog opens with disqualification details
    await tester.tap(find.text('Evaluate My Eligibility'));
    await tester.pumpAndSettle();
    expect(find.text('Statutory Disqualification'), findsOneWidget);
    expect(find.text('Review Checklist'), findsOneWidget);
    await tester.tap(find.text('Review Checklist'));
    await tester.pumpAndSettle();

    // Verify bottom diagnostic card reflects triggered disqualification and portal button exists
    expect(find.text('Visit Official Portal for Guidelines'), findsOneWidget);

    // ==========================================
    // TAB 2: REPAYMENT CALCULATOR
    // ==========================================
    await tester.tap(find.byIcon(CupertinoIcons.chart_pie));
    await tester.pumpAndSettle();

    expect(find.text('Payment Calculator'), findsOneWidget);
    expect(find.text('Reset'), findsNothing);
    expect(find.text('NELFUND WALLET'), findsOneWidget);
    expect(find.text('STATUTORY MONTHLY DEDUCTION'), findsOneWidget);

    // Switch to Self-Employed mode
    await tester.tap(find.text('Self-Employed (Direct)'));
    await tester.pumpAndSettle();
    expect(find.text('STATUTORY MONTHLY DEDUCTION'), findsOneWidget);
    expect(find.textContaining('10% of monthly business profit'),
        findsOneWidget);

    // Verify Moratorium & Friendly compliance
    expect(find.text('2-Year Post-NYSC Grace Period'), findsOneWidget);
    expect(find.text('Repayment Support & Compliance Guidelines'),
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
        findsNothing);

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
    // TAB 4: ABOUT & SUPPORT
    // ==========================================
    await tester.tap(find.byIcon(CupertinoIcons.info_circle));
    await tester.pumpAndSettle();

    expect(find.text('About & Support'), findsOneWidget);
    expect(find.text('09076872520'), findsOneWidget);
    expect(find.text('Chat Directly on WhatsApp'), findsOneWidget);
    expect(find.text('Abdullahi Adam Usman'), findsWidgets);
    expect(find.text('Founder, Anjal Ventures'), findsWidgets);
    expect(find.text('Official Clarification & Disclaimer'), findsOneWidget);
    expect(find.text('Official NELFUND Channels'), findsOneWidget);
    expect(find.text('nelf.gov.ng'), findsOneWidget);
    expect(find.text('info@nelf.gov.ng'), findsOneWidget);

    // Return to Home tab
    await tester.tap(find.byIcon(CupertinoIcons.house));
    await tester.pumpAndSettle();
    expect(find.text('Program Overview'), findsOneWidget);
  });
}
