import 'package:flutter/cupertino.dart';

import '../../../../core/localization/app_locale.dart';
import '../../../../shared/widgets/apple_frosted_card.dart';
import '../../domain/eligibility_model.dart';
import '../providers/eligibility_provider.dart';
import 'eligibility_check_row.dart';

/// Section 1 statutory core eligibility criteria checklist card.
class CoreCriteriaCard extends StatelessWidget {
  /// Creates a [CoreCriteriaCard].
  const CoreCriteriaCard({
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
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          EligibilityCheckRow(
            title: isHa
                ? 'Ɗan Ƙasa ne na Najeriya (Tantance NIN da BVN)'
                : 'Nigerian Citizen (NIN & BVN Verified)',
            subtitle: isHa
                ? 'Tabbatar da zama ɗan Najeriya ta hanyar lambobin ɗan ƙasa NIN da kuma na banki BVN (Sashe na 2.1)'
                : 'Must be a Nigerian citizen as defined by the Constitution.',
            value: provider.isNigerianCitizen,
            onChanged: provider.toggleNigerianCitizen,
          ),
          EligibilityCheckRow(
            title: isHa
                ? 'Makarantar Gwamnati da Aka Amince da Ita'
                : 'Approved Public Tertiary Institution',
            subtitle: isHa
                ? "Kasancewa ɗalibi a jami'a, kwalejin foliteknik ko kwalejin ilimi ta gwamnatin tarayya ko jiha (Sashe na 2.2)"
                : 'Enrolled in an eligible Federal/State public university, polytechnic, or college.',
            value: provider.isEnrolledInPublicEti,
            onChanged: provider.toggleEnrolledInPublicEti,
          ),
          EligibilityCheckRow(
            title: isHa
                ? 'Tabbatar da Matsayin Karatu'
                : 'Academic Status Verified',
            subtitle: provider.academicType
                .getLocalizedAcademicRequirementLabel(language),
            value: provider.isAcademicAdmissionVerified,
            onChanged: provider.toggleAcademicAdmissionVerified,
          ),
          EligibilityCheckRow(
            title: isHa
                ? 'Makarantarku ta Loda Bayananku a Tsarin SVS'
                : 'Uploaded to Student Verification System (SVS)',
            subtitle: isHa
                ? 'Makarantarku ta loda cikakkun bayanan ɗalibanta zuwa tsarin NELFUND (SVS) domin tantancewa.'
                : 'Your tertiary institution has uploaded your student profile to NELFUND.',
            value: provider.isSchoolDataUploaded,
            onChanged: provider.toggleSchoolDataUploaded,
            isLast: true,
          ),
        ],
      ),
    );
  }
}
