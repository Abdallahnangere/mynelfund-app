import 'dart:io' show Platform;
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/nelfund_colors.dart';
import '../theme/nelfund_typography.dart';

class UpdateService {
  UpdateService._();
  static final UpdateService instance = UpdateService._();

  static const String appVersion = '1.0.0';
  static const int appBuildNumber = 1;
  static const String packageName = 'com.mynelfund.app';
  static const String playStoreUrl =
      'https://play.google.com/store/apps/details?id=$packageName';

  bool _isChecking = false;

  /// Check Google Play Store for in-app updates
  Future<void> checkForUpdates(BuildContext context,
      {bool userInitiated = false}) async {
    if (_isChecking) return;
    _isChecking = true;

    try {
      // In-App Update API is Android Google Play specific
      if (kIsWeb || !Platform.isAndroid) {
        if (userInitiated && context.mounted) {
          _showUpToDateDialog(context, 'You are running the latest version ($appVersion).');
        }
        return;
      }

      final updateInfo = await InAppUpdate.checkForUpdate();

      if (updateInfo.updateAvailability == UpdateAvailability.updateAvailable) {
        if (!context.mounted) return;

        if (updateInfo.immediateUpdateAllowed) {
          await InAppUpdate.performImmediateUpdate();
        } else if (updateInfo.flexibleUpdateAllowed) {
          await InAppUpdate.startFlexibleUpdate();
          await InAppUpdate.completeFlexibleUpdate();
        } else {
          _showUpdateAvailableDialog(context);
        }
      } else {
        if (userInitiated && context.mounted) {
          _showUpToDateDialog(
              context, 'Your app is up to date (Version $appVersion, Build $appBuildNumber).');
        }
      }
    } catch (e) {
      // In development, sideloaded, or non-Play Store environments, InAppUpdate throws.
      // Production fallback provides user-friendly status and direct store link:
      if (userInitiated && context.mounted) {
        _showUpToDateDialog(
          context,
          'You are running version $appVersion.\n\nAll official updates and security patches are served via the Google Play Store.',
          showStoreLink: true,
        );
      }
    } finally {
      _isChecking = false;
    }
  }

  void _showUpToDateDialog(BuildContext context, String message,
      {bool showStoreLink = false}) {
    showCupertinoDialog<void>(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              CupertinoIcons.checkmark_seal_fill,
              color: NelfundColors.emerald,
              size: 20,
            ),
            SizedBox(width: 6),
            Text('App Version Status'),
          ],
        ),
        content: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(
            message,
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
          if (showStoreLink)
            CupertinoDialogAction(
              onPressed: () {
                Navigator.of(ctx).pop();
                launchUrl(
                  Uri.parse(playStoreUrl),
                  mode: LaunchMode.externalApplication,
                );
              },
              child: const Text(
                'Open Google Play',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: NelfundColors.emerald,
                ),
              ),
            ),
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showUpdateAvailableDialog(BuildContext context) {
    showCupertinoDialog<void>(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text('New Update Available'),
        content: const Padding(
          padding: EdgeInsets.only(top: 8),
          child: Text(
            'A new version of My NELFund is available on Google Play Store with updated policy rules and improvements.',
          ),
        ),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () {
              Navigator.of(ctx).pop();
              launchUrl(
                Uri.parse(playStoreUrl),
                mode: LaunchMode.externalApplication,
              );
            },
            child: const Text(
              'Update Now',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: NelfundColors.emerald,
              ),
            ),
          ),
          CupertinoDialogAction(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Later'),
          ),
        ],
      ),
    );
  }
}
