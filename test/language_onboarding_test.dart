import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:my_nelfund/core/localization/locale_provider.dart';
import 'package:my_nelfund/views/home/home_view.dart';
import 'package:my_nelfund/main.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Home Header Language Toggle', () {
    testWidgets('Toggles language smoothly between English and Hausa in Home header',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final localeProvider = LocaleProvider();

      await tester.pumpWidget(
        ChangeNotifierProvider<LocaleProvider>.value(
          value: localeProvider,
          child: const CupertinoApp(
            home: HomeView(showLanguageOnboarding: false),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Initial state: English
      expect(find.text('English'), findsOneWidget);
      expect(find.text('Harshen Hausa'), findsOneWidget);
      expect(find.text('Student Loan Guide'), findsOneWidget);
      expect(find.text('Program Overview'), findsOneWidget);

      // Tap 'Harshen Hausa' on the header segmented toggle
      await tester.tap(find.text('Harshen Hausa'));
      await tester.pumpAndSettle();

      // Verified Hausa state
      expect(find.text('Fahimtar Bashin Karatu na Dalibai.'), findsOneWidget);
      expect(find.text('Bayanin Shirin Bashi'), findsOneWidget);
      expect(find.text('Muhimman Rukunnan Bashi'), findsOneWidget);

      // Tap 'English' to switch back
      await tester.tap(find.text('English'));
      await tester.pumpAndSettle();

      // Verified English state restored
      expect(find.text('Student Loan Guide'), findsOneWidget);
      expect(find.text('Program Overview'), findsOneWidget);
    });
  });

  group('Central First-Time Language Onboarding Modal', () {
    testWidgets('Displays modal on first launch, allows language selection, and dismisses on confirmation',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      SharedPreferences.setMockInitialValues({});

      await tester.pumpWidget(
        const MyNelfundApp(
          skipSplash: true,
          showLanguageOnboarding: true,
        ),
      );
      await tester.pumpAndSettle();

      // Verify the modal is displayed
      expect(find.text('NEW FEATURE • BILINGUAL'), findsOneWidget);
      expect(find.text('Language Preference • Zaɓin Harshe'), findsOneWidget);
      expect(find.text('Confirm & Continue'), findsOneWidget);

      // Select 'Harshen Hausa' within the modal (last instance, as first is in the header behind)
      final hausaModalOption = find.text('Harshen Hausa').last;
      await tester.tap(hausaModalOption);
      await tester.pumpAndSettle();

      // Modal dynamically updates text to formal Hausa
      expect(find.text('SABON TSARI • BILINGUAL'), findsOneWidget);
      expect(find.text('Zaɓin Harshe • Language Selection'), findsOneWidget);
      expect(find.text('Tabbatar da Zaɓi'), findsOneWidget);

      // Tap 'Tabbatar da Zaɓi' to confirm and dismiss
      await tester.tap(find.text('Tabbatar da Zaɓi'));
      await tester.pumpAndSettle();

      // Verify modal is dismissed and HomeView reflects Hausa
      expect(find.text('Tabbatar da Zaɓi'), findsNothing);
      expect(find.text('Fahimtar Bashin Karatu na Dalibai.'), findsOneWidget);

      // Verify SharedPreferences has marked modal as seen
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('has_seen_language_modal_v2'), isTrue);
    });

    testWidgets('Does not display modal when user has already seen it',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      // Pre-seed preference as seen
      SharedPreferences.setMockInitialValues({
        'has_seen_language_modal_v2': true,
      });

      await tester.pumpWidget(
        const MyNelfundApp(
          skipSplash: true,
          showLanguageOnboarding: true,
        ),
      );
      await tester.pumpAndSettle();

      // Modal should NOT appear
      expect(find.text('NEW FEATURE • BILINGUAL'), findsNothing);
      expect(find.text('Language Preference • Zaɓin Harshe'), findsNothing);
      expect(find.text('Confirm & Continue'), findsNothing);

      // Regular home screen should be visible
      expect(find.text('Program Overview'), findsOneWidget);
    });
  });
}
