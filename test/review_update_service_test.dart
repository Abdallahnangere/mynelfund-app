import 'package:flutter_test/flutter_test.dart';
import 'package:my_nelfund/core/services/review_service.dart';
import 'package:my_nelfund/core/services/update_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('ReviewService Tests', () {
    test('Package name and Store URLs match com.mynelfund.app', () {
      expect(ReviewService.androidPackageName, 'com.mynelfund.app');
      expect(
        ReviewService.playStoreWebUrl,
        'https://play.google.com/store/apps/details?id=com.mynelfund.app',
      );
      expect(
        ReviewService.playStoreMarketUrl,
        'market://details?id=com.mynelfund.app',
      );
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

  group('UpdateService Tests', () {
    test('Package configuration and version properties', () {
      expect(UpdateService.packageName, 'com.mynelfund.app');
      expect(UpdateService.appVersion, '1.0.0');
      expect(UpdateService.appBuildNumber, 1);
      expect(
        UpdateService.playStoreUrl,
        'https://play.google.com/store/apps/details?id=com.mynelfund.app',
      );
    });
  });
}
