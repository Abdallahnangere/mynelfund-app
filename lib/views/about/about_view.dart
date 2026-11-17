import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/localization/app_locale.dart';
import '../../core/localization/app_translations.dart';
import '../../core/localization/locale_provider.dart';
import '../../core/services/analytics_service.dart';
import '../../core/services/review_service.dart';
import '../../core/services/update_service.dart';
import '../../core/theme/nelfund_colors.dart';
import '../../core/theme/nelfund_typography.dart';
import '../../widgets/apple_frosted_card.dart';
import '../../widgets/liquid_glass_header.dart';

class AboutView extends StatelessWidget {
  const AboutView({super.key});

  @override
  Widget build(BuildContext context) {
    LocaleProvider? localeProv;
    try {
      localeProv = Provider.of<LocaleProvider?>(context, listen: false);
    } catch (_) {}

    const content = _AboutViewContent();
    if (localeProv == null) {
      return ChangeNotifierProvider(
        create: (_) => LocaleProvider(),
        child: content,
      );
    }
    return content;
  }
}

class _AboutViewContent extends StatefulWidget {
  const _AboutViewContent();

  @override
  State<_AboutViewContent> createState() => _AboutViewContentState();
}

class _AboutViewContentState extends State<_AboutViewContent> {
  static const String directCallNumber = '08164135836';
  static const String whatsappRawNumber = '09076872520';
  static const String nelfundWebsiteUrl = 'https://nelf.gov.ng';
  static const String nelfundEmail = 'info@nelf.gov.ng';

