import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_nelfund/main.dart';
import 'package:my_nelfund/views/splash/splash_view.dart';

void main() {
  group('SplashView Animated Entry Tests', () {
    testWidgets('Renders official branding, emblem, and statutory text',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(const MyNelfundApp());
      // Initial frame of splash
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byType(SplashView), findsOneWidget);
      expect(find.text('Federal Republic of Nigeria'), findsOneWidget);
      expect(find.text('My NELFund'), findsOneWidget);
      expect(find.text('Nigerian Education Loan Fund'), findsOneWidget);
      expect(
          find.text('Students Loans (Access to Higher Education) Act 2024'),
          findsOneWidget);
      expect(
          find.text('Initializing Statutory Guidelines...'), findsOneWidget);
      expect(find.text('Tap anywhere to skip'), findsOneWidget);
      expect(find.byType(CupertinoActivityIndicator), findsOneWidget);
    });

    testWidgets('Tapping on screen skips immediately to MainTabScaffold',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(const MyNelfundApp());
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.byType(SplashView), findsOneWidget);

      // Tap on the splash view
      await tester.tap(find.byType(SplashView));
      await tester.pumpAndSettle();

      // Main tab scaffold should now be loaded
      expect(find.text('Portal Currently Open'), findsOneWidget);
      expect(find.text('0% Zero Interest'), findsOneWidget);
    });

    testWidgets('Auto-transitions to MainTabScaffold after timeout',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(const MyNelfundApp());
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(SplashView), findsOneWidget);

      // Advance past the 2400ms duration + fade transition
      await tester.pump(const Duration(milliseconds: 2500));
      await tester.pumpAndSettle();

      expect(find.text('Portal Currently Open'), findsOneWidget);
    });
  });
}
