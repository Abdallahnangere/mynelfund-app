import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_nelfund/main.dart';

void main() {
  testWidgets('MyNelfundApp launches with Home tab, logo, pillars, and quick navigation',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(const MyNelfundApp(skipSplash: true));
    await tester.pumpAndSettle();

    // Verify all 5 Cupertino navigation tab labels exist
    expect(find.text('Home'), findsWidgets);
    expect(find.text('Eligibility'), findsWidgets);
    expect(find.text('Calculator'), findsWidgets);
    expect(find.text('FAQ'), findsWidgets);
    expect(find.text('Timeline'), findsWidgets);

    // Verify Home Tab Content
    expect(find.text('My NELFund'), findsWidgets);
    expect(find.text('Student Loan Guide'), findsOneWidget);
    expect(find.byIcon(CupertinoIcons.bell_fill), findsOneWidget);
    expect(find.text('Portal Currently Open'), findsOneWidget);
    expect(find.text('0% Zero Interest'), findsOneWidget);
    expect(find.text('₦20,000 Monthly Upkeep'), findsOneWidget);
    expect(find.text('Key Loan Pillars (Act 2024)'), findsOneWidget);

    // Verify Notification Modal Popup
    await tester.tap(find.byIcon(CupertinoIcons.bell_fill));
    await tester.pumpAndSettle();
    expect(find.text('Official Bulletins'), findsOneWidget);
    expect(find.text('2024/2025 Application Window Open'), findsOneWidget);
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();

    // Verify Quick-Access card to Eligibility Checker
    final eligibilityActionCard = find.text('Eligibility Checker');
    expect(eligibilityActionCard, findsOneWidget);

    await tester.tap(eligibilityActionCard);
    await tester.pumpAndSettle();

    // Now Eligibility tab is active
    expect(find.text('Official Eligibility Audit'), findsOneWidget);
    expect(find.text('Fresh Entry'), findsOneWidget);
    expect(find.text('Likely Eligible for NELFUND Loan'), findsOneWidget);
    expect(find.text('Statutory Disqualification Bars'), findsOneWidget);

    // Switch back to Home tab via bottom bar
    await tester.tap(find.byIcon(CupertinoIcons.house));
    await tester.pumpAndSettle();

    expect(find.text('Portal Currently Open'), findsOneWidget);

    // Switch to Calculator tab via bottom bar
    await tester.tap(find.byIcon(CupertinoIcons.chart_pie));
    await tester.pumpAndSettle();

    // Verify Calculator Tab Content
    expect(find.text('Statutory 10% Repayment Model'), findsOneWidget);
    expect(find.text('STATUTORY MONTHLY DEDUCTION'), findsOneWidget);
    expect(find.text('₦15,000'), findsOneWidget);
    expect(find.text('2-Year Post-NYSC Grace Period'), findsOneWidget);
    expect(find.text('Default Escalation Timeline (Section 5.3)'), findsOneWidget);

    // Switch to FAQ tab via bottom bar
    await tester.tap(find.byIcon(CupertinoIcons.question_circle));
    await tester.pumpAndSettle();

    // Verify FAQ Tab Content
    expect(find.text('Official FAQ'), findsOneWidget);
    expect(find.text('30-Day Institutional Refund Rule (Sec. 4.1.2)'), findsOneWidget);
    expect(find.text('Global Standing Instruction (GSI) Alert (Sec. 5.3)'), findsOneWidget);
    expect(find.byType(CupertinoSearchTextField), findsOneWidget);

    // Switch to Timeline tab via bottom bar
    await tester.tap(find.byIcon(CupertinoIcons.clock));
    await tester.pumpAndSettle();

    // Verify Timeline Tab Content
    expect(find.text('Official Service Level Agreements (SLAs)'), findsOneWidget);
    expect(find.text('Interactive On-Track Evaluator'), findsOneWidget);
    expect(find.text('Official Grievance & Escalation Directory'), findsOneWidget);
  });
}
