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
      expect(find.text('ABU Zaria'), findsOneWidget);
      expect(find.text('NELFUND'), findsOneWidget);
      expect(find.text('🚀'), findsOneWidget);
      expect(find.text('For Students, By a Student'), findsOneWidget);
      expect(find.text('From ABU to the World 🌍'), findsOneWidget);
      expect(find.text('Federal Republic of Nigeria'), findsOneWidget);
      expect(find.text('My NELFund'), findsOneWidget);
      expect(find.text('Nigerian Education Loan Fund'), findsOneWidget);
      expect(
          find.text('Students Loans (Access to Higher Education) Act 2024'),
          findsOneWidget);
      expect(find.text('Proceed to App'), findsOneWidget);
      expect(find.text('Version 1.0.0'), findsOneWidget);
      expect(find.byType(CupertinoActivityIndicator), findsNothing);
    });

    testWidgets('Tapping Proceed to App button transitions to MainTabScaffold',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(const MyNelfundApp());
      await tester.pump(const Duration(milliseconds: 1800));

      expect(find.text('Proceed to App'), findsOneWidget);

      // Tap on the Proceed to App button
      await tester.tap(find.text('Proceed to App'));
      await tester.pumpAndSettle();

      // Main tab scaffold should now be loaded
      expect(find.text('Program Overview'), findsOneWidget);
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

      expect(find.text('Program Overview'), findsOneWidget);
    });
  });
}
