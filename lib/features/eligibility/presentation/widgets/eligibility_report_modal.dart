import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/localization/app_locale.dart';
import '../../../../core/localization/app_translations.dart';
import '../../../../core/theme/nelfund_colors.dart';
import '../../domain/eligibility_model.dart';

/// Launches the official NELFUND portal and shows a localized fallback notice
/// dialog if the device browser cannot open the link.
Future<void> launchNelfundPortal(BuildContext context) async {
  final uri = Uri.parse('https://nelf.gov.ng');
  try {
    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched && context.mounted) {
      _showPortalFallbackDialog(context);
    }
  } catch (_) {
    if (context.mounted) {
      _showPortalFallbackDialog(context);
    }
  }
}

void _showPortalFallbackDialog(BuildContext context) {
  final tr = AppTranslations.of(context);
  showCupertinoDialog<void>(
    context: context,
    builder: (ctx) => CupertinoAlertDialog(
      title: Text(tr.isHausa ? 'Shafin NELFUND' : 'NELFUND Official Portal'),
      content: Text(
        tr.isHausa
            ? 'Da fatan za a ziyarci https://nelf.gov.ng ta hanyar burauzar wayarka domin shigar da takardu.'
            : 'Please visit https://nelf.gov.ng in your browser to continue your application.',
      ),
      actions: [
        CupertinoDialogAction(
          isDefaultAction: true,
          onPressed: () => Navigator.of(ctx).pop(),
          child: Text(tr.buttonOk),
        ),
      ],
    ),
  );
}

/// Presents a comprehensive diagnostic summary [CupertinoAlertDialog] for the
/// student's selected eligibility inputs.
Future<void> showEligibilityReportModal(
  BuildContext context,
  EligibilityReport report,
  AppLanguage lang,
) {
  final isHa = lang == AppLanguage.hausa;
  final isEligible = report.isLikelyEligible;
  final hasDisqualifiers = report.hasDisqualifiers;
  final Color statusColor = isEligible
      ? NelfundColors.emerald
      : (hasDisqualifiers
            ? CupertinoColors.systemRed
            : CupertinoColors.systemOrange);

  return showCupertinoDialog<void>(
    context: context,
    builder: (dialogContext) {
      return CupertinoAlertDialog(
        title: Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Column(
            children: [
              Icon(
                isEligible
                    ? CupertinoIcons.checkmark_seal_fill
                    : (hasDisqualifiers
                          ? CupertinoIcons.xmark_octagon_fill
                          : CupertinoIcons.exclamationmark_triangle_fill),
                size: 42,
                color: statusColor,
              ),
              const SizedBox(height: 8),
              Text(
                isEligible
                    ? (isHa
                          ? 'Sharuddan Doka Sun Cika'
                          : 'Statutory Criteria Satisfied')
                    : (hasDisqualifiers
                          ? (isHa
                                ? 'Shingen Doka Ya Hana Cancanta'
                                : 'Statutory Disqualification')
                          : (isHa
                                ? 'Bayanai Ba Su Kammala Ba'
                                : 'Incomplete Requirements')),
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                report.summaryMessage,
                style: const TextStyle(fontSize: 13, height: 1.35),
              ),
              const SizedBox(height: 12),
              Text(
                isHa
                    ? '1. Muhimman Sharudda (${report.coreMetCount}/${report.coreTotalCount} Sun Cika)'
                    : '1. Core Criteria (${report.coreMetCount}/${report.coreTotalCount} Met)',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 12.5,
                ),
              ),
              const SizedBox(height: 4),
              if (report.pendingCoreCriteria.isEmpty)
                Text(
                  isHa
                      ? '✓ Dukkan muhimman sharuddan doka an tabbatar da su.'
                      : '✓ All statutory core criteria confirmed.',
                  style: const TextStyle(
                    color: NelfundColors.emerald,
                    fontSize: 12,
                  ),
                )
              else
                ...report.pendingCoreCriteria.map(
                  (p) => _DialogBulletRow(
                    prefix: '! ',
                    text: p,
                    color: CupertinoColors.systemOrange,
                  ),
                ),
              const SizedBox(height: 10),
              Text(
                isHa
                    ? '2. Shirye-shiryen KYC (${report.kycMetCount}/${report.kycTotalCount} A Shirye)'
                    : '2. KYC Readiness (${report.kycMetCount}/${report.kycTotalCount} Ready)',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 12.5,
                ),
              ),
              const SizedBox(height: 4),
              if (report.pendingKycItems.isEmpty)
                Text(
                  isHa
                      ? '✓ Dukkan takardun KYC na wajibi an tabbatar da su.'
                      : '✓ All mandatory KYC documents verified.',
                  style: const TextStyle(
                    color: NelfundColors.emerald,
                    fontSize: 12,
                  ),
                )
              else
                ...report.pendingKycItems.map(
                  (k) => _DialogBulletRow(
                    prefix: '• ',
                    text: k,
                    color: CupertinoColors.systemOrange,
                  ),
                ),
              const SizedBox(height: 10),
              Text(
                isHa
                    ? '3. Shingen Doka Masu Hana Bashi'
                    : '3. Disqualification Bars',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 12.5,
                ),
              ),
              const SizedBox(height: 4),
              if (!hasDisqualifiers)
                Text(
                  isHa
                      ? '✓ Tarihi Mai Kyau: Babu wani shingen doka da ya shafe ka.'
                      : '✓ Clean Record: 0 active disqualification bars.',
                  style: const TextStyle(
                    color: NelfundColors.emerald,
                    fontSize: 12,
                  ),
                )
              else
                ...report.activeDisqualifiers.map(
                  (reason) => _DialogBulletRow(
                    prefix: '✕ ',
                    text: reason,
                    color: CupertinoColors.systemRed,
                    tintText: true,
                  ),
                ),
            ],
          ),
        ),
        actions: [
          if (isEligible)
            CupertinoDialogAction(
              isDefaultAction: true,
              onPressed: () {
                Navigator.of(dialogContext).pop();
                unawaited(launchNelfundPortal(context));
              },
              child: Text(
                isHa
                    ? 'Bude Shafin Hukumar NELFUND (nelf.gov.ng)'
                    : 'Proceed to Portal (nelf.gov.ng)',
                style: const TextStyle(
                  color: NelfundColors.emerald,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          CupertinoDialogAction(
            isDestructiveAction: !isEligible,
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(
              isEligible
                  ? (isHa ? 'Rufe' : 'Close')
                  : (isHa
                        ? 'Duba Jerin Abubuwan da Ake Bukata'
                        : 'Review Checklist'),
            ),
          ),
        ],
      );
    },
  );
}

class _DialogBulletRow extends StatelessWidget {
  const _DialogBulletRow({
    required this.prefix,
    required this.text,
    required this.color,
    this.tintText = false,
  });

  final String prefix;
  final String text;
  final Color color;
  final bool tintText;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            prefix,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: tintText ? color : null,
                fontSize: 11.5,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
