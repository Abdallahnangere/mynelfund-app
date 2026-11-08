import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:my_nelfund/core/localization/locale_provider.dart';
import 'package:my_nelfund/providers/promo_provider.dart';
import 'package:my_nelfund/views/home/home_view.dart';
import 'package:my_nelfund/main.dart';

void main() {
  setUp(() {
    PromoProvider.isTesting = true;
    SharedPreferences.setMockInitialValues({});
  });

  group('Home Header Language Toggle', () {
    testWidgets(
        'Toggles language smoothly between English and Hausa in Home header',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final localeProvider = LocaleProvider();
      final promoProvider = PromoProvider();

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<LocaleProvider>.value(value: localeProvider),
            ChangeNotifierProvider<PromoProvider>.value(value: promoProvider),
          ],
          child: const CupertinoApp(
            home: HomeView(showStartupPromo: false),
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

  group('Retired Language Onboarding Modal', () {
    testWidgets(
        'Legacy language onboarding modal never appears on startup while header toggle persists language',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      SharedPreferences.setMockInitialValues({});

      await tester.pumpWidget(
        const MyNelfundApp(
          skipSplash: true,
          showStartupPromo: false,
        ),
      );
      await tester.pumpAndSettle();

      // Retired language onboarding modal must NOT appear
      expect(find.text('NEW FEATURE • BILINGUAL'), findsNothing);
      expect(find.text('Language Preference • Zaɓin Harshe'), findsNothing);
      expect(find.text('Confirm & Continue'), findsNothing);

      // Home screen is immediately accessible
      expect(find.text('Program Overview'), findsOneWidget);

      // Selecting Hausa from the header segmented toggle persists choice
      await tester.tap(find.text('Harshen Hausa'));
      await tester.pumpAndSettle();

      expect(find.text('Fahimtar Bashin Karatu na Dalibai.'), findsOneWidget);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('app_language_preference'), equals('ha'));
    });

    testWidgets(
        'Startup with showStartupPromo: true shows only Sauki Go modal and never legacy language modal',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      SharedPreferences.setMockInitialValues({});

      await tester.pumpWidget(
        const MyNelfundApp(
          skipSplash: true,
          showStartupPromo: true,
        ),
      );
      await tester.pumpAndSettle();

      // Legacy language modal is completely absent
      expect(find.text('NEW FEATURE • BILINGUAL'), findsNothing);
      expect(find.text('Confirm & Continue'), findsNothing);

      // Sole startup modal is Sauki Go promo modal
      expect(find.byKey(const ValueKey('sauki_promo_modal')), findsOneWidget);
    });
  });
}
