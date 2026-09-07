import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_nelfund/core/services/review_service.dart';
import 'package:my_nelfund/core/services/update_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    debugDefaultTargetPlatformOverride = null;
  });

  tearDown(() {
    debugDefaultTargetPlatformOverride = null;
  });

  group('ReviewService Platform Tests', () {
    test('Package name and Store URLs match com.mynelfund.app', () {
      expect(ReviewService.androidPackageName, 'com.mynelfund.app');
      expect(ReviewService.iosAppStoreId, 'com.mynelfund.app');
      expect(
        ReviewService.playStoreWebUrl,
        'https://play.google.com/store/apps/details?id=com.mynelfund.app',
      );
      expect(
        ReviewService.playStoreMarketUrl,
        'market://details?id=com.mynelfund.app',
      );
      expect(
        ReviewService.iosAppStoreWebUrl,
        'https://apps.apple.com/app/idcom.mynelfund.app',
      );
    });

    test('iOS dynamically displays App Store labels and URLs', () {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      expect(ReviewService.isIOS, isTrue);
      expect(ReviewService.storeName, 'App Store');
      expect(ReviewService.rateActionLabel, 'Rate on App Store ★★★★★');
    });

    test('Android dynamically displays Play Store labels and URLs', () {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      expect(ReviewService.isIOS, isFalse);
      expect(ReviewService.storeName, 'Play Store');
      expect(ReviewService.rateActionLabel, 'Rate on Play Store ★★★★★');
    });

    test('App launch counter increments correctly and triggers review prompt at threshold',
        () async {
      final review = ReviewService.instance;

      expect(await review.shouldPromptReview(), isFalse);

      await review.recordAppLaunch(); // 1
      expect(await review.shouldPromptReview(), isFalse);

      await review.recordAppLaunch(); // 2
      expect(await review.shouldPromptReview(), isFalse);

      await review.recordAppLaunch(); // 3
      expect(await review.shouldPromptReview(), isTrue);

      // Once user rates or declines, shouldPromptReview becomes false
      await review.setHasRatedOrDeclined(true);
      expect(await review.shouldPromptReview(), isFalse);
    });
  });

  group('UpdateService Platform Tests', () {
    test('Package configuration and version properties', () {
      expect(UpdateService.packageName, 'com.mynelfund.app');
      expect(UpdateService.appVersion, '1.0.0');
      expect(UpdateService.appBuildNumber, 1);
      expect(
        UpdateService.playStoreUrl,
        'https://play.google.com/store/apps/details?id=com.mynelfund.app',
      );
      expect(
        UpdateService.appStoreUrl,
        'https://apps.apple.com/app/com.mynelfund.app',
      );
    });

    test('iOS dynamically resolves Apple App Store metadata', () {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      expect(UpdateService.isIOS, isTrue);
      expect(UpdateService.storeName, 'App Store');
      expect(UpdateService.storeFullName, 'Apple App Store');
      expect(
        UpdateService.currentStoreUrl,
        'https://apps.apple.com/app/com.mynelfund.app',
      );
    });

    test('Android dynamically resolves Google Play Store metadata', () {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      expect(UpdateService.isIOS, isFalse);
      expect(UpdateService.storeName, 'Play Store');
      expect(UpdateService.storeFullName, 'Google Play Store');
      expect(
        UpdateService.currentStoreUrl,
        'https://play.google.com/store/apps/details?id=com.mynelfund.app',
      );
    });
  });
}
