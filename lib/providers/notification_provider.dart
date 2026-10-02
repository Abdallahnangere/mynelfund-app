import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/notification_model.dart';

class NotificationProvider extends ChangeNotifier {
  static const String _cacheKey = 'cached_notifications_v1';
  static const String _readIdsKey = 'read_notification_ids_v1';

  List<NotificationItem> _notifications = [];
  Set<String> _readIds = {};
  bool _isLoading = false;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _firestoreSubscription;

  NotificationProvider() {
    _initialize();
  }

  List<NotificationItem> get notifications => List.unmodifiable(_notifications);
  int get unreadCount => _notifications.where((n) => !n.isRead).length;
  bool get hasUnread => unreadCount > 0;
  bool get isLoading => _isLoading;

  Future<void> _initialize() async {
    // 1. Immediately load local cache and read IDs
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
    try {
      if (Firebase.apps.isEmpty) return;

      _firestoreSubscription?.cancel();
      _firestoreSubscription = FirebaseFirestore.instance
          .collection('notifications')
          .orderBy('createdAt', descending: true)
          .snapshots()
          .listen(
        (snapshot) {
          final items = snapshot.docs.map((doc) {
            final item = NotificationItem.fromMap(doc.data(), doc.id);
            return item.copyWith(isRead: _readIds.contains(item.id));
          }).toList();

          _notifications = items;
          _saveToLocalCache();
          notifyListeners();
          debugPrint('[NotificationProvider] Synced ${items.length} notifications from Firestore.');
        },
        onError: (error) {
          debugPrint('[NotificationProvider] Firestore stream note (offline/cache): $error');
        },
      );
    } catch (e) {
      debugPrint('[NotificationProvider] Firebase note: $e');
    }
  }

  Future<void> refresh() async {
    _isLoading = true;
    notifyListeners();
    try {
      if (Firebase.apps.isNotEmpty) {
        final snapshot = await FirebaseFirestore.instance
            .collection('notifications')
            .orderBy('createdAt', descending: true)
            .get();

        final items = snapshot.docs.map((doc) {
          final item = NotificationItem.fromMap(doc.data(), doc.id);
          return item.copyWith(isRead: _readIds.contains(item.id));
        }).toList();

        _notifications = items;
        await _saveToLocalCache();
      }
    } catch (e) {
      debugPrint('[NotificationProvider] Refresh note: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void addNotificationLocally(NotificationItem item) {
    final existingIndex = _notifications.indexWhere((n) => n.id == item.id);
    if (existingIndex >= 0) {
      _notifications[existingIndex] = item;
    } else {
      _notifications.insert(0, item);
    }
    _saveToLocalCache();
    notifyListeners();
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
    _notifications = _notifications.map((n) => n.copyWith(isRead: true)).toList();
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
    _firestoreSubscription?.cancel();
    super.dispose();
  }
}
