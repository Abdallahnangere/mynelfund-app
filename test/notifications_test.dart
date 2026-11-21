import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_nelfund/core/localization/locale_provider.dart';
import 'package:my_nelfund/features/notifications/domain/notification_model.dart';
import 'package:my_nelfund/features/notifications/presentation/providers/notification_provider.dart';
import 'package:my_nelfund/features/notifications/presentation/views/notifications_view.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

    test(
      'NotificationProvider marks notifications as read and calculates unread count',
      () {
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
        expect(
          provider.notifications.firstWhere((n) => n.id == 'n1').isRead,
          isTrue,
        );

        provider.markAllAsRead();
        expect(provider.unreadCount, 0);
        expect(provider.hasUnread, isFalse);
      },
    );

    test(
      'NotificationProvider restores stored notifications and read state on app reopen',
      () async {
        SharedPreferences.setMockInitialValues({});
        final prov1 = NotificationProvider();

        final itemA = NotificationItem(
          id: 'n_stored_1',
          title: 'Stored Bulletin',
          body: 'This must persist across launches.',
          badge: 'Statutory',
          badgeColorHex: '#0D5C3A',
          timestamp: 'Just now',
          createdAt: DateTime.now(),
          isRead: false,
        );

        prov1.addNotificationLocally(itemA);
        prov1.markAsRead('n_stored_1');

        await Future<void>.delayed(const Duration(milliseconds: 50));

        // Simulate app restart / reopen: create a second provider instance reading from the same mock SharedPreferences
        final prov2 = NotificationProvider();
        await Future<void>.delayed(const Duration(milliseconds: 50));

        expect(prov2.notifications.length, 1);
        expect(prov2.notifications.first.id, 'n_stored_1');
        expect(prov2.notifications.first.title, 'Stored Bulletin');
        expect(prov2.notifications.first.isRead, isTrue);
        expect(prov2.unreadCount, 0);
      },
    );

    test(
      'NotificationProvider.saveNotificationDirectlyToDisk saves incoming push to disk',
      () async {
        SharedPreferences.setMockInitialValues({});

        final pushItem = NotificationItem(
          id: 'push_bg_1',
          title: 'Background Push Notification',
          body: 'Arrived when app was closed.',
          badge: 'Alert',
          badgeColorHex: '#0D5C3A',
          timestamp: 'Today',
          createdAt: DateTime.now(),
          isRead: false,
        );

        // Save directly to disk from simulated background isolate
        await NotificationProvider.saveNotificationDirectlyToDisk(pushItem);

        // App is opened later by the user
        final prov = NotificationProvider();
        await Future<void>.delayed(const Duration(milliseconds: 50));

        expect(prov.notifications.length, 1);
        expect(prov.notifications.first.id, 'push_bg_1');
        expect(prov.notifications.first.title, 'Background Push Notification');
        expect(prov.unreadCount, 1);
      },
    );
  });

  group('NotificationsView Widget Tests', () {
    testWidgets(
      'Renders full-screen NotificationsView header and empty state when no items',
      (tester) async {
        await tester.pumpWidget(
          MultiProvider(
            providers: [
              ChangeNotifierProvider(create: (_) => LocaleProvider()),
              ChangeNotifierProvider(create: (_) => NotificationProvider()),
            ],
            child: const CupertinoApp(home: NotificationsView()),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Official Bulletins'), findsOneWidget);
        expect(find.byType(CupertinoSearchTextField), findsOneWidget);
        expect(find.text('No Notifications Yet'), findsOneWidget);
      },
    );
  });
}