  Future<void> _launch(BuildContext context, String urlString) async {
    final isTel = urlString.startsWith('tel:');
    final isWa = urlString.contains('wa.me');
    final isMail = urlString.startsWith('mailto:');
    final isAnjal = urlString.contains('anjalsolutionsltd');
    final isNelfund = urlString.contains('nelf.gov.ng');

    if (isTel) {
      AnalyticsService.instance.logDeveloperContact(method: 'call_phone');
    } else if (isWa) {
      AnalyticsService.instance.logDeveloperContact(method: 'whatsapp');
    } else if (isMail) {
      AnalyticsService.instance.logDeveloperContact(method: 'email_nelfund');
    } else {
      AnalyticsService.instance.logExternalLink(
        destination: isAnjal
            ? 'Anjal Solutions Website'
            : (isNelfund ? 'NELFUND Official' : 'External Link'),
        url: urlString,
      );
    }

    final uri = Uri.parse(urlString);
    try {
      final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched && context.mounted) {
        _showErrorDialog(context, 'Could not open: $urlString');
      }
    } catch (_) {
      if (context.mounted) {
        _showErrorDialog(context, 'Unable to open link. Please verify your connection.');
      }
    }
  }

  void _openWhatsApp(BuildContext context, bool isHausa) {
    final message = isHausa
        ? Uri.encodeComponent('Salam Abdullahi, ina tuntuɓar ka ne daga manhajar My NELFund.')
        : Uri.encodeComponent('Hello Abdullahi, I\'m reaching out from the My NELFund App.');
    final intlPhone = whatsappRawNumber.startsWith('0')
        ? '234${whatsappRawNumber.substring(1)}'
        : whatsappRawNumber;
    final url = 'https://wa.me/$intlPhone?text=$message';
    _launch(context, url);
  }

  void _copyToClipboard(BuildContext context, String text, String label) {
    AnalyticsService.instance.logDeveloperContact(method: 'copy_$label');
    Clipboard.setData(ClipboardData(text: text));
    final tr = AppTranslations.of(context);
    showCupertinoDialog<void>(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: Text(tr.isHausa ? 'An Kwafi' : 'Copied to Clipboard'),
        content: Text(
          tr.isHausa
              ? 'An kwafi $label ($text) zuwa allon kwafi.'
              : '$label ($text) has been copied.',
        ),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(tr.isHausa ? 'Toh' : 'OK'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(BuildContext context, String message) {
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
            child: Text(tr.isHausa ? 'Toh' : 'OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tr = AppTranslations.of(context);

    return CupertinoPageScaffold(
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildFintechHeader(context, tr),
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.fromLTRB(0, 12, 0, 88),
                children: [
                  _buildLanguageSwitcherCard(context, tr),
                  const SizedBox(height: 16),
                  _buildDeveloperProfileCard(context, tr),
                  const SizedBox(height: 16),
                  _buildDigitalSolutionsCtaCard(context, tr),
                  const SizedBox(height: 16),
                  _buildDeveloperContactCard(context, tr),
                  const SizedBox(height: 16),
                  _buildClarificationNoticeCard(context, tr),
                  const SizedBox(height: 16),
                  _buildOfficialNelfundChannelsCard(context, tr),
                  const SizedBox(height: 16),
                  _buildAppManagementCard(context, tr),
                  const SizedBox(height: 24),
                  _buildFooter(context, tr),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFintechHeader(BuildContext context, AppTranslations tr) {
    return LiquidGlassHeader(
      title: tr.aboutHeaderTitle,
      subtitle: tr.isHausa ? 'Bayanai Game da Manhaja da Mai Haɓaka' : 'System Info, Language & Developer Contact',
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
    );
  }

  Widget _buildLanguageSwitcherCard(BuildContext context, AppTranslations tr) {
    final localeProv = context.watch<LocaleProvider>();
    final currentLang = localeProv.currentLanguage;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: AppleFrostedCard(
        margin: EdgeInsets.zero,
        borderColor: NelfundColors.emerald.withValues(alpha: 0.35),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: NelfundColors.emerald.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    CupertinoIcons.globe,
                    size: 18,
                    color: NelfundColors.emerald,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tr.languageCardTitle,
                        style: NelfundTypography.headline.copyWith(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        tr.languageCardDesc,
                        style: NelfundTypography.caption.copyWith(
                          color: CupertinoDynamicColor.resolve(
                            NelfundColors.secondaryLabel,
                            context,
                          ),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => localeProv.setLanguage(AppLanguage.english),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                      decoration: BoxDecoration(
                        color: currentLang == AppLanguage.english
                            ? NelfundColors.emerald.withValues(alpha: 0.15)
                            : CupertinoDynamicColor.resolve(
                                CupertinoColors.systemGrey6,
                                context,
                              ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: currentLang == AppLanguage.english
                              ? NelfundColors.emerald
                              : CupertinoColors.transparent,
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('🇬🇧', style: TextStyle(fontSize: 18)),
                          const SizedBox(width: 8),
                          Text(
                            'English',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: currentLang == AppLanguage.english
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                              color: currentLang == AppLanguage.english
                                  ? NelfundColors.emerald
                                  : CupertinoDynamicColor.resolve(
                                      NelfundColors.label,
                                      context,
                                    ),
                            ),
                          ),
                          if (currentLang == AppLanguage.english) ...[
                            const SizedBox(width: 6),
                            const Icon(
                              CupertinoIcons.checkmark_alt_circle_fill,
                              color: NelfundColors.emerald,
                              size: 16,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: GestureDetector(
                    onTap: () => localeProv.setLanguage(AppLanguage.hausa),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                      decoration: BoxDecoration(
                        color: currentLang == AppLanguage.hausa
                            ? NelfundColors.emerald.withValues(alpha: 0.15)
                            : CupertinoDynamicColor.resolve(
                                CupertinoColors.systemGrey6,
                                context,
                              ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: currentLang == AppLanguage.hausa
                              ? NelfundColors.emerald
                              : CupertinoColors.transparent,
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('🇳🇬', style: TextStyle(fontSize: 18)),
                          const SizedBox(width: 8),
                          Text(
                            'Hausa',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: currentLang == AppLanguage.hausa
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                              color: currentLang == AppLanguage.hausa
                                  ? NelfundColors.emerald
                                  : CupertinoDynamicColor.resolve(
                                      NelfundColors.label,
                                      context,
                                    ),
                            ),
                          ),
                          if (currentLang == AppLanguage.hausa) ...[
                            const SizedBox(width: 6),
                            const Icon(
                              CupertinoIcons.checkmark_alt_circle_fill,
                              color: NelfundColors.emerald,
                              size: 16,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeveloperProfileCard(BuildContext context, AppTranslations tr) {
    final isHa = tr.isHausa;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: AppleFrostedCard(
        margin: EdgeInsets.zero,
        borderColor: NelfundColors.emerald.withValues(alpha: 0.35),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
              decoration: BoxDecoration(
                color: NelfundColors.emerald.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: NelfundColors.emerald.withValues(alpha: 0.25),
                  width: 0.8,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    CupertinoIcons.person_badge_plus_fill,
                    size: 13,
                    color: NelfundColors.emerald,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    tr.developerBadge,
                    style: NelfundTypography.captionBold.copyWith(
                      color: NelfundColors.emerald,
                      fontSize: 11,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Text(
              tr.developerIntro,
              style: NelfundTypography.footnote.copyWith(
                color: CupertinoDynamicColor.resolve(
                  NelfundColors.secondaryLabel,
                  context,
                ),
                fontSize: 13,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 14),

            // Profile Identity Row
            Row(
              children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [NelfundColors.emerald, Color(0xFF68D391)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: NelfundColors.emerald.withValues(alpha: 0.25),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text(
                      'AU',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: CupertinoColors.white,
                        letterSpacing: 1.1,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tr.developerName,
                        style: NelfundTypography.title2.copyWith(
                          fontSize: 17.5,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2.5,
                        ),
                        decoration: BoxDecoration(
                          color: NelfundColors.emerald.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: NelfundColors.emerald.withValues(alpha: 0.3),
                            width: 0.6,
                          ),
                        ),
                        child: Text(
                          tr.developerRole,
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w500,
                            color: CupertinoDynamicColor.resolve(
                              const CupertinoDynamicColor.withBrightness(
                                color: Color(0xFF007A48),
                                darkColor: Color(0xFF68D391),
                              ),
                              context,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Container(
              height: 0.8,
              color: CupertinoDynamicColor.resolve(
                CupertinoColors.systemGrey5,
                context,
              ),
            ),
            const SizedBox(height: 12),

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  CupertinoIcons.book_fill,
                  size: 16,
                  color: NelfundColors.emerald,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    isHa
                        ? 'Ɗalibi mai karatu a aji na 300 a Sashen Nazarin Harkokin Ƙasashen Duniya.'
                        : '300 Level Student of International Studies.',
                    style: NelfundTypography.footnote.copyWith(
                      fontWeight: FontWeight.w500,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  CupertinoIcons.building_2_fill,
                  size: 16,
                  color: NelfundColors.emerald,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    isHa
                        ? 'Jami\'ar Ahmadu Bello (ABU), Zaria.'
                        : 'Ahmadu Bello University (ABU), Zaria.',
                    style: NelfundTypography.footnote.copyWith(
                      fontWeight: FontWeight.w400,
                      fontSize: 13,
                      color: CupertinoDynamicColor.resolve(
                        NelfundColors.secondaryLabel,
                        context,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDigitalSolutionsCtaCard(BuildContext context, AppTranslations tr) {
    final isHa = tr.isHausa;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: AppleFrostedCard(
        margin: EdgeInsets.zero,
        borderColor: NelfundColors.emerald.withValues(alpha: 0.45),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Badge with Sparkles
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
              decoration: BoxDecoration(
                color: NelfundColors.emerald.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: NelfundColors.emerald.withValues(alpha: 0.3),
                  width: 0.8,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    CupertinoIcons.sparkles,
                    size: 13,
                    color: NelfundColors.emerald,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    tr.digitalSolutionsBadge,
                    style: NelfundTypography.captionBold.copyWith(
                      color: NelfundColors.emerald,
                      fontSize: 10.5,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // Headline
            Text(
              tr.digitalSolutionsTitle,
              style: NelfundTypography.title2.copyWith(
                fontSize: 16.5,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.3,
                height: 1.25,
              ),
            ),
            const SizedBox(height: 7),

            // Description Pitch
            Text(
              tr.digitalSolutionsDesc,
              style: NelfundTypography.footnote.copyWith(
                color: CupertinoDynamicColor.resolve(
                  NelfundColors.secondaryLabel,
                  context,
                ),
                fontSize: 12.5,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 12),

            // Capability Tags
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                _buildDigitalPill(context, '📱', tr.digitalSolutionsPill1),
                _buildDigitalPill(context, '⚡', tr.digitalSolutionsPill2),
                _buildDigitalPill(context, '💡', tr.digitalSolutionsPill3),
              ],
            ),
            const SizedBox(height: 14),

            // WhatsApp Direct CTA Button
            SizedBox(
              width: double.infinity,
              child: CupertinoButton(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                color: const Color(0xFF25D366),
                borderRadius: BorderRadius.circular(13),
                minimumSize: Size.zero,
                onPressed: () => _openDigitalSolutionsWhatsApp(context, isHa),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      CupertinoIcons.chat_bubble_2_fill,
                      size: 18,
                      color: CupertinoColors.white,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      tr.digitalSolutionsCtaButton,
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                        color: CupertinoColors.white,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDigitalPill(BuildContext context, String emoji, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
      decoration: BoxDecoration(
        color: CupertinoDynamicColor.resolve(
          CupertinoColors.systemGrey6,
          context,
        ),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: CupertinoDynamicColor.resolve(
            CupertinoColors.systemGrey4,
            context,
          ).withValues(alpha: 0.5),
          width: 0.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 11)),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: CupertinoDynamicColor.resolve(
                NelfundColors.secondaryLabel,
                context,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _openDigitalSolutionsWhatsApp(BuildContext context, bool isHausa) {
    AnalyticsService.instance.logDeveloperContact(method: 'whatsapp_digital_solutions');
    final message = isHausa
        ? Uri.encodeComponent('Salam Abdullahi, na ga aikinka a manhajar My NELFund. Ina son mu tattauna batun gina wata manhaja ko tsarin dijital.')
        : Uri.encodeComponent('Hello Abdullahi, I saw your work on the My NELFund app. I would like to discuss a custom digital solution / software project.');
    final intlPhone = whatsappRawNumber.startsWith('0')
        ? '234${whatsappRawNumber.substring(1)}'
        : whatsappRawNumber;
    final url = 'https://wa.me/$intlPhone?text=$message';
    _launch(context, url);
  }

  Widget _buildDeveloperContactCard(BuildContext context, AppTranslations tr) {
    final isHa = tr.isHausa;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: AppleFrostedCard(
        margin: EdgeInsets.zero,
        borderColor: NelfundColors.emerald.withValues(alpha: 0.35),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  CupertinoIcons.person_crop_circle_badge_checkmark,
                  color: NelfundColors.emerald,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    tr.contactDeveloperTitle,
                    style: NelfundTypography.headline.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              tr.contactDeveloperDesc,
              style: NelfundTypography.footnote.copyWith(
                color: CupertinoDynamicColor.resolve(
                  NelfundColors.secondaryLabel,
                  context,
                ),
                fontSize: 12.5,
              ),
            ),
            const SizedBox(height: 14),

            // Official NELFUND Loan Enquiries Notice & Email Deeplink
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(13),
              decoration: BoxDecoration(
                color: CupertinoDynamicColor.resolve(
                  const CupertinoDynamicColor.withBrightness(
                    color: Color(0xFFF0F5FA),
                    darkColor: Color(0xFF14202C),
                  ),
                  context,
                ),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: CupertinoColors.systemBlue.withValues(alpha: 0.35),
                  width: 1.0,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        CupertinoIcons.info_circle_fill,
                        size: 15,
                        color: CupertinoColors.systemBlue,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          tr.loanInquiryNoticeTitle,
                          style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: CupertinoColors.systemBlue,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    tr.loanInquiryNoticeDesc,
                    style: NelfundTypography.footnote.copyWith(
                      fontSize: 11.5,
                      height: 1.35,
                      color: CupertinoDynamicColor.resolve(
                        NelfundColors.secondaryLabel,
                        context,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: CupertinoButton(
                      padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 12),
                      color: CupertinoColors.systemBlue,
                      borderRadius: BorderRadius.circular(10),
                      minimumSize: Size.zero,
                      onPressed: () => _launch(
                        context,
                        'mailto:$nelfundEmail?subject=${Uri.encodeComponent('NELFUND Student Loan Enquiry')}',
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            CupertinoIcons.mail_solid,
                            size: 14,
                            color: CupertinoColors.white,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${tr.contactOfficialNelfundEmailBtn} ($nelfundEmail)',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: CupertinoColors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // 1. Prominently Revealed Direct Phone Call Card (08164135836)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: CupertinoDynamicColor.resolve(
                  const CupertinoDynamicColor.withBrightness(
                    color: Color(0xFFF0F7F3),
                    darkColor: Color(0xFF152A1C),
                  ),
                  context,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: NelfundColors.emerald.withValues(alpha: 0.35),
                  width: 1.2,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3.5,
                        ),
                        decoration: BoxDecoration(
                          color: NelfundColors.emerald.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              CupertinoIcons.phone_fill,
                              size: 12,
                              color: NelfundColors.emerald,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              isHa ? 'KIRA KAI-TSAYE' : 'DIRECT CALL & SUPPORT',
                              style: const TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.8,
                                color: NelfundColors.emerald,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: CupertinoColors.systemGreen
                              .withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: CupertinoColors.systemGreen,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              isHa ? 'A Buɗe' : 'Available',
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: CupertinoColors.systemGreen,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // Revealed Phone Number in prominent display
                  Text(
                    directCallNumber,
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.2,
                      color: CupertinoDynamicColor.resolve(
                        NelfundColors.label,
                        context,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Action buttons: Call + Copy
                  Row(
                    children: [
                      Expanded(
                        child: CupertinoButton(
                          padding: const EdgeInsets.symmetric(vertical: 11),
                          color: NelfundColors.emerald,
                          borderRadius: BorderRadius.circular(12),
                          minimumSize: Size.zero,
                          onPressed: () =>
                              _launch(context, 'tel:$directCallNumber'),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                CupertinoIcons.phone_fill,
                                size: 15,
                                color: CupertinoColors.white,
                              ),
                              const SizedBox(width: 7),
                              Text(
                                isHa
                                    ? 'Kira: $directCallNumber'
                                    : 'Call: $directCallNumber',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: CupertinoColors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      CupertinoButton(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 11,
                        ),
                        color: CupertinoDynamicColor.resolve(
                          CupertinoColors.systemGrey5,
                          context,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        minimumSize: Size.zero,
                        onPressed: () => _copyToClipboard(
                          context,
                          directCallNumber,
                          isHa ? 'Lambar Waya' : 'Phone Number',
                        ),
                        child: const Icon(
                          CupertinoIcons.doc_on_doc,
                          size: 16,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // 2. WhatsApp Card: 09076872520 Hidden behind WhatsApp Icon
            SizedBox(
              width: double.infinity,
              child: CupertinoButton(
                padding: const EdgeInsets.symmetric(
                  vertical: 13,
                  horizontal: 16,
                ),
                color: const Color(0xFF25D366),
                borderRadius: BorderRadius.circular(14),
                minimumSize: Size.zero,
                onPressed: () => _openWhatsApp(context, isHa),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      CupertinoIcons.chat_bubble_fill,
                      size: 20,
                      color: CupertinoColors.white,
                    ),
                    const SizedBox(width: 9),
                    Text(
                      tr.whatsappButtonLabel,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: CupertinoColors.white,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClarificationNoticeCard(BuildContext context, AppTranslations tr) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: AppleFrostedCard(
        margin: EdgeInsets.zero,
        borderColor: CupertinoColors.systemOrange.withValues(alpha: 0.35),
        backgroundColor: CupertinoDynamicColor.resolve(
          const CupertinoDynamicColor.withBrightness(
            color: Color(0xFFFFFBF0),
            darkColor: Color(0xFF282010),
          ),
          context,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  CupertinoIcons.shield_slash_fill,
                  color: CupertinoColors.systemOrange,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    tr.clarificationTitle,
                    style: NelfundTypography.headline.copyWith(
                      fontSize: 15.5,
                      fontWeight: FontWeight.w600,
                      color: CupertinoColors.systemOrange,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              tr.clarificationBody,
              style: NelfundTypography.footnote.copyWith(
                fontSize: 12.5,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: CupertinoColors.systemOrange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    CupertinoIcons.lock_shield_fill,
                    size: 16,
                    color: CupertinoColors.systemOrange,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      tr.zeroDataCollectionDesc,
                      style: NelfundTypography.captionBold.copyWith(
                        fontSize: 11.5,
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOfficialNelfundChannelsCard(BuildContext context, AppTranslations tr) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: AppleFrostedCard(
        margin: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  CupertinoIcons.building_2_fill,
                  color: NelfundColors.emerald,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    tr.officialChannelsTitle,
                    style: NelfundTypography.headline.copyWith(
                      fontSize: 15.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              tr.officialChannelsDesc,
              style: NelfundTypography.footnote.copyWith(
                color: CupertinoDynamicColor.resolve(
                  NelfundColors.secondaryLabel,
                  context,
                ),
                fontSize: 12.5,
              ),
            ),
            const SizedBox(height: 14),
            _buildOfficialChannelRow(
              context: context,
              icon: CupertinoIcons.globe,
              iconColor: NelfundColors.emerald,
              title: tr.officialPortalTitle,
              subtitle: 'nelf.gov.ng',
              buttonLabel: tr.isHausa ? 'Buɗe Shafin' : 'Open Portal',
              onTap: () => _launch(context, nelfundWebsiteUrl),
            ),
            const SizedBox(height: 10),
            _buildOfficialChannelRow(
              context: context,
              icon: CupertinoIcons.mail_solid,
              iconColor: CupertinoColors.systemBlue,
              title: tr.officialEmailTitle,
              subtitle: nelfundEmail,
              buttonLabel: tr.isHausa ? 'Tura Imel' : 'Send Email',
              onTap: () => _launch(context, 'mailto:$nelfundEmail'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOfficialChannelRow({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String buttonLabel,
    required VoidCallback onTap,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: CupertinoDynamicColor.resolve(
          CupertinoColors.systemGrey6,
          context,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: NelfundTypography.headline.copyWith(fontSize: 13.5),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: NelfundTypography.captionBold.copyWith(
                    color: iconColor,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          CupertinoButton(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            color: iconColor,
            borderRadius: BorderRadius.circular(16),
            minimumSize: Size.zero,
            onPressed: onTap,
            child: Text(
              buttonLabel,
              style: const TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: CupertinoColors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppManagementCard(BuildContext context, AppTranslations tr) {
    final isIOS = defaultTargetPlatform == TargetPlatform.iOS;
    final storeTitle = isIOS ? 'App Store & Community' : 'Play Store & Community';
    final rateButtonLabel = isIOS
        ? (tr.isHausa ? 'Bada Ƙima a App Store' : 'Rate on App Store')
        : (tr.isHausa ? 'Bada Ƙima a Play Store' : 'Rate on Play Store');

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: AppleFrostedCard(
        margin: EdgeInsets.zero,
        borderColor: NelfundColors.emerald.withValues(alpha: 0.3),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  CupertinoIcons.sparkles,
                  color: NelfundColors.emerald,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    storeTitle,
                    style: NelfundTypography.headline.copyWith(
                      fontSize: 15.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => _showVersionHistorySheet(context, tr),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: NelfundColors.emerald.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'v2.2.7+13',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: NelfundColors.emerald,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              tr.isHausa
                  ? 'Taimaka wa sauran ɗaliban Najeriya samun wannan bashi mara ruwa ta hanyar bayar da ƙyakkyawar ƙima ga manhajar, ko duba sabbin sauye-sauye.'
                  : 'Help other Nigerian students discover zero-interest financing by rating the app, or check for the latest official updates.',
              style: NelfundTypography.footnote.copyWith(
                color: CupertinoDynamicColor.resolve(
                  NelfundColors.secondaryLabel,
                  context,
                ),
                fontSize: 12.5,
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: CupertinoButton(
                    padding: const EdgeInsets.symmetric(vertical: 11),
                    color: NelfundColors.emerald,
                    borderRadius: BorderRadius.circular(12),
                    minimumSize: Size.zero,
                    onPressed: () => ReviewService.instance.openStoreListing(),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          CupertinoIcons.star_fill,
                          size: 15,
                          color: Color(0xFFFFD700),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          rateButtonLabel,
                          style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: CupertinoColors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: CupertinoButton(
                    padding: const EdgeInsets.symmetric(vertical: 11),
                    color: CupertinoDynamicColor.resolve(
                      CupertinoColors.systemGrey5,
                      context,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    minimumSize: Size.zero,
                    onPressed: () => UpdateService.instance.checkForUpdates(
                      context,
                      userInitiated: true,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          CupertinoIcons.arrow_clockwise_circle_fill,
                          size: 16,
                          color: CupertinoDynamicColor.resolve(
                            NelfundColors.label,
                            context,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          tr.isHausa ? 'Duba Sabuntawa' : 'Check Update',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: CupertinoDynamicColor.resolve(
                              NelfundColors.label,
                              context,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            CupertinoButton(
              padding: const EdgeInsets.symmetric(vertical: 10),
              color: CupertinoDynamicColor.resolve(
                CupertinoColors.systemGrey6,
                context,
              ),
              borderRadius: BorderRadius.circular(12),
              minimumSize: Size.zero,
              onPressed: () => _showVersionHistorySheet(context, tr),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    CupertinoIcons.doc_text_search,
                    size: 15,
                    color: NelfundColors.emerald,
                  ),
                  const SizedBox(width: 7),
                  Text(
                    tr.isHausa
                        ? 'Duba Tarihin Sabuntawa (Changelog)'
                        : "What's New / Version History",
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w500,
                      color: CupertinoDynamicColor.resolve(
                        NelfundColors.label,
                        context,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Center(
              child: Text(
                'Package: com.mynelfund.app',
                style: TextStyle(
                  fontSize: 11,
                  fontFamily: 'monospace',
                  color: CupertinoDynamicColor.resolve(
                    NelfundColors.tertiaryLabel,
                    context,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter(BuildContext context, AppTranslations tr) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                tr.isHausa ? 'An samar da shi da ' : 'Built with ',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: CupertinoColors.systemGrey,
                ),
              ),
              const Icon(
                CupertinoIcons.heart_fill,
                color: CupertinoColors.systemRed,
                size: 15,
              ),
              Text(
                tr.isHausa ? ' domin Ɗaliban Najeriya' : ' for Nigerian Students',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: CupertinoColors.systemGrey,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '${tr.isHausa ? 'daga' : 'from'} ${tr.developerName}',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: NelfundColors.emerald,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            tr.developerEducation,
            textAlign: TextAlign.center,
            style: NelfundTypography.caption.copyWith(
              color: CupertinoDynamicColor.resolve(
                NelfundColors.tertiaryLabel,
                context,
              ),
              height: 1.35,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            tr.isHausa
                ? 'Siffa ta 2.2.7+13 • Dokar Bashin Ɗalibai domin samar da ilimi mai zurfi ta shekarar 2024'
                : 'Version 2.2.7+13 • Students Loans (Access to Higher Education) Act 2024',
            textAlign: TextAlign.center,
            style: NelfundTypography.caption.copyWith(
              color: CupertinoDynamicColor.resolve(
                NelfundColors.tertiaryLabel,
                context,
              ),
              fontSize: 10.5,
            ),
          ),
        ],
      ),
    );
  }

  void _showVersionHistorySheet(BuildContext context, AppTranslations tr) {
    HapticFeedback.lightImpact();

    showCupertinoModalPopup<void>(
      context: context,
      builder: (sheetCtx) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(sheetCtx).height * 0.86,
          ),
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
          decoration: BoxDecoration(
            color: CupertinoDynamicColor.resolve(
              CupertinoColors.systemBackground,
              sheetCtx,
            ),
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(24),
            ),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Container(
                    width: 38,
                    height: 4.5,
                    decoration: BoxDecoration(
                      color: CupertinoColors.systemGrey4,
                      borderRadius: BorderRadius.circular(2.5),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: NelfundColors.emerald.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        CupertinoIcons.doc_text_search,
                        color: NelfundColors.emerald,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            tr.isHausa ? 'Tarihin Sauye-sauye' : 'Version History',
                            style: NelfundTypography.headline.copyWith(
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            tr.isHausa
                                ? 'Bayanan abubuwan da aka sabunta'
                                : 'Release notes and system updates',
                            style: NelfundTypography.caption.copyWith(
                              color: CupertinoDynamicColor.resolve(
                                NelfundColors.secondaryLabel,
                                sheetCtx,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: NelfundColors.emerald.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'v2.2.7+13',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: NelfundColors.emerald,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Flexible(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildChangelogCard(
                          sheetCtx,
                          tr,
                          version: 'v2.2.7',
                          build: 'Build 13',
                          date: 'Nov 2026',
                          isCurrent: true,
                          title: tr.isHausa
                              ? 'Tsarin Rubutu Mai Kyau & Haɗin Sauki Go'
                              : 'Refined Apple HIG Typography & Sauki Go Integration',
                          highlights: tr.isHausa
                              ? [
                                  'Daidaita kaurin rubutu a duk shafukan manhajar don sauƙin karantawa da tsari mai haske.',
                                  'Sabon katin amintacciyar manhajar Sauki Go don sayen data da katin waya mai rahusa na wata-wata.',
                                  'Gyaran girman allon waya a harshen Hausa da Turanci ba tare da cunkoso ba.',
                                ]
                              : [
                                  'Balanced Apple HIG typography weights across every screen for cleaner, lighter readability.',
                                  'Integrated Sauki Go companion app access for affordable monthly student data & airtime plans.',
                                  'Responsive bilingual layout improvements across compact and large displays.',
                                ],
                        ),
                        const SizedBox(height: 12),
                        _buildChangelogCard(
                          sheetCtx,
                          tr,
                          version: 'v2.2.5',
                          build: 'Build 11',
                          date: 'Oct 2026',
                          isCurrent: false,
                          title: tr.isHausa
                              ? 'Gyaran Bayanan Mai Haɓakawa & Katin Tuntuɓar WhatsApp'
                              : 'Developer Bio Refinement & Custom Digital Solutions CTA',
                          highlights: tr.isHausa
                              ? [
                                  'Sabunta bayanan mai haɓakawa zuwa matsayin ɗalibi a Jami\'ar Ahmadu Bello (ABU), Zaria.',
                                  'Keɓance hanyar tuntuɓar mai haɓakawa don batutuwan manhaja kaɗai, tare da tura tambayoyin lamuni zuwa info@nelf.gov.ng.',
                                  'Sabon katin frosted glass na tuntuɓar WhatsApp don haɓaka manhajoji ko tsarin dijital na kasuwanci da ƙungiyoyi.',
                                ]
                              : [
                                  'Developer profile refined to academic status as an Ahmadu Bello University (ABU) undergraduate.',
                                  'Explicit separation of technical app feedback from official loan support with direct info@nelf.gov.ng deeplink.',
                                  'Bespoke Apple frosted glass CTA card for custom mobile apps, web platforms, and digital solutions via WhatsApp.',
                                ],
                        ),
                        const SizedBox(height: 12),
                        _buildChangelogCard(
                          sheetCtx,
                          tr,
                          version: 'v2.2.4',
                          build: 'Build 9',
                          date: 'Oct 2026',
                          isCurrent: false,
                          title: tr.isHausa
                              ? 'Isar da Sanarwa ta Harshe & Rumbun FAQs Ba Intanet'
                              : 'Targeted Push Routing & Resilient Offline FAQs',
                          highlights: tr.isHausa
                              ? [
                                  'Sanarwar gaggawa ta wayar hannu tana isa da Hausa ko Turanci daidai da zaɓin harshenka.',
                                  'Rumbun tambayoyin hukuma yana aiki 100% koda ba intanet, tare da sabuntawa ta atomatik.',
                                  'Sanarwar sabunta ka’idojin lamuni ta atomatik a wayarka lokacin da aka gyara FAQ.',
                                  'Allon kula da na’urori da rabe-raben masu amfani da Turanci ko Hausa a shafin gudanarwa.',
                                ]
                              : [
                                  'Language-targeted push notifications dispatched via dedicated FCM channels (English and Hausa).',
                                  'Resilient offline FAQ knowledge base with automatic reconnect sync and offline retry action.',
                                  'Automated push notifications triggered on statutory FAQ additions or policy updates.',
                                  'Live device telemetry tracking audience breakdown in the Enterprise Administration Portal.',
                                ],
                        ),
                        const SizedBox(height: 12),
                        _buildChangelogCard(
                          sheetCtx,
                          tr,
                          version: 'v2.2.3',
                          build: 'Build 8',
                          date: 'Oct 2026',
                          isCurrent: false,
                          title: tr.isHausa
                              ? 'Ajiye Bayanan Lamuni & Cikakken Rumbun Firestore'
                              : 'Device Storage Persistence & Full Firestore Sync',
                          highlights: tr.isHausa
                              ? [
                                  'Ajiyar bayanan lissafin lamuni a ma’adanar waya koda an rufe manhaja.',
                                  'Tabbatar da adana dukkan tambayoyin hukuma 19 a Cloud Firestore.',
                                ]
                              : [
                                  'Persistent storage for customized loan calculations and notification inbox across app restarts.',
                                  'Synchronized all 19 statutory FAQs directly with Cloud Firestore.',
                                ],
                        ),
                        const SizedBox(height: 12),
                        _buildChangelogCard(
                          sheetCtx,
                          tr,
                          version: 'v2.2.0',
                          build: 'Build 7',
                          date: 'Oct 2026',
                          isCurrent: false,
                          title: tr.isHausa
                              ? 'Shafin Gudanarwa na Desktop & Sabon Splash na ABU'
                              : 'Enterprise Admin Portal & ABU Splash',
                          highlights: tr.isHausa
                              ? [
                                  'Kaddamar da shafin gudanarwa (Admin Portal) a http://localhost:4040.',
                                  'Sabon shafin maraba mai tambarin ABU Zaria da NELFUND tare da roket mai motsi.',
                                  'Lissafin kudin alawus na kowane wata tare da zabin kwanakin wata.',
                                ]
                              : [
                                  'Web Enterprise Administration Portal for live FAQ management and push bulletin broadcasting.',
                                  'ABU Zaria & NELFUND dual-logo animated splash with rocket flight trajectory.',
                                  'Upkeep month calendar selector and voluntary prepayment configurator.',
                                ],
                        ),
                        const SizedBox(height: 12),
                        _buildChangelogCard(
                          sheetCtx,
                          tr,
                          version: 'v2.1.0',
                          build: 'Build 4',
                          date: 'Sep 2026',
                          isCurrent: false,
                          title: tr.isHausa
                              ? 'Fassarar Cikakken Harshen Hausa'
                              : 'Full Bilingual Hausa Localization',
                          highlights: tr.isHausa
                              ? [
                                  'Cikakken goyon bayan harshen Hausa a dukkan shafuka da bayanai.',
                                  'Maballin sauya harshe cikin sauki a saman babban shafi.',
                                ]
                              : [
                                  'Full bilingual Hausa language support across all 5 core application tabs.',
                                  'Real-time language switch toggle in the Home header.',
                                ],
                        ),
                        const SizedBox(height: 12),
                        _buildChangelogCard(
                          sheetCtx,
                          tr,
                          version: 'v1.0.0',
                          build: 'Build 1',
                          date: 'Sep 2026',
                          isCurrent: false,
                          title: tr.isHausa
                              ? 'Kaddamarwar Farko ta Manhaja'
                              : 'Initial Official Launch',
                          highlights: tr.isHausa
                              ? [
                                  'Babban shafi mai kunshe da ginshikan lamuni 3 (0% ruwa, biyan kudin makaranta, alawus na N20,000).',
                                  'Na’urar tantance cancanta da kuma lissafin biyan kudi na 10%.',
                                  'Rumbun tambayoyin doka da mai bin diddigin lokutan aiki (SLA).',
                                ]
                              : [
                                  'Apple Cupertino Human Interface Guidelines design foundation.',
                                  'Core tools: Eligibility Checker, Repayment Calculator, FAQ Knowledge Base, and SLA Timeline Tracker.',
                                ],
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
                CupertinoButton(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  color: NelfundColors.emerald,
                  borderRadius: BorderRadius.circular(12),
                  onPressed: () => Navigator.of(sheetCtx).pop(),
                  child: Center(
                    child: Text(
                      tr.isHausa ? 'Rufe' : 'Close',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: CupertinoColors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildChangelogCard(
    BuildContext context,
    AppTranslations tr, {
    required String version,
    required String build,
    required String date,
    required bool isCurrent,
    required String title,
    required List<String> highlights,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: CupertinoDynamicColor.resolve(
          CupertinoColors.systemGrey6,
          context,
        ),
        borderRadius: BorderRadius.circular(14),
        border: isCurrent
            ? Border.all(
                color: NelfundColors.emerald.withValues(alpha: 0.45),
                width: 1.5,
              )
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                version,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: NelfundColors.emerald,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: CupertinoColors.systemGrey5,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  build,
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
                ),
              ),
              if (isCurrent) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: NelfundColors.emerald,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    tr.isHausa ? 'Na Yanzu' : 'Current',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: CupertinoColors.white,
                    ),
                  ),
                ),
              ],
              const Spacer(),
              Text(
                date,
                style: TextStyle(
                  fontSize: 11.5,
                  color: CupertinoDynamicColor.resolve(
                    NelfundColors.tertiaryLabel,
                    context,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            title,
            style: NelfundTypography.subhead.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 8),
          ...highlights.map(
            (point) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '• ',
                    style: TextStyle(
                      color: NelfundColors.emerald,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      point,
                      style: NelfundTypography.footnote.copyWith(
                        fontSize: 12,
                        height: 1.35,
                        color: CupertinoDynamicColor.resolve(
                          NelfundColors.secondaryLabel,
                          context,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
