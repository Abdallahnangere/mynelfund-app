import 'package:flutter_test/flutter_test.dart';
import 'package:my_nelfund/main.dart';

void main() {
  testWidgets('MyNelfundApp launches and displays 5 Cupertino tabs',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MyNelfundApp());
    await tester.pumpAndSettle();

    // Verify all 5 Cupertino navigation tab labels exist
    expect(find.text('Home'), findsWidgets);
    expect(find.text('Eligibility'), findsWidgets);
    expect(find.text('Calculator'), findsWidgets);
    expect(find.text('FAQ'), findsWidgets);
    expect(find.text('Timeline'), findsWidgets);

    // Verify initial home content is displayed
    expect(find.text('My NELFund'), findsOneWidget);

    // Switch to Eligibility tab
    await tester.tap(find.text('Eligibility'));
    await tester.pumpAndSettle();
    expect(find.text('Eligibility Checker'), findsOneWidget);

    // Switch to Calculator tab
    await tester.tap(find.text('Calculator'));
    await tester.pumpAndSettle();
    expect(find.text('Repayment Calculator'), findsOneWidget);
  });
}
