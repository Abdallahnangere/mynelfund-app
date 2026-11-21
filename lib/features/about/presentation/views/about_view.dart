import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../app/app.dart';
import '../../../../core/localization/app_translations.dart';
import '../../../../core/localization/locale_provider.dart';
import '../../../../core/services/analytics_service.dart';
import '../../../../core/theme/nelfund_colors.dart';
import '../../../../shared/widgets/liquid_glass_header.dart';
import '../widgets/about_footer.dart';
import '../widgets/app_management_card.dart';
import '../widgets/clarification_notice_card.dart';
import '../widgets/developer_contact_card.dart';
import '../widgets/developer_profile_card.dart';
import '../widgets/digital_solutions_cta_card.dart';
import '../widgets/language_preference_card.dart';
import '../widgets/official_channels_card.dart';

/// System information, bilingual settings, official NELFUND channels, and
/// independent student developer attribution screen.
class AboutView extends StatelessWidget {
  /// Creates an [AboutView].
  const AboutView({super.key});

  @override
  Widget build(BuildContext context) {
    return AppProviders.ensure<LocaleProvider>(
      context,
      create: LocaleProvider.new,
      child: const _AboutViewContent(),
    );
  }
}

class _AboutViewContent extends StatelessWidget {
  const _AboutViewContent();

  static const String directCallNumber = '08164135836';
  static const String _whatsappRawNumber = '09076872520';
  static const String _nelfundWebsiteUrl = 'https://nelf.gov.ng';
  static const String _nelfundEmail = 'info@nelf.gov.ng';

  Future<void> _launch(BuildContext context, String url) async {
    final tr = AppTranslations.of(context);
    final uri = Uri.tryParse(url);
    if (uri == null) {
      return;
    }

    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched && context.mounted) {
        _showNoticeDialog(
          context,
          tr.isHausa
              ? 'Ba a iya buɗe wannan hanyar haɗi a na’urarka ba.'
              : 'Could not launch this external link on your device.',
        );
      }
    } catch (_) {
      if (context.mounted) {
        _showNoticeDialog(
          context,
          tr.isHausa
              ? 'An sami matsala wajen buɗe wannan shafi.'
              : 'Unable to open this destination at the moment.',
        );
      }
    }
  }

  void _openWhatsApp(BuildContext context, bool isHausa, String analyticsTag) {
    unawaited(
      AnalyticsService.instance.logDeveloperContact(method: analyticsTag),
    );
    final message = isHausa
        ? Uri.encodeComponent(
            'Salam Abdullahi, ina tuntuɓarka ne daga manhajar My NELFund.',
          )
        : Uri.encodeComponent(
            'Hello Abdullahi, I am reaching out from the My NELFund app.',
          );
    final intlPhone = _whatsappRawNumber.startsWith('0')
        ? '234${_whatsappRawNumber.substring(1)}'
        : _whatsappRawNumber;
    unawaited(_launch(context, 'https://wa.me/$intlPhone?text=$message'));
  }

  void _copyToClipboard(BuildContext context, String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    HapticFeedback.lightImpact();
    final tr = AppTranslations.of(context);
    _showNoticeDialog(
      context,
      tr.isHausa ? 'An kwafi $label ($text).' : '$label copied to clipboard.',
    );
  }

  void _showNoticeDialog(BuildContext context, String message) {
    final tr = AppTranslations.of(context);
    showCupertinoDialog<void>(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: Text(tr.isHausa ? 'Sanarwa' : 'Notice'),
        content: Text(message),
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

  @override
  Widget build(BuildContext context) {
    final localeProv = context.watch<LocaleProvider>();
    final tr = AppTranslations.from(localeProv.currentLanguage);

    return CupertinoPageScaffold(
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            LiquidGlassHeader(
              title: tr.aboutHeaderTitle,
              subtitle: tr.isHausa
                  ? 'Bayanai Game da Manhaja da Mai Haɓaka'
                  : 'System Info, Language & Developer Contact',
              leading: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: NelfundColors.emerald.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  CupertinoIcons.person_crop_circle_fill,
                  color: NelfundColors.emerald,
                  size: 22,
                ),
              ),
            ),
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.fromLTRB(0, 12, 0, 88),
                children: [
                  LanguagePreferenceCard(localeProvider: localeProv, tr: tr),
                  const SizedBox(height: 16),
                  DeveloperProfileCard(tr: tr),
                  const SizedBox(height: 16),
                  DigitalSolutionsCtaCard(
                    tr: tr,
                    onWhatsAppTap: () => _openWhatsApp(
                      context,
                      tr.isHausa,
                      'whatsapp_digital_solutions',
                    ),
                  ),
                  const SizedBox(height: 16),
                  DeveloperContactCard(
                    tr: tr,
                    directCallNumber: directCallNumber,
                    nelfundEmail: _nelfundEmail,
                    onOfficialEmailTap: () => unawaited(
                      _launch(
                        context,
                        'mailto:$_nelfundEmail?subject=${Uri.encodeComponent('NELFUND Student Loan Enquiry')}',
                      ),
                    ),
                    onDirectCallTap: () =>
                        unawaited(_launch(context, 'tel:$directCallNumber')),
                    onCopyNumberTap: () => _copyToClipboard(
                      context,
                      directCallNumber,
                      tr.isHausa ? 'Lambar Waya' : 'Phone Number',
                    ),
                    onWhatsAppTap: () =>
                        _openWhatsApp(context, tr.isHausa, 'whatsapp_support'),
                  ),
                  const SizedBox(height: 16),
                  ClarificationNoticeCard(tr: tr),
                  const SizedBox(height: 16),
                  OfficialChannelsCard(
                    tr: tr,
                    nelfundEmail: _nelfundEmail,
                    onOpenPortalTap: () =>
                        unawaited(_launch(context, _nelfundWebsiteUrl)),
                    onSendEmailTap: () =>
                        unawaited(_launch(context, 'mailto:$_nelfundEmail')),
                  ),
                  const SizedBox(height: 16),
                  AppManagementCard(tr: tr),
                  const SizedBox(height: 24),
                  AboutFooter(tr: tr),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
