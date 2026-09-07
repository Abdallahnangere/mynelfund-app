import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/services/analytics_service.dart';
import '../../core/services/review_service.dart';
import '../../core/services/update_service.dart';
import '../../core/theme/nelfund_colors.dart';
import '../../core/theme/nelfund_typography.dart';
import '../../widgets/apple_frosted_card.dart';

class AboutView extends StatelessWidget {
  const AboutView({super.key});

  static const String developerPhone = '09076872520';
  static const String developerIntlPhone = '+2349076872520';
  static const String developerWhatsAppUrl =
      'https://wa.me/2349076872520?text=Hello%20Abdullahi,%20I%27m%20reaching%20out%20from%20the%20NELFUND%20Student%20Loan%20Guide';
  static const String anjalVenturesUrl = 'https://www.anjalventures.com';
  static const String nelfundWebsiteUrl = 'https://nelf.gov.ng';
  static const String nelfundEmail = 'info@nelf.gov.ng';

  Future<void> _launch(BuildContext context, String urlString) async {
    final isTel = urlString.startsWith('tel:');
    final isWa = urlString.contains('wa.me');
    final isMail = urlString.startsWith('mailto:');
    final isAnjal = urlString.contains('anjalventures');
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
            ? 'Anjal Ventures Website'
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

  void _copyToClipboard(BuildContext context, String text, String label) {
    AnalyticsService.instance.logDeveloperContact(method: 'copy_$label');
    Clipboard.setData(ClipboardData(text: text));
    showCupertinoDialog<void>(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text('Copied to Clipboard'),
        content: Text('$label ($text) has been copied.'),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(BuildContext context, String message) {
    showCupertinoDialog<void>(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text('Notice'),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(
          'About & Support',
          style: NelfundTypography.headline.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 17,
            letterSpacing: -0.4,
          ),
        ),
        backgroundColor: CupertinoDynamicColor.resolve(
          const CupertinoDynamicColor.withBrightness(
            color: Color(0xCCF8FAF8),
            darkColor: Color(0xCC161718),
          ),
          context,
        ),
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 16),
          children: [
            _buildDeveloperProfileCard(context),
            const SizedBox(height: 16),
            _buildDeveloperContactCard(context),
            const SizedBox(height: 16),
            _buildClarificationNoticeCard(context),
            const SizedBox(height: 16),
            _buildOfficialNelfundChannelsCard(context),
            const SizedBox(height: 16),
            _buildAppManagementCard(context),
            const SizedBox(height: 24),
            _buildFooter(context),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildDeveloperProfileCard(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0C2B1C),
              Color(0xFF071F14),
            ],
          ),
          border: Border.all(
            color: const Color(0x4D48BB78),
            width: 1.2,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x38004D25),
              blurRadius: 18,
              offset: Offset(0, 8),
            ),
          ],
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [NelfundColors.emerald, Color(0xFF68D391)],
                    ),
                    border: Border.all(
                      color: CupertinoColors.white,
                      width: 2,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x44000000),
                        blurRadius: 8,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text(
                      'AU',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: CupertinoColors.white,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Abdullahi Adam Usman',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: CupertinoColors.white,
                          letterSpacing: -0.4,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0x3348BB78),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: const Color(0x5548BB78),
                            width: 0.8,
                          ),
                        ),
                        child: const Text(
                          'Founder, Anjal Ventures',
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF68D391),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              height: 0.8,
              color: const Color(0x28FFFFFF),
            ),
            const SizedBox(height: 14),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  CupertinoIcons.book_fill,
                  size: 16,
                  color: Color(0xFF68D391),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '300 Level Student of International Studies',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: CupertinoColors.white.withValues(alpha: 0.95),
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
                  color: Color(0xFF68D391),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Ahmadu Bello University (ABU), Zaria',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: CupertinoColors.white.withValues(alpha: 0.85),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: CupertinoButton(
                padding: const EdgeInsets.symmetric(vertical: 12),
                color: NelfundColors.emerald,
                borderRadius: BorderRadius.circular(12),
                minimumSize: Size.zero,
                onPressed: () => _launch(context, anjalVenturesUrl),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      CupertinoIcons.globe,
                      size: 17,
                      color: CupertinoColors.white,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Visit www.anjalventures.com',
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
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
    );
  }

  Widget _buildDeveloperContactCard(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: AppleFrostedCard(
        borderColor: NelfundColors.emerald.withValues(alpha: 0.4),
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
                    'Contact Developer',
                    style: NelfundTypography.headline.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Have feedback, suggestions, or technical questions about this guide? Reach out directly to the developer:',
              style: NelfundTypography.footnote.copyWith(
                color: CupertinoDynamicColor.resolve(
                  NelfundColors.secondaryLabel,
                  context,
                ),
                fontSize: 12.5,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: CupertinoDynamicColor.resolve(
                  const CupertinoDynamicColor.withBrightness(
                    color: Color(0xF2F0FBF5),
                    darkColor: Color(0xD0132B1D),
                  ),
                  context,
                ),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: NelfundColors.emerald.withValues(alpha: 0.35),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    'DIRECT PHONE LINE',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                      color: NelfundColors.emerald,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    developerPhone,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                      color: NelfundColors.emerald,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CupertinoButton(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        color: NelfundColors.emerald,
                        borderRadius: BorderRadius.circular(20),
                        minimumSize: Size.zero,
                        onPressed: () => _launch(context, 'tel:$developerPhone'),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              CupertinoIcons.phone_fill,
                              size: 15,
                              color: CupertinoColors.white,
                            ),
                            SizedBox(width: 6),
                            Text(
                              'Call Now',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: CupertinoColors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      CupertinoButton(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        color: CupertinoDynamicColor.resolve(
                          CupertinoColors.systemGrey5,
                          context,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        minimumSize: Size.zero,
                        onPressed: () => _copyToClipboard(
                          context,
                          developerPhone,
                          'Phone Number',
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              CupertinoIcons.doc_on_doc,
                              size: 15,
                              color: CupertinoDynamicColor.resolve(
                                NelfundColors.label,
                                context,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Copy',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: CupertinoDynamicColor.resolve(
                                  NelfundColors.label,
                                  context,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: CupertinoButton(
                padding: const EdgeInsets.symmetric(vertical: 14),
                color: const Color(0xFF25D366),
                borderRadius: BorderRadius.circular(14),
                minimumSize: Size.zero,
                onPressed: () => _launch(context, developerWhatsAppUrl),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      CupertinoIcons.chat_bubble_2_fill,
                      size: 20,
                      color: CupertinoColors.white,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Chat Directly on WhatsApp',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
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
    );
  }

  Widget _buildClarificationNoticeCard(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: AppleFrostedCard(
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
                    'Official Clarification & Disclaimer',
                    style: NelfundTypography.headline.copyWith(
                      fontSize: 15.5,
                      fontWeight: FontWeight.w700,
                      color: CupertinoColors.systemOrange,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'This application was developed as an independent student initiative created solely for public awareness, education, and enlightenment regarding the Nigerian student loan scheme.',
              style: NelfundTypography.footnote.copyWith(
                fontSize: 13,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 8),
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
                    CupertinoIcons.exclamationmark_triangle_fill,
                    size: 16,
                    color: CupertinoColors.systemOrange,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Not an Official NELFUND App: This app is not affiliated with, authorized by, or endorsed by the National Higher Education Support Fund (NELFUND) or the Federal Government of Nigeria.',
                      style: NelfundTypography.captionBold.copyWith(
                        fontSize: 12,
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'No Personal Data Storage: This app does NOT collect, store, or transmit your National Identity Number (NIN), Bank Verification Number (BVN), JAMB details, or academic credentials. All calculations and simulations operate entirely offline on your device.',
              style: NelfundTypography.footnote.copyWith(
                color: CupertinoDynamicColor.resolve(
                  NelfundColors.secondaryLabel,
                  context,
                ),
                fontSize: 12,
                height: 1.35,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOfficialNelfundChannelsCard(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: AppleFrostedCard(
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
                    'Official NELFUND Channels',
                    style: NelfundTypography.headline.copyWith(
                      fontSize: 15.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'For official loan applications, institution verification (SVS), and formal inquiries, use only authorized Federal Government portals:',
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
              title: 'Official Portal & Website',
              subtitle: 'nelf.gov.ng',
              buttonLabel: 'Open Portal',
              onTap: () => _launch(context, nelfundWebsiteUrl),
            ),
            const SizedBox(height: 10),
            _buildOfficialChannelRow(
              context: context,
              icon: CupertinoIcons.mail_solid,
              iconColor: CupertinoColors.systemBlue,
              title: 'Official Inquiries Email',
              subtitle: nelfundEmail,
              buttonLabel: 'Send Email',
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
                fontWeight: FontWeight.w700,
                color: CupertinoColors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppManagementCard(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: AppleFrostedCard(
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
                    'App Store & Community',
                    style: NelfundTypography.headline.copyWith(
                      fontSize: 15.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: NelfundColors.emerald.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'v1.0.0',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w800,
                      color: NelfundColors.emerald,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Help other Nigerian students discover zero-interest financing by rating the app, or check for the latest official updates.',
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
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          CupertinoIcons.star_fill,
                          size: 15,
                          color: Color(0xFFFFD700),
                        ),
                        SizedBox(width: 6),
                        Text(
                          'Rate & Review',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
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
                          'Check Update',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
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

  Widget _buildFooter(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Built with ',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: CupertinoColors.systemGrey,
                ),
              ),
              Icon(
                CupertinoIcons.heart_fill,
                color: CupertinoColors.systemRed,
                size: 15,
              ),
              Text(
                ' for Nigerian Students',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: CupertinoColors.systemGrey,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'from Abdullahi Adam Usman',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: NelfundColors.emerald,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '300 Level Student of International Studies\nAhmadu Bello University, Zaria\nFounder of Anjal Ventures',
            textAlign: TextAlign.center,
            style: NelfundTypography.caption.copyWith(
              color: CupertinoDynamicColor.resolve(
                NelfundColors.tertiaryLabel,
                context,
              ),
              height: 1.35,
            ),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () => _launch(context, anjalVenturesUrl),
            child: const Text(
              'www.anjalventures.com',
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: NelfundColors.emerald,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Version 1.0.0 • Students Loans (Access to Higher Education) Act 2024',
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
}
