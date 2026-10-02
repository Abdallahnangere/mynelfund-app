import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../../firebase_options.dart';
import '../theme/nelfund_colors.dart';
import 'analytics_service.dart';

/// Top-level background message handler for Firebase Cloud Messaging.
///
/// Must be annotated with `@pragma('vm:entry-point')` so Flutter's AOT compiler
/// preserves it for background isolate execution.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (_) {}

  final title = message.notification?.title ??
      message.data['title'] ??
      message.data['header'] ??
      message.data['subject'] ??
      '';
  final body = message.notification?.body ??
      message.data['body'] ??
      message.data['message'] ??
      message.data['content'] ??
      '';

  debugPrint(
    '[NotificationService] Background message received: ${message.messageId} (title: "$title", body: "$body", data: ${message.data})',
  );
}

/// Production-grade Push Notification Service for My NELFund.
///
/// Manages FCM token registration, topic subscriptions (broadcast announcements),
/// foreground in-app Cupertino banners, and notification click navigation.
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  FirebaseMessaging? _messaging;
  String? _fcmToken;
  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;
  String? get fcmToken => _fcmToken;

  /// Standard broadcast topics for all students
  static const List<String> defaultTopics = [
    'all',
    'general',
    'announcements',
    'loan_updates',
  ];

  /// Initialize Firebase Cloud Messaging
  Future<void> initialize() async {
    if (_isInitialized || kIsWeb) return;

    try {
      _messaging = FirebaseMessaging.instance;

      // 1. Request notification permissions (Android 13+ & iOS)
      final NotificationSettings settings = await _messaging!.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      debugPrint(
        '[NotificationService] Permission authorization status: ${settings.authorizationStatus}',
      );

      // 2. Enable foreground display options on iOS/macOS
      await _messaging!.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      // 3. Register background handler
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

      // 4. Retrieve FCM Registration Token
      try {
        _fcmToken = await _messaging!.getToken();
        debugPrint('[NotificationService] FCM Registration Token: $_fcmToken');
      } catch (tokenErr) {
        debugPrint('[NotificationService] Could not retrieve token: $tokenErr');
      }

      // Listen for token refreshes
      _messaging!.onTokenRefresh.listen((newToken) {
        _fcmToken = newToken;
        debugPrint('[NotificationService] FCM Token refreshed: $newToken');
      });

      // 5. Subscribe to default broadcast topics
      await _subscribeToDefaultTopics();

      // 6. Handle notification click when app is opened from terminated state
      final RemoteMessage? initialMessage = await _messaging!.getInitialMessage();
      if (initialMessage != null) {
        _handleNotificationTap(initialMessage, isTerminatedLaunch: true);
      }

      // 7. Handle notification click when app is running in background
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        _handleNotificationTap(message, isTerminatedLaunch: false);
      });

      _isInitialized = true;
      debugPrint('[NotificationService] Push notifications initialized successfully.');
    } catch (e) {
      debugPrint('[NotificationService] Push notifications unavailable in this environment: $e');
    }
  }

  /// Subscribe device to broadcast announcement topics
  Future<void> _subscribeToDefaultTopics() async {
    if (_messaging == null) return;
    for (final topic in defaultTopics) {
      try {
        await _messaging!.subscribeToTopic(topic);
        debugPrint('[NotificationService] Subscribed to topic: $topic');
      } catch (e) {
        debugPrint('[NotificationService] Topic subscription error ($topic): $e');
      }
    }
  }

  /// Manually subscribe to a specific topic
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _messaging?.subscribeToTopic(topic);
    } catch (_) {}
  }

  /// Manually unsubscribe from a topic
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _messaging?.unsubscribeFromTopic(topic);
    } catch (_) {}
  }

  /// Process notification tap / open event
  void _handleNotificationTap(
    RemoteMessage message, {
    required bool isTerminatedLaunch,
  }) {
    final title = message.notification?.title ??
        message.data['title'] ??
        message.data['header'] ??
        message.data['subject'] ??
        'Notification';
    debugPrint(
      '[NotificationService] Notification opened ($title), isTerminatedLaunch: $isTerminatedLaunch, data: ${message.data}',
    );

    AnalyticsService.instance.logNotificationInteraction(
      title: title,
      messageId: message.messageId,
      action: isTerminatedLaunch ? 'opened_from_terminated' : 'opened_from_background',
    );
  }

  /// Listen to foreground messages and display a stylish in-app Cupertino toast banner
  StreamSubscription<RemoteMessage>? attachForegroundListener(
    BuildContext context, {
    void Function(RemoteMessage)? onNotificationTapped,
  }) {
    if (_messaging == null) return null;

    return FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final title = message.notification?.title ??
          message.data['title'] ??
          message.data['header'] ??
          message.data['subject'] ??
          'My NELFund Alert';

      final body = message.notification?.body ??
          message.data['body'] ??
          message.data['message'] ??
          message.data['content'] ??
          '';

      if (title.isEmpty && body.isEmpty) return;

      AnalyticsService.instance.logNotificationInteraction(
        title: title,
        messageId: message.messageId,
        action: 'received_in_foreground',
      );

      if (context.mounted) {
        _showForegroundBanner(
          context,
          title: title,
          body: body,
          onTap: () {
            onNotificationTapped?.call(message);
          },
        );
      }
    });
  }

  /// Display an Apple-styled floating banner at the top of the screen for foreground messages
  void _showForegroundBanner(
    BuildContext context, {
    required String title,
    required String body,
    VoidCallback? onTap,
  }) {
    final overlay = Overlay.maybeOf(context);
    if (overlay == null) return;

    late OverlayEntry entry;
    Timer? dismissTimer;

    entry = OverlayEntry(
      builder: (ctx) => Positioned(
        top: MediaQuery.of(ctx).padding.top + 8,
        left: 16,
        right: 16,
        child: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () {
            dismissTimer?.cancel();
            entry.remove();
            onTap?.call();
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: CupertinoDynamicColor.resolve(
                const CupertinoDynamicColor.withBrightness(
                  color: Color(0xFAF8FAF8),
                  darkColor: Color(0xFA1E2220),
                ),
                ctx,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: NelfundColors.emerald.withValues(alpha: 0.35),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: CupertinoColors.black.withValues(alpha: 0.15),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: NelfundColors.emerald.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    CupertinoIcons.bell_fill,
                    color: NelfundColors.emerald,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: CupertinoColors.label,
                        ),
                      ),
                      if (body.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          body,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: CupertinoColors.secondaryLabel,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  CupertinoIcons.chevron_right,
                  size: 14,
                  color: CupertinoColors.tertiaryLabel,
                ),
              ],
            ),
          ),
        ),
      ),
    );

    overlay.insert(entry);
    dismissTimer = Timer(const Duration(seconds: 4), () {
      entry.remove();
    });
  }
}
