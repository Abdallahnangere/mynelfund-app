import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_nelfund/views/main_tab_scaffold.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets(
      'Global Navigation: Back button on non-Home tabs returns to Home (Tab 0)',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      const CupertinoApp(
        home: MainTabScaffold(),
      ),
    );
    await tester.pumpAndSettle();

    // Verify initial tab is Home
    expect(find.text('Program Overview'), findsOneWidget);

    // 1. Switch to Eligibility Tab (Tab 1)
    await tester.tap(find.byIcon(CupertinoIcons.checkmark_seal));
    await tester.pumpAndSettle();
    expect(find.text('Eligibility Checker'), findsOneWidget);

    // Trigger System Back Button
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    // Must return to Home Tab
    expect(find.text('Program Overview'), findsOneWidget);

    // 2. Switch to Calculator Tab (Tab 2)
    await tester.tap(find.byIcon(CupertinoIcons.creditcard));
    await tester.pumpAndSettle();
    expect(find.text('Payment Calculator'), findsOneWidget);

    // Trigger System Back Button
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    // Must return to Home Tab
    expect(find.text('Program Overview'), findsOneWidget);

    // 3. Switch to FAQ Tab (Tab 3)
    await tester.tap(find.byIcon(CupertinoIcons.bubble_left_bubble_right));
    await tester.pumpAndSettle();
    expect(find.text('Official FAQ'), findsOneWidget);

    // Trigger System Back Button
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    // Must return to Home Tab
    expect(find.text('Program Overview'), findsOneWidget);

    // 4. Switch to About Tab (Tab 4)
    await tester.tap(find.byIcon(CupertinoIcons.person_crop_circle));
    await tester.pumpAndSettle();
    expect(find.text('About & Support'), findsOneWidget);

    // Trigger System Back Button
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    // Must return to Home Tab
    expect(find.text('Program Overview'), findsOneWidget);

    // 5. While on Home (Tab 0) at root, back button shows double-tap exit toast
    await tester.binding.handlePopRoute();
    await tester.pump();
    expect(find.text('Press back again to exit'), findsOneWidget);

    // Let the 2-second toast timer elapse cleanly
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
  });
}
