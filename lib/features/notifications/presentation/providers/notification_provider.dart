import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/notification_model.dart';

class NotificationProvider extends ChangeNotifier {
  static const String _cacheKey = 'cached_notifications_v1';
  static const String _readIdsKey = 'read_notification_ids_v1';

  static NotificationProvider? current;

  List<NotificationItem> _notifications = [];
  Set<String> _readIds = {};
  bool _isLoading = false;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>?
  _firestoreSubscription;
  Timer? _retryTimer;

  NotificationProvider() {
    current = this;
    _initialize();
  }

  List<NotificationItem> get notifications => List.unmodifiable(_notifications);
  int get unreadCount => _notifications.where((n) => !n.isRead).length;
  bool get hasUnread => unreadCount > 0;
  bool get isLoading => _isLoading;

  Future<void> _initialize() async {
    // 1. Immediately load local cache and read IDs for 0ms startup
    await _loadFromLocalCache();

    // 2. Attach live Firestore listener
    _attachFirestoreListener();
  }

  Future<void> _loadFromLocalCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _readIds = (prefs.getStringList(_readIdsKey) ?? <String>[]).toSet();

      final raw = prefs.getString(_cacheKey);
      if (raw != null && raw.isNotEmpty) {
        final List<dynamic> decoded = jsonDecode(raw) as List<dynamic>;
        _notifications = decoded.map((e) {
          final item = NotificationItem.fromMap(e as Map<String, dynamic>);
          return item.copyWith(isRead: _readIds.contains(item.id));
        }).toList();
        _notifications.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        notifyListeners();
      }
    } catch (e) {
      debugPrint('[NotificationProvider] Cache load note: $e');
    }
  }

  Future<void> _saveToLocalCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_readIdsKey, _readIds.toList());
      final raw = jsonEncode(_notifications.map((n) => n.toMap()).toList());
      await prefs.setString(_cacheKey, raw);
    } catch (e) {
      debugPrint('[NotificationProvider] Cache save note: $e');
    }
  }

  void _attachFirestoreListener() {
    if (Firebase.apps.isEmpty) {
      _retryTimer?.cancel();
      _retryTimer = Timer.periodic(const Duration(milliseconds: 600), (t) {
        if (Firebase.apps.isNotEmpty) {
          t.cancel();
          _attachFirestoreListener();
        }
        if (t.tick > 25) {
          t.cancel();
        }
      });
      return;
    }

    try {
      _firestoreSubscription?.cancel();
      _firestoreSubscription = FirebaseFirestore.instance
          .collection('notifications')
          .snapshots()
          .listen(
            (snapshot) {
              final items = snapshot.docs.map((doc) {
                final item = NotificationItem.fromMap(doc.data(), doc.id);
                return item.copyWith(isRead: _readIds.contains(item.id));
              }).toList();

              _mergeAndPersist(items);
              debugPrint(
                '[NotificationProvider] Live Firestore synced ${items.length} bulletins (total stored: ${_notifications.length}).',
              );
            },
            onError: (error) {
              debugPrint(
                '[NotificationProvider] Firestore stream error: $error',
              );
            },
          );
    } catch (e) {
      debugPrint('[NotificationProvider] Error attaching listener: $e');
    }
  }

  void _mergeAndPersist(List<NotificationItem> incomingItems) {
    final Map<String, NotificationItem> map = {
      for (final n in _notifications) n.id: n,
    };

    for (final item in incomingItems) {
      final isRead =
          _readIds.contains(item.id) || (map[item.id]?.isRead ?? false);
      map[item.id] = item.copyWith(isRead: isRead);
    }

    final merged = map.values.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    _notifications = merged;
    _saveToLocalCache();
    notifyListeners();
  }

  /// Manually force-reconnect or refresh remote sync
  void syncRemote() {
    _attachFirestoreListener();
    refresh();
  }

  Future<void> refresh() async {
    _isLoading = true;
    notifyListeners();
    try {
      if (Firebase.apps.isNotEmpty) {
        QuerySnapshot<Map<String, dynamic>> snapshot;
        try {
          snapshot = await FirebaseFirestore.instance
              .collection('notifications')
              .get(const GetOptions(source: Source.server));
        } catch (_) {
          snapshot = await FirebaseFirestore.instance
              .collection('notifications')
              .get(const GetOptions(source: Source.serverAndCache));
        }

        final items = snapshot.docs.map((doc) {
          final item = NotificationItem.fromMap(doc.data(), doc.id);
          return item.copyWith(isRead: _readIds.contains(item.id));
        }).toList();

        _mergeAndPersist(items);
      }
    } catch (e) {
      debugPrint('[NotificationProvider] Refresh note: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Add incoming notification directly from push payloads
  void addNotificationLocally(NotificationItem item) {
    final existingIndex = _notifications.indexWhere((n) => n.id == item.id);
    if (existingIndex >= 0) {
      _notifications[existingIndex] = item;
    } else {
      _notifications.insert(0, item);
    }
    _notifications.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    _saveToLocalCache();
    notifyListeners();
  }

  /// Static helper for background isolates or direct writes
  static Future<void> saveNotificationDirectlyToDisk(
    NotificationItem item,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final readIds = (prefs.getStringList(_readIdsKey) ?? <String>[]).toSet();
      final raw = prefs.getString(_cacheKey);
      List<NotificationItem> list = [];
      if (raw != null && raw.isNotEmpty) {
        final List<dynamic> decoded = jsonDecode(raw) as List<dynamic>;
        list = decoded
            .map((e) => NotificationItem.fromMap(e as Map<String, dynamic>))
            .toList();
      }

      final existingIndex = list.indexWhere((n) => n.id == item.id);
      if (existingIndex >= 0) {
        list[existingIndex] = item;
      } else {
        list.insert(0, item);
      }
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      final updatedRaw = jsonEncode(list.map((n) => n.toMap()).toList());
      await prefs.setString(_cacheKey, updatedRaw);

      if (current != null) {
        current!.addNotificationLocally(
          item.copyWith(isRead: readIds.contains(item.id)),
        );
      }
    } catch (e) {
      debugPrint('[NotificationProvider] Static cache write note: $e');
    }
  }

  void markAsRead(String id) {
    _readIds.add(id);
    final idx = _notifications.indexWhere((n) => n.id == id);
    if (idx >= 0) {
      _notifications[idx] = _notifications[idx].copyWith(isRead: true);
      _saveToLocalCache();
      notifyListeners();
    }
  }

  void markAllAsRead() {
    for (final n in _notifications) {
      _readIds.add(n.id);
    }
    _notifications = _notifications
        .map((n) => n.copyWith(isRead: true))
        .toList();
    _saveToLocalCache();
    notifyListeners();
  }

  void deleteNotificationLocally(String id) {
    _notifications.removeWhere((n) => n.id == id);
    _readIds.remove(id);
    _saveToLocalCache();
    notifyListeners();
  }

  @override
  void dispose() {
    _retryTimer?.cancel();
    _firestoreSubscription?.cancel();
    if (current == this) {
      current = null;
    }
    super.dispose();
  }
}
