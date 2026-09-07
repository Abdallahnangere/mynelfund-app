import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_nelfund/views/about/about_view.dart';

void main() {
  testWidgets('AboutView renders developer profile, contact, disclaimer, and official channels',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      const CupertinoApp(
        home: AboutView(),
      ),
    );
    await tester.pumpAndSettle();

    // Header
    expect(find.text('About & Support'), findsOneWidget);

    // Developer Profile Card
    expect(find.text('ABOUT DEVELOPER & BUILDER'), findsOneWidget);
    expect(find.textContaining('My NELFund is an independent civic initiative'), findsOneWidget);
    expect(find.text('Abdullahi Adam Usman'), findsWidgets);
    expect(find.text('Founder, Anjal Ventures'), findsWidgets);
    expect(find.text('300 Level Student of International Studies.'), findsWidgets);
    expect(find.text('Ahmadu Bello University (ABU), Zaria.'), findsWidgets);
    expect(find.text('Visit www.anjalventures.com'), findsOneWidget);

    // Developer Contact Section
    expect(find.text('Contact Developer'), findsOneWidget);
    expect(find.text('09076872520'), findsOneWidget);
    expect(find.text('Call Now'), findsOneWidget);
    expect(find.text('Copy'), findsOneWidget);
    expect(find.text('Chat Directly on WhatsApp'), findsOneWidget);

    // Clarification & Disclaimer Card
    expect(find.text('Official Clarification & Disclaimer'), findsOneWidget);
    expect(find.textContaining('Independent Civic Initiative'), findsOneWidget);
    expect(find.textContaining('Nigerian Education Loan Fund'), findsOneWidget);
    expect(find.textContaining('Zero Personal Data Collection'), findsOneWidget);

    // Official NELFUND Channels Card
    expect(find.text('Official NELFUND Channels'), findsOneWidget);
    expect(find.text('nelf.gov.ng'), findsOneWidget);
    expect(find.text('info@nelf.gov.ng'), findsOneWidget);
    expect(find.text('Open Portal'), findsOneWidget);
    expect(find.text('Send Email'), findsOneWidget);

    // App Store & Community Card
    expect(find.textContaining('Store & Community'), findsOneWidget);
    expect(find.textContaining('Rate on'), findsOneWidget);
    expect(find.text('Check Update'), findsOneWidget);
    expect(find.textContaining('com.mynelfund.app'), findsOneWidget);

    // Footer
    expect(find.textContaining('for Nigerian Students'), findsOneWidget);
    expect(find.text('www.anjalventures.com'), findsWidgets);
  });
}
