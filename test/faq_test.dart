import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_nelfund/features/faq/domain/faq_model.dart';
import 'package:my_nelfund/features/faq/presentation/providers/faq_provider.dart';
import 'package:my_nelfund/features/faq/presentation/views/faq_view.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

final List<FaqItem> mockFaqItems = [
  const FaqItem(
    id: 'app_1',
    question: 'Who is eligible to apply for the NELFUND Student Loan?',
    answer:
        'Under Section 2.0 of the Guidelines, you must be a verified Nigerian citizen (with valid NIN and BVN).',
    statutoryReference: 'Section 2.0 & Section 2.1',
    questionHa:
        'Su wane ne suka cancanci neman bashin karatun dalibai na NELFUND?',
    answerHa:
        'Karkashin Sashe na 2.0 na Ka\'idojin, dole ne ka kasance dan Najeriya.',
    statutoryReferenceHa: 'Sashe na 2.0 & Sashe na 2.1',
    category: FaqCategory.applying,
  ),
  const FaqItem(
    id: 'disb_3',
    question:
        'What happens if I already paid my school fees before the loan was approved?',
    answer:
        'Under Section 4.1.2 of the Guidelines, the tertiary institution is legally mandated to refund the student within 30 calendar days.',
    statutoryReference: 'Section 4.1.2 (Student Refund Policy)',
    questionHa:
        'Menene zai faru idan na riga na biya kudin makaranta da kaina kafin bashi ya fito?',
    answerHa:
        'Doka ta tilasta wa makarantar mayar wa dalibin kudinsa cikin kwanaki 30.',
    statutoryReferenceHa: 'Sashe na 4.1.2 (Mayar wa Dalibi Kudi)',
    category: FaqCategory.disbursement,
  ),
  const FaqItem(
    id: 'rep_5',
    question: 'What happens if I am still unemployed 2 years after NYSC?',
    answer:
        'Under Section 5.1(c), you must submit a sworn affidavit of unemployment and periodic statutory declarations.',
    statutoryReference: 'Section 5.1(c) (Unemployment Declaration)',
    questionHa:
        'Menene zai faru idan har yanzu ban sami aikin yi ba bayan shekaru 2 da NYSC?',
    answerHa:
        'Za ka gabatar da takardar rantsuwa ta rashin aikin yi ga NELFUND.',
    statutoryReferenceHa: 'Sashe na 5.1(c)',
    category: FaqCategory.repayment,
  ),
  const FaqItem(
    id: 'def_1',
    question: 'What is the Global Standing Instruction (GSI) mandate?',
    answer:
        'Under Section 5.3, willful defaulters will have their outstanding loan amount automatically swept via GSI.',
    statutoryReference: 'Section 5.3(d) (GSI Auto-Debit)',
    questionHa:
        'Menene ma\'anar umarnin banki na GSI (Global Standing Instruction)?',
    answerHa: 'Za a rinka kwasar kudin bashinsa kai-tsaye ta hanyar GSI.',
    statutoryReferenceHa: 'Sashe na 5.3(d)',
    category: FaqCategory.defaultRecovery,
  ),
];

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('FaqProvider Search & Filtering Tests', () {
    late FaqProvider provider;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      provider = FaqProvider();
      provider.setItemsForTesting(mockFaqItems);
    });

    tearDown(() {
      provider.dispose();
    });

    test(
      'Initial state contains all fixture questions and all category is selected',
      () {
        expect(provider.selectedCategory, FaqCategory.all);
        expect(provider.filteredItems.length, mockFaqItems.length);
        expect(provider.filteredItems.length, 4);
      },
    );

    test('Filtering by category isolates designated questions', () {
      provider.setCategory(FaqCategory.applying);
      expect(
        provider.filteredItems.every(
          (item) => item.category == FaqCategory.applying,
        ),
        isTrue,
      );
      expect(provider.filteredItems.length, 1);

      provider.setCategory(FaqCategory.disbursement);
      expect(
        provider.filteredItems.every(
          (item) => item.category == FaqCategory.disbursement,
        ),
        isTrue,
      );
      expect(provider.filteredItems.length, 1);

      provider.setCategory(FaqCategory.defaultRecovery);
      expect(
        provider.filteredItems.every(
          (item) => item.category == FaqCategory.defaultRecovery,
        ),
        isTrue,
      );
      expect(provider.filteredItems.length, 1);
    });

    test(
      'Search query matches questions, answers, and statutory citations',
      () {
        provider.setSearchQuery('GSI');
        final gsiItems = provider.filteredItems;
        expect(gsiItems, isNotEmpty);
        expect(
          gsiItems.any(
            (item) =>
                item.question.contains('GSI') || item.answer.contains('GSI'),
          ),
          isTrue,
        );

        provider.setSearchQuery('30 calendar days');
        final refundItems = provider.filteredItems;
        expect(refundItems, isNotEmpty);
        expect(refundItems.first.statutoryReference, contains('Section 4.1.2'));
      },
    );

    test('Expansion toggles properly and can be queried', () {
      const id = 'app_1';
      expect(provider.isExpanded(id), isFalse);

      provider.toggleExpansion(id);
      expect(provider.isExpanded(id), isTrue);

      provider.toggleExpansion(id);
      expect(provider.isExpanded(id), isFalse);
    });

    test('Reset filters restores all categories and clears search', () {
      provider.setCategory(FaqCategory.repayment);
      provider.setSearchQuery('affidavit');
      provider.toggleExpansion('rep_5');

      provider.resetFilters();
      expect(provider.selectedCategory, FaqCategory.all);
      expect(provider.searchQuery, isEmpty);
      expect(provider.isExpanded('rep_5'), isFalse);
      expect(provider.filteredItems.length, mockFaqItems.length);
    });
  });

  group('FaqView UI Tests', () {
    testWidgets(
      'Renders fintech header with Official FAQ title and topics badge',
      (tester) async {
        SharedPreferences.setMockInitialValues({});
        final provider = FaqProvider();
        provider.setItemsForTesting(mockFaqItems);
        addTearDown(() => provider.dispose());

        await tester.pumpWidget(
          CupertinoApp(
            home: ChangeNotifierProvider<FaqProvider>.value(
              value: provider,
              child: const FaqView(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Official FAQ'), findsOneWidget);
        expect(find.textContaining('Topic'), findsOneWidget);
      },
    );
  });
}
