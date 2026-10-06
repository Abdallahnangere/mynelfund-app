import '../core/localization/app_locale.dart';

enum FaqCategory {
  all,
  applying,
  disbursement,
  repayment,
  defaultRecovery,
}

extension FaqCategoryExtension on FaqCategory {
  String get title => getTitle(AppLanguage.english);

  String getTitle(AppLanguage lang) {
    if (lang == AppLanguage.hausa) {
      switch (this) {
        case FaqCategory.all:
          return 'Dukkan Tambayoyi';
        case FaqCategory.applying:
          return 'Neman Bashi & Cancanta';
        case FaqCategory.disbursement:
          return 'Biyan Kudin Makaranta & Alawus';
        case FaqCategory.repayment:
          return 'Biyan Bashi & Sassauci';
        case FaqCategory.defaultRecovery:
          return 'Kin Biya & Matakan Doka';
      }
    }
    switch (this) {
      case FaqCategory.all:
        return 'All Questions';
      case FaqCategory.applying:
        return 'Applying & Eligibility';
      case FaqCategory.disbursement:
        return 'Disbursement & Fees';
      case FaqCategory.repayment:
        return 'Repayment & Moratorium';
      case FaqCategory.defaultRecovery:
        return 'Default & Legal';
    }
  }

  String get shortLabel => getShortLabel(AppLanguage.english);

  String getShortLabel(AppLanguage lang) {
    if (lang == AppLanguage.hausa) {
      switch (this) {
        case FaqCategory.all:
          return 'Duka';
        case FaqCategory.applying:
          return 'Neman Bashi';
        case FaqCategory.disbursement:
          return 'Biyan Kudi';
        case FaqCategory.repayment:
          return 'Biyan Bashi';
        case FaqCategory.defaultRecovery:
          return 'Shari\'a';
      }
    }
    switch (this) {
      case FaqCategory.all:
        return 'All';
      case FaqCategory.applying:
        return 'Applying';
      case FaqCategory.disbursement:
        return 'Disbursement';
      case FaqCategory.repayment:
        return 'Repayment';
      case FaqCategory.defaultRecovery:
        return 'Default';
    }
  }
}

class FaqItem {
  final String id;
  final String question;
  final String answer;
  final String statutoryReference;
  final String questionHa;
  final String answerHa;
  final String statutoryReferenceHa;
  final FaqCategory category;

  const FaqItem({
    required this.id,
    required this.question,
    required this.answer,
    required this.statutoryReference,
    required this.questionHa,
    required this.answerHa,
    required this.statutoryReferenceHa,
    required this.category,
  });

  static FaqCategory parseCategory(String? name) {
    if (name == null) return FaqCategory.applying;
    return FaqCategory.values.firstWhere(
      (c) => c.name.toLowerCase() == name.toLowerCase(),
      orElse: () => FaqCategory.applying,
    );
  }

  factory FaqItem.fromMap(Map<String, dynamic> map, [String? id]) {
    return FaqItem(
      id: id ?? map['id']?.toString() ?? '',
      question: map['question']?.toString() ?? '',
      answer: map['answer']?.toString() ?? '',
      statutoryReference: map['statutoryReference']?.toString() ?? '',
      questionHa: map['questionHa']?.toString() ?? map['question']?.toString() ?? '',
      answerHa: map['answerHa']?.toString() ?? map['answer']?.toString() ?? '',
      statutoryReferenceHa: map['statutoryReferenceHa']?.toString() ?? map['statutoryReference']?.toString() ?? '',
      category: parseCategory(map['category']?.toString()),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'question': question,
      'answer': answer,
      'statutoryReference': statutoryReference,
      'questionHa': questionHa,
      'answerHa': answerHa,
      'statutoryReferenceHa': statutoryReferenceHa,
      'category': category.name,
    };
  }

  String getQuestion(AppLanguage lang) =>
      lang == AppLanguage.hausa ? questionHa : question;

  String getAnswer(AppLanguage lang) =>
      lang == AppLanguage.hausa ? answerHa : answer;

  String getReference(AppLanguage lang) =>
      lang == AppLanguage.hausa ? statutoryReferenceHa : statutoryReference;

  String getStatutoryReference(AppLanguage lang) => getReference(lang);

}
