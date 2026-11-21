import 'package:flutter/cupertino.dart';

import '../../../../core/localization/app_locale.dart';
import '../../../../shared/widgets/apple_frosted_card.dart';
import '../providers/eligibility_provider.dart';
import 'eligibility_check_row.dart';

/// Section 2 KYC & Identity documentation readiness checklist card.
class KycReadinessCard extends StatelessWidget {
  /// Creates a [KycReadinessCard].
  const KycReadinessCard({
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
            title: isHa ? 'Lambar Rajistar JAMB' : 'JAMB Registration Number',
            subtitle: isHa
                ? 'Ingantacciyar lambar JAMB da aka tantance tare da hukumar JAMB.'
                : 'Validated with the Joint Admissions & Matriculation Board.',
            value: provider.hasJambNumber,
            onChanged: provider.toggleJambNumber,
          ),
          EligibilityCheckRow(
            title: isHa
                ? 'Lambar Tabbatar da Asusun Banki (BVN)'
                : 'Bank Verification Number (BVN)',
            subtitle: isHa
                ? 'Dole ne ga dukkan masu neman bashi masu shekaru 18 ko sama da haka (NIBSS).'
                : 'Mandatory for all applicants aged 18 years and above (NIBSS).',
            value: provider.hasBvn,
            onChanged: provider.toggleBvn,
          ),
          EligibilityCheckRow(
            title: isHa
                ? 'Lambar Shaidar Ɗan Ƙasa (NIN)'
                : 'National Identity Number (NIN)',
            subtitle: isHa
                ? 'Wadda aka tantance a rumbun adana bayanai na NIMC.'
                : 'Verified through NIMC database.',
            value: provider.hasNin,
            onChanged: provider.toggleNin,
          ),
          EligibilityCheckRow(
            title: isHa
                ? 'Bayanin Adireshin Zama da Lambar Waya'
                : 'Personal Contact & Residential Info',
            subtitle: isHa
                ? 'Ingantacciyar lambar waya, adireshin gida, shekaru, jinsi da imel mai aiki.'
                : 'Valid phone number, residential address, age, gender, and active email.',
            value: provider.hasPersonalInfo,
            onChanged: provider.togglePersonalInfo,
          ),
          EligibilityCheckRow(
            title: isHa
                ? 'Hoton Fasfo na Zamani'
                : 'Recent Passport Photograph',
            subtitle: isHa
                ? 'Hoton fasfo na zamani mai farin baya a shirye yake.'
                : 'Clear digital headshot for identity verification.',
            value: provider.hasPassportPhoto,
            onChanged: provider.togglePassportPhoto,
          ),
          EligibilityCheckRow(
            title: isHa
                ? 'Takardar Shaidar Karatu ko Katin Ɗalibi'
                : 'Valid Admission Letter or Student ID',
            subtitle: isHa
                ? 'Shaidar zama ɗalibi a babbar makarantar gwamnati da ta cancanta.'
                : 'Official proof of studentship from an Eligible Tertiary Institution (ETI).',
            value: provider.hasAdmissionOrStudentId,
            onChanged: provider.toggleAdmissionOrStudentId,
            isLast: true,
          ),
        ],
      ),
    );
  }
}
