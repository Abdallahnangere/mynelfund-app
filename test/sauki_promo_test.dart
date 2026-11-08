import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:my_nelfund/core/localization/locale_provider.dart';
import 'package:my_nelfund/models/promo_model.dart';
import 'package:my_nelfund/providers/promo_provider.dart';
import 'package:my_nelfund/views/home/home_view.dart';

void main() {
  const expectedAppStoreUrl = 'https://apps.apple.com/app/id6815456102';
  const expectedPlayStoreUrl =
      'https://play.google.com/store/apps/details?id=com.saukimart.go';

  setUp(() {
    PromoProvider.isTesting = true;
    SharedPreferences.setMockInitialValues({});
  });

  Widget buildTestHome({
    required LocaleProvider localeProvider,
    required PromoProvider promoProvider,
    bool showStartupPromo = false,
  }) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<LocaleProvider>.value(value: localeProvider),
        ChangeNotifierProvider<PromoProvider>.value(value: promoProvider),
      ],
      child: CupertinoApp(
        home: HomeView(showStartupPromo: showStartupPromo),
      ),
    );
  }

  group('Sauki Go Promo UI, Placement & Direct Store Links', () {
    testWidgets(
        'Renders Get Data header button and SaukiPromoHomeCard between Program Overview and Key Loan Pillars with zero website links',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final localeProvider = LocaleProvider();
      final promoProvider = PromoProvider();

      await tester.pumpWidget(
        buildTestHome(
          localeProvider: localeProvider,
          promoProvider: promoProvider,
          showStartupPromo: false,
        ),
      );
      await tester.pumpAndSettle();

      // 1. Header "Get Data" pill is visible next to notification icon
      final getDataBtn = find.byKey(const ValueKey('header_get_data_button'));
      expect(getDataBtn, findsOneWidget);
      expect(find.text('Get Data'), findsOneWidget);

      // 2. SaukiPromoHomeCard is rendered between Program Overview and Key Loan Pillars
      final promoCard = find.byKey(const ValueKey('sauki_promo_home_card'));
      expect(promoCard, findsOneWidget);

      final programOverviewY =
          tester.getTopLeft(find.text('Program Overview')).dy;
      final promoCardY = tester.getTopLeft(promoCard).dy;
      final keyPillarsY = tester.getTopLeft(find.text('Key Loan Pillars')).dy;

      expect(promoCardY, greaterThan(programOverviewY));
      expect(promoCardY, lessThan(keyPillarsY));

      // 3. Verify plan snippets, CTA copy, and explicit platform store badges
      expect(find.text('Sauki Go'), findsOneWidget);
      expect(
        find.text('Get affordable data and airtime from our trusted app'),
        findsOneWidget,
      );
      expect(find.text('All Monthly'), findsOneWidget);
      expect(find.text('1GB'), findsOneWidget);
      expect(find.text('₦400'), findsOneWidget);
      expect(find.text('5GB'), findsOneWidget);
      expect(find.text('₦1,500'), findsOneWidget);
      expect(find.text('FOR IPHONE'), findsOneWidget);
      expect(find.text('App Store'), findsOneWidget);
      expect(find.text('FOR ANDROID'), findsOneWidget);
      expect(find.text('Google Play'), findsOneWidget);

      // 4. Strictly zero website URL displayed anywhere
      expect(find.textContaining('saukimart.com'), findsNothing);
    });

    testWidgets(
        'Tapping App Store and Google Play badges on Home card launches exact store URLs and marks store clicked',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final launchedUris = <Uri>[];
      final localeProvider = LocaleProvider();
      final promoProvider = PromoProvider(
        customLauncher: (uri) async {
          launchedUris.add(uri);
          return true;
        },
      );

      await tester.pumpWidget(
        buildTestHome(
          localeProvider: localeProvider,
          promoProvider: promoProvider,
          showStartupPromo: false,
        ),
      );
      await tester.pumpAndSettle();

      // Tap App Store badge (For iPhone)
      await tester.tap(
        find.byKey(const ValueKey('sauki_home_app_store_badge')),
      );
      await tester.pumpAndSettle();

      expect(launchedUris.length, 1);
      expect(launchedUris.first.toString(), equals(expectedAppStoreUrl));

      // Tap Google Play badge (For Android)
      await tester.tap(
        find.byKey(const ValueKey('sauki_home_play_store_badge')),
      );
      await tester.pumpAndSettle();

      expect(launchedUris.length, 2);
      expect(launchedUris.last.toString(), equals(expectedPlayStoreUrl));

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool(PromoProvider.prefStoreClicked), isTrue);
    });

    testWidgets(
        'Header "Get Data" button always opens SaukiPromoModal on demand and modal badges launch exact store URLs',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      // Pre-seed store clicked + recent modal shown to verify on-demand still opens
      SharedPreferences.setMockInitialValues({
        PromoProvider.prefStoreClicked: true,
        PromoProvider.prefLastShownMs: DateTime.now().millisecondsSinceEpoch,
      });

      final launchedUris = <Uri>[];
      final localeProvider = LocaleProvider();
      final promoProvider = PromoProvider(
        customLauncher: (uri) async {
          launchedUris.add(uri);
          return true;
        },
      );

      await tester.pumpWidget(
        buildTestHome(
          localeProvider: localeProvider,
          promoProvider: promoProvider,
          showStartupPromo: false,
        ),
      );
      await tester.pumpAndSettle();

      // Tap "Get Data" header pill
      await tester.tap(find.byKey(const ValueKey('header_get_data_button')));
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('sauki_promo_modal')), findsOneWidget);
      expect(find.text('TRUSTED APP • SAUKI GO'), findsOneWidget);
      expect(find.text('FOR IPHONE • DOWNLOAD ON'), findsOneWidget);
      expect(find.text('FOR ANDROID • GET IT ON'), findsOneWidget);
      expect(find.textContaining('saukimart.com'), findsNothing);

      // Tap App Store badge inside modal -> closes modal and launches App Store URL
      await tester.tap(
        find.byKey(const ValueKey('sauki_modal_app_store_badge')),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('sauki_promo_modal')), findsNothing);
      expect(launchedUris, [Uri.parse(expectedAppStoreUrl)]);

      // Re-open via "Get Data" and tap Google Play badge inside modal
      await tester.tap(find.byKey(const ValueKey('header_get_data_button')));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('sauki_promo_modal')), findsOneWidget);

      await tester.tap(
        find.byKey(const ValueKey('sauki_modal_play_store_badge')),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('sauki_promo_modal')), findsNothing);
      expect(
        launchedUris,
        [Uri.parse(expectedAppStoreUrl), Uri.parse(expectedPlayStoreUrl)],
      );
    });
  });

  group('Sauki Go 7-Day Startup Modal Cadence', () {
    testWidgets(
        'Auto-shows modal on first launch, suppresses within 7-day cooldown, re-allows after 7 days, and stops once store clicked',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      // 1. First launch (empty prefs) -> modal auto-opens
      SharedPreferences.setMockInitialValues({});
      final promo1 = PromoProvider();
      await tester.pumpWidget(
        buildTestHome(
          localeProvider: LocaleProvider(),
          promoProvider: promo1,
          showStartupPromo: true,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('sauki_promo_modal')), findsOneWidget);

      // Dismiss via "Maybe Later"
      await tester.tap(find.byKey(const ValueKey('sauki_modal_later_button')));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('sauki_promo_modal')), findsNothing);

      final prefsAfterFirst = await SharedPreferences.getInstance();
      expect(prefsAfterFirst.getInt(PromoProvider.prefLastShownMs), isNotNull);

      // 2. Within 7-day cooldown (2 days ago) -> shouldAutoShowModal is false
      final twoDaysAgo = DateTime.now()
          .subtract(const Duration(days: 2))
          .millisecondsSinceEpoch;
      SharedPreferences.setMockInitialValues({
        PromoProvider.prefLastShownMs: twoDaysAgo,
      });
      final promoCooldown = PromoProvider();
      expect(await promoCooldown.shouldAutoShowModal(), isFalse);

      // 3. Past 7-day cooldown (8 days ago) -> shouldAutoShowModal is true
      final eightDaysAgo = DateTime.now()
          .subtract(const Duration(days: 8))
          .millisecondsSinceEpoch;
      SharedPreferences.setMockInitialValues({
        PromoProvider.prefLastShownMs: eightDaysAgo,
      });
      final promoExpiredCooldown = PromoProvider();
      expect(await promoExpiredCooldown.shouldAutoShowModal(), isTrue);

      // 4. Store already clicked (even 30 days ago) -> permanently suppressed on auto-startup
      final thirtyDaysAgo = DateTime.now()
          .subtract(const Duration(days: 30))
          .millisecondsSinceEpoch;
      SharedPreferences.setMockInitialValues({
        PromoProvider.prefLastShownMs: thirtyDaysAgo,
        PromoProvider.prefStoreClicked: true,
      });
      final promoConverted = PromoProvider();
      expect(await promoConverted.shouldAutoShowModal(), isFalse);
    });
  });

  group('Bilingual English/Hausa, Compact Screen & Config Sync', () {
    testWidgets(
        'Switches Sauki Go card and modal copy cleanly to Hausa and renders overflow-free on compact 360x640 screen',
        (WidgetTester tester) async {
      // Compact 360x640 viewport check
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final localeProvider = LocaleProvider();
      final promoProvider = PromoProvider();

      await tester.pumpWidget(
        buildTestHome(
          localeProvider: localeProvider,
          promoProvider: promoProvider,
          showStartupPromo: false,
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      // Switch to Hausa
      await tester.tap(find.text('Harshen Hausa'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      // "Get Data" text remains visible in header pill
      expect(find.text('Get Data'), findsOneWidget);

      // Scroll compact 640px viewport down to SaukiPromoHomeCard and verify zero overflow
      await tester.scrollUntilVisible(
        find.byKey(const ValueKey('sauki_promo_home_card')),
        180,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      // Hausa copy on inline card
      expect(
        find.text('Samu data da katin waya mai sauƙi daga amintacciyar manhajarmu'),
        findsOneWidget,
      );
      expect(find.text('Duka na Wata-Wata'), findsOneWidget);
      expect(find.text('NA IPHONE'), findsOneWidget);
      expect(find.text('NA ANDROID'), findsOneWidget);

      // Open modal on compact screen in Hausa -> zero overflow
      await tester.tap(find.byKey(const ValueKey('header_get_data_button')));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      expect(find.text('AMINTACCIYAR MANHAJA • SAUKI GO'), findsOneWidget);
      expect(find.text('NA IPHONE • SAUKE A'), findsOneWidget);
      expect(find.text('NA ANDROID • SAUKE A'), findsOneWidget);
      expect(find.text('Ba Yanzu Ba'), findsOneWidget);

      // Close modal via top-right close button
      await tester.tap(find.byKey(const ValueKey('sauki_modal_close_button')));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('sauki_promo_modal')), findsNothing);
    });

    test('SaukiPromoConfig.fromMap maps Admin Panel cycleEn/cycleHa and respects kill-switch',
        () {
      final parsed = SaukiPromoConfig.fromMap({
        'enabled': false,
        'modalEnabled': false,
        'cooldownDays': '14',
        'appName': 'Sauki Go',
        'cycleEn': 'Monthly Plans',
        'cycleHa': 'Tsarin Wata',
        'plan1Data': '2GB',
        'plan1Price': '₦750',
      });

      expect(parsed.enabled, isFalse);
      expect(parsed.modalEnabled, isFalse);
      expect(parsed.cooldownDays, equals(14));
      expect(parsed.monthlyTagEn, equals('Monthly Plans'));
      expect(parsed.monthlyTagHa, equals('Tsarin Wata'));
      expect(parsed.plan1Data, equals('2GB'));
      expect(parsed.plan1Price, equals('₦750'));
      expect(parsed.appStoreUrl, equals(expectedAppStoreUrl));
      expect(parsed.playStoreUrl, equals(expectedPlayStoreUrl));
    });
  });
}
