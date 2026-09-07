import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_nelfund/models/faq_model.dart';
import 'package:my_nelfund/providers/faq_provider.dart';
import 'package:my_nelfund/views/faq/faq_view.dart';

void main() {
  group('FaqProvider Search & Filtering Tests', () {
    late FaqProvider provider;

    setUp(() {
      provider = FaqProvider();
    });

    test('Initial state contains all default questions and all category is selected', () {
      expect(provider.selectedCategory, FaqCategory.all);
      expect(provider.filteredItems.length, FaqItem.defaultList.length);
      expect(provider.filteredItems.length, greaterThanOrEqualTo(15));
    });

    test('Filtering by category isolates designated questions', () {
      provider.setCategory(FaqCategory.applying);
      expect(provider.filteredItems.every((item) => item.category == FaqCategory.applying), isTrue);

      provider.setCategory(FaqCategory.disbursement);
      expect(provider.filteredItems.every((item) => item.category == FaqCategory.disbursement), isTrue);

      provider.setCategory(FaqCategory.defaultRecovery);
      expect(provider.filteredItems.every((item) => item.category == FaqCategory.defaultRecovery), isTrue);
    });

    test('Search query matches questions, answers, and statutory citations', () {
      provider.setSearchQuery('GSI');
      final gsiItems = provider.filteredItems;
      expect(gsiItems, isNotEmpty);
      expect(gsiItems.any((item) => item.question.contains('GSI') || item.answer.contains('GSI')), isTrue);

      provider.setSearchQuery('30 calendar days');
      final refundItems = provider.filteredItems;
      expect(refundItems, isNotEmpty);
      expect(refundItems.first.statutoryReference, contains('Section 4.1.2'));
    });

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
      expect(provider.filteredItems.length, FaqItem.defaultList.length);
    });
  });

  group('FaqView UI Tests', () {
    testWidgets('Renders fintech header with Official FAQ title and topics badge', (tester) async {
      await tester.pumpWidget(
        const CupertinoApp(
          home: FaqView(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Official FAQ'), findsOneWidget);
      expect(find.textContaining('Topics'), findsOneWidget);
    });
  });
}
