import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/nelfund_colors.dart';
import '../theme/nelfund_typography.dart';

class ReviewService {
  ReviewService._();
  static final ReviewService instance = ReviewService._();

  static const String androidPackageName = 'com.mynelfund.app';
  static const String playStoreWebUrl =
      'https://play.google.com/store/apps/details?id=$androidPackageName';
  static const String playStoreMarketUrl =
      'market://details?id=$androidPackageName';
  static const String iosAppStoreId = 'com.mynelfund.app';
  static const String iosAppStoreWebUrl =
      'https://apps.apple.com/app/id$iosAppStoreId';

  static bool get isIOS => defaultTargetPlatform == TargetPlatform.iOS;
  static String get storeName => isIOS ? 'App Store' : 'Play Store';
  static String get rateActionLabel =>
      isIOS ? 'Rate on App Store ★★★★★' : 'Rate on Play Store ★★★★★';

  static const String _prefLaunchCount = 'review_launch_count';
  static const String _prefHasRatedOrDeclined = 'review_has_rated_or_declined';
  static const String _prefLastPromptTime = 'review_last_prompt_time';

  final InAppReview _inAppReview = InAppReview.instance;

  /// Increment app launch counter in SharedPreferences
  Future<void> recordAppLaunch() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final current = prefs.getInt(_prefLaunchCount) ?? 0;
      await prefs.setInt(_prefLaunchCount, current + 1);
    } catch (_) {}
  }

  /// Check whether the automated rating prompt should be displayed
  Future<bool> shouldPromptReview() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final hasCompleted = prefs.getBool(_prefHasRatedOrDeclined) ?? false;
      if (hasCompleted) return false;

      final count = prefs.getInt(_prefLaunchCount) ?? 0;
      if (count < 3) return false;

      final lastPrompt = prefs.getInt(_prefLastPromptTime) ?? 0;
      final now = DateTime.now().millisecondsSinceEpoch;
      // At least 4 days between prompts if postponed
      if (now - lastPrompt < const Duration(days: 4).inMilliseconds) {
        return false;
      }

      return true;
    } catch (_) {
      return false;
    }
  }

  /// Mark that the user has reviewed or permanently dismissed
  Future<void> setHasRatedOrDeclined(bool value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_prefHasRatedOrDeclined, value);
    } catch (_) {}
  }

  /// Postpone prompt reminder
  Future<void> postponePrompt() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(
          _prefLastPromptTime, DateTime.now().millisecondsSinceEpoch);
    } catch (_) {}
  }

  /// Trigger the official in-app review popup or fallback to store listing
  Future<void> requestReviewOrOpenStore() async {
    try {
      if (await _inAppReview.isAvailable()) {
        await _inAppReview.requestReview();
      } else {
        await openStoreListing();
      }
    } catch (_) {
      await openStoreListing();
    }
  }

  /// Direct deep link to Google Play Store / Apple App Store listing
  Future<void> openStoreListing() async {
    try {
      if (await _inAppReview.isAvailable()) {
        await _inAppReview.openStoreListing(appStoreId: iosAppStoreId);
        return;
      }
    } catch (_) {}

    // Fallback: direct intent / browser URL based on platform
    if (isIOS) {
      try {
        final Uri appStoreUri = Uri.parse(iosAppStoreWebUrl);
        if (await canLaunchUrl(appStoreUri)) {
          await launchUrl(appStoreUri, mode: LaunchMode.externalApplication);
          return;
        }
      } catch (_) {}
    } else {
      try {
        final Uri marketUri = Uri.parse(playStoreMarketUrl);
        if (await canLaunchUrl(marketUri)) {
          await launchUrl(marketUri, mode: LaunchMode.externalApplication);
          return;
        }
      } catch (_) {}

      final Uri webUri = Uri.parse(playStoreWebUrl);
      await launchUrl(webUri, mode: LaunchMode.externalApplication);
    }
  }

  /// Beautiful Cupertino In-App Rating Dialog
  Future<void> showRatingDialog(BuildContext context) async {
    await postponePrompt();

    if (!context.mounted) return;

    await showCupertinoDialog<void>(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              CupertinoIcons.star_fill,
              color: Color(0xFFFFB800),
              size: 20,
            ),
            const SizedBox(width: 6),
            const Text('Enjoying My NELFund?'),
          ],
        ),
        content: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(
            'Your 5-star review helps thousands of Nigerian students discover and navigate the student loan scheme with zero stress!',
            style: NelfundTypography.footnote.copyWith(
              color: CupertinoDynamicColor.resolve(
                NelfundColors.secondaryLabel,
                ctx,
              ),
              height: 1.35,
            ),
          ),
        ),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () async {
              Navigator.of(ctx).pop();
              await setHasRatedOrDeclined(true);
              await requestReviewOrOpenStore();
            },
            child: Text(
              rateActionLabel,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: NelfundColors.emerald,
              ),
            ),
          ),
          CupertinoDialogAction(
            onPressed: () async {
              Navigator.of(ctx).pop();
              await postponePrompt();
            },
            child: const Text('Remind Me Later'),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () async {
              Navigator.of(ctx).pop();
              await setHasRatedOrDeclined(true);
            },
            child: const Text("Don't Ask Again"),
          ),
        ],
      ),
    );
  }
}
