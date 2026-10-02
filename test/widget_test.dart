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
    expect(find.text('About'), findsWidgets);

    // Verify Home Tab Content
    expect(find.text('My NELFund'), findsWidgets);
    expect(find.text('Student Loan Guide'), findsOneWidget);
    expect(find.byIcon(CupertinoIcons.bell_fill), findsOneWidget);
    expect(find.text('Program Overview'), findsOneWidget);
    expect(find.text('Key Loan Pillars'), findsOneWidget);
    expect(find.text('0% Zero Interest'), findsOneWidget);
    expect(find.text('₦20,000 Monthly Upkeep'), findsOneWidget);
    expect(find.text('Explore Tools & Guides'), findsOneWidget);

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
    expect(find.text('Fresh Entry'), findsOneWidget);
    expect(find.text('Direct Entry'), findsOneWidget);
    expect(find.text('Undergraduate'), findsOneWidget);
    expect(find.text('Reset'), findsNothing);
    expect(find.text('Evaluate My Eligibility'), findsOneWidget);
    expect(find.text('3. Statutory Disqualification Bars'), findsOneWidget);

    // Verify Animated Help button opens the dismissable Student Eligibility Guide modal
    expect(find.text('Help Guide'), findsOneWidget);
    await tester.tap(find.text('Help Guide'));
    await tester.pumpAndSettle();
    expect(find.text('Student Eligibility Guide'), findsOneWidget);
    expect(find.textContaining('Follow through the following steps to check if you are eligible'), findsOneWidget);

    // Dismiss modal
    await tester.tap(find.text('Got It, Let’s Begin'));
    await tester.pumpAndSettle();
    expect(find.text('Student Eligibility Guide'), findsNothing);

    // Verify Evaluate modal popup opens
    await tester.tap(find.text('Evaluate My Eligibility'));
    await tester.pumpAndSettle();
    expect(find.text('Incomplete Requirements'), findsOneWidget);
    expect(find.text('Review Checklist'), findsOneWidget);
    await tester.tap(find.text('Review Checklist'));
    await tester.pumpAndSettle();

    // Switch back to Home tab via bottom bar
    await tester.tap(find.byIcon(CupertinoIcons.house_alt));
    await tester.pumpAndSettle();

    expect(find.text('Program Overview'), findsOneWidget);

    // Switch to Calculator tab via bottom bar
    await tester.tap(find.byIcon(CupertinoIcons.creditcard));
    await tester.pumpAndSettle();

    // Verify Calculator Tab Content
    expect(find.text('Payment Calculator'), findsOneWidget);
    expect(find.text('Reset'), findsNothing);
    expect(find.text('NELFUND WALLET'), findsOneWidget);
    expect(find.text('Add Loan Year'), findsOneWidget);
    expect(find.text('STATUTORY MONTHLY DEDUCTION'), findsOneWidget);
    expect(find.text('Employment & Income Configurator'), findsOneWidget);
    expect(find.text('2-Year Post-NYSC Grace Period'), findsOneWidget);
    expect(find.text('Repayment Support & Compliance Guidelines'), findsOneWidget);

    // Switch to FAQ tab via bottom bar
    await tester.tap(find.byIcon(CupertinoIcons.bubble_left_bubble_right));
    await tester.pumpAndSettle();

    // Verify FAQ Tab Content
    expect(find.text('Official FAQ'), findsOneWidget);
    expect(find.text('30-Day Institutional Refund Rule (Sec. 4.1.2)'), findsOneWidget);
    expect(find.text('Global Standing Instruction (GSI) Alert (Sec. 5.3)'), findsNothing);
    expect(find.byType(CupertinoSearchTextField), findsOneWidget);

    // Switch to About tab via bottom bar
    await tester.tap(find.byIcon(CupertinoIcons.person_crop_circle));
    await tester.pumpAndSettle();

    // Verify About Tab Content
    expect(find.text('About & Support'), findsOneWidget);
    expect(find.text('08164135836'), findsWidgets);
    expect(find.text('Chat on WhatsApp (WhatsApp Only)'), findsOneWidget);
    expect(find.text('Abdullahi Adam Usman'), findsWidgets);
    expect(find.text('Co-Founder, Anjal Solutions Ltd'), findsWidgets);
    expect(find.text('Official Clarification & Disclaimer'), findsOneWidget);
    expect(find.text('Official NELFUND Channels'), findsOneWidget);
  });
}
