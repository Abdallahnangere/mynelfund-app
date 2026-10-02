import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:my_nelfund/core/localization/locale_provider.dart';
import 'package:my_nelfund/models/notification_model.dart';
import 'package:my_nelfund/providers/notification_provider.dart';
import 'package:my_nelfund/views/notifications/notifications_view.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('NotificationModel & NotificationProvider Tests', () {
    test('NotificationItem serializes to and from Map accurately', () {
      final now = DateTime.now();
      final item = NotificationItem(
        id: 'notif_123',
        title: 'Portal Window Open',
        body: '2024/2025 applications are now accepting submissions.',
        badge: 'Portal Open',
        badgeColorHex: '#2E7D32',
        timestamp: 'Today',
        createdAt: now,
        isRead: false,
      );

      final map = item.toMap();
      expect(map['id'], 'notif_123');
      expect(map['title'], 'Portal Window Open');
      expect(map['badge'], 'Portal Open');

      final reconstructed = NotificationItem.fromMap(map);
      expect(reconstructed.id, 'notif_123');
      expect(reconstructed.title, 'Portal Window Open');
      expect(reconstructed.badge, 'Portal Open');
      expect(reconstructed.isRead, isFalse);
    });

    test('NotificationProvider marks notifications as read and calculates unread count', () {
      final provider = NotificationProvider();

      final item1 = NotificationItem(
        id: 'n1',
        title: 'Advisory 1',
        body: 'Body 1',
        badge: 'Advisory',
        badgeColorHex: '#0D5C3A',
        timestamp: '1h ago',
        createdAt: DateTime.now(),
        isRead: false,
      );

      final item2 = NotificationItem(
        id: 'n2',
        title: 'Advisory 2',
        body: 'Body 2',
        badge: 'Advisory',
        badgeColorHex: '#0D5C3A',
        timestamp: '2h ago',
        createdAt: DateTime.now(),
        isRead: false,
      );

      provider.addNotificationLocally(item1);
      provider.addNotificationLocally(item2);

      expect(provider.notifications.length, 2);
      expect(provider.unreadCount, 2);
      expect(provider.hasUnread, isTrue);

      provider.markAsRead('n1');
      expect(provider.unreadCount, 1);
      expect(provider.notifications.firstWhere((n) => n.id == 'n1').isRead, isTrue);

      provider.markAllAsRead();
      expect(provider.unreadCount, 0);
      expect(provider.hasUnread, isFalse);
    });
  });

  group('NotificationsView Widget Tests', () {
    testWidgets('Renders full-screen NotificationsView header and empty state when no items', (tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => LocaleProvider()),
            ChangeNotifierProvider(create: (_) => NotificationProvider()),
          ],
          child: const CupertinoApp(
            home: NotificationsView(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Official Bulletins'), findsOneWidget);
      expect(find.byType(CupertinoSearchTextField), findsOneWidget);
      expect(find.text('No Notifications Yet'), findsOneWidget);
    });
  });
}
