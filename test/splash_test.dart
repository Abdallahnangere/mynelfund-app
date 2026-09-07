import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_nelfund/main.dart';
import 'package:my_nelfund/views/splash/splash_view.dart';

void main() {
  group('SplashView Animated Entry Tests', () {
    testWidgets('Renders official branding, emblem, Act citation, and Continue button',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(const MyNelfundApp());
      // Advance animation so all widgets are built and visible
      await tester.pump(const Duration(milliseconds: 1800));

      expect(find.byType(SplashView), findsOneWidget);
      expect(find.text('Federal Republic of Nigeria'), findsOneWidget);
      expect(find.text('My NELFund'), findsOneWidget);
      expect(find.text('Nigerian Education Loan Fund'), findsOneWidget);
      expect(
          find.text('Students Loans (Access to Higher Education) Act 2024'),
          findsOneWidget);
      expect(find.text('Continue to Portal'), findsOneWidget);
      expect(
          find.text('Portal Ready • Official Version 1.0.0'), findsOneWidget);
      expect(find.byType(CupertinoActivityIndicator), findsOneWidget);
    });

    testWidgets('Tapping Continue to Portal button transitions to MainTabScaffold',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(const MyNelfundApp());
      await tester.pump(const Duration(milliseconds: 1800));

      expect(find.text('Continue to Portal'), findsOneWidget);

      // Tap on the Continue to Portal button
      await tester.tap(find.text('Continue to Portal'));
      await tester.pumpAndSettle();

      // Main tab scaffold should now be loaded
      expect(find.text('Portal Currently Open'), findsOneWidget);
      expect(find.text('0% Zero Interest'), findsOneWidget);
    });

    testWidgets('Tapping anywhere on splash screen also navigates to MainTabScaffold',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(const MyNelfundApp());
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.byType(SplashView), findsOneWidget);

      // Tap anywhere on the screen
      await tester.tap(find.byType(SplashView));
      await tester.pumpAndSettle();

      expect(find.text('Portal Currently Open'), findsOneWidget);
    });
  });
}
