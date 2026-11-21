import 'package:flutter/cupertino.dart';

import '../../../../core/localization/app_locale.dart';
import '../../../../core/theme/nelfund_colors.dart';
import '../../../../core/theme/nelfund_typography.dart';
import '../../../../shared/widgets/apple_frosted_card.dart';
import '../providers/eligibility_provider.dart';
import 'eligibility_check_row.dart';

/// Section 3 statutory disqualification bars card covering Section 3.0 of the
/// NELFUND Guidelines.
class DisqualifierSection extends StatelessWidget {
  /// Creates a [DisqualifierSection].
  const DisqualifierSection({
    super.key,
    required this.provider,
    required this.language,
  });

  /// Eligibility state owner.
  final EligibilityProvider provider;

  /// Active language.
  final AppLanguage language;

  @override
  Widget build(BuildContext context) {
    final isHa = language == AppLanguage.hausa;

    return AppleFrostedCard(
      borderColor: CupertinoColors.systemRed.withValues(alpha: 0.3),
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      CupertinoIcons.exclamationmark_shield_fill,
                      color: CupertinoColors.systemRed,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        isHa
                            ? 'Shingen Doka Masu Hana Bashi'
                            : 'Statutory Disqualification Bars',
                        style: NelfundTypography.headline.copyWith(
                          color: CupertinoColors.systemRed,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  isHa
                      ? "Ƙarƙashin Sashe na 3.0 na Ƙa'idojin, kasancewar kowane ɗaya daga cikin waɗannan zai hana samun bashi kai-tsaye:"
                      : 'Under Section 3.0 of the Guidelines, having any of these conditions will automatically disqualify an applicant:',
                  style: NelfundTypography.footnote.copyWith(
                    color: CupertinoDynamicColor.resolve(
                      NelfundColors.secondaryLabel,
                      context,
                    ),
                  ),
                ),
              ],
            ),
          ),
          EligibilityCheckRow(
            isDestructive: true,
            title: isHa
                ? 'Ƙin Biyan Wani Bashin Karatu a Baya'
                : 'Prior Education Loan Default',
            subtitle: isHa
                ? 'Wanda ya gaza biyan wani bashin karatu na gwamnatin tarayya ko jiha a baya.'
                : 'Defaulted on any prior FG or state education loan.',
            value: provider.hasPriorLoanDefault,
            onChanged: provider.togglePriorLoanDefault,
          ),
          EligibilityCheckRow(
            isDestructive: true,
            title: isHa
                ? 'Mai Ƙarɓar Wani Tallafin Karatu / Bashi a Halin Yanzu'
                : 'Concurrent Scholarship / Loan Beneficiary',
            subtitle: isHa
                ? 'Duk wanda a yanzu yake cin gajiyar wani tallafin karatu ko lamuni na gwamnati.'
                : 'Currently receiving another FG or state education loan or scholarship.',
            value: provider.hasActiveScholarship,
            onChanged: provider.toggleActiveScholarship,
          ),
          EligibilityCheckRow(
            isDestructive: true,
            title: isHa
                ? 'Laifin Maguɗin Jarrabawa ko Halayyar Makaranta'
                : 'Institutional Misconduct or Malpractice',
            subtitle: isHa
                ? 'Wanda makaranta ta kama da satar fasaha, ƙungiyar asiri, tashin hankali, ko ƙorar maguɗin jarrabawa.'
                : 'Found culpable of plagiarism, cultism, violence, exam malpractice dismissal, or forged papers.',
            value: provider.hasAcademicMisconduct,
            onChanged: provider.toggleAcademicMisconduct,
          ),
          EligibilityCheckRow(
            isDestructive: true,
            title: isHa
                ? 'Hukuncin Kotu Kan Aikata Laifi'
                : 'Criminal Conviction',
            subtitle: isHa
                ? 'Wanda kotu ta taɓa yanke wa hukunci kan damfara, jabu, miyagun ƙwayoyi, ko rashin gaskiya.'
                : 'Convicted of fraud, forgery, drug offences, felony, or dishonesty.',
            value: provider.hasCriminalConviction,
            onChanged: provider.toggleCriminalConviction,
          ),
          EligibilityCheckRow(
            isDestructive: true,
            title: isHa
                ? 'Mai Shaidar Digiri na Farko'
                : 'Holder of First Degree',
            subtitle: isHa
                ? 'Wanda ya riga ya mallaki digiri na farko (B.Sc/B.A) ko makamancin haka.'
                : 'Already possesses a bachelor’s degree or higher equivalent.',
            value: provider.holdsFirstDegree,
            onChanged: provider.toggleHoldsFirstDegree,
            isLast: true,
          ),
        ],
      ),
    );
  }
}
