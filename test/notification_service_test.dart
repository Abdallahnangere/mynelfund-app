import 'package:flutter_test/flutter_test.dart';
import 'package:my_nelfund/core/services/notification_service.dart';

void main() {
  group('NotificationService Tests', () {
    test('NotificationService singleton instance exists and is non-null', () {
      final service = NotificationService.instance;
      expect(service, isNotNull);
    });

    test('Default broadcast topics match all, general, announcements, and loan_updates', () {
      expect(
        NotificationService.defaultTopics,
        containsAll(['all', 'general', 'announcements', 'loan_updates']),
      );
      expect(NotificationService.defaultTopics.length, 4);
    });

    test('Topic subscription and unsubscription methods run safely without throwing',
        () async {
      final service = NotificationService.instance;
      await expectLater(service.subscribeToTopic('test_topic'), completes);
      await expectLater(service.unsubscribeFromTopic('test_topic'), completes);
    });
  });
}
