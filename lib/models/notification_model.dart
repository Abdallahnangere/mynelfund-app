import 'package:flutter/cupertino.dart';
import '../core/theme/nelfund_colors.dart';

/// Notification model representing announcements, bulletins, and push updates.
class NotificationItem {
  final String id;
  final String title;
  final String body;
  final String badge;
  final String badgeColorHex;
  final String timestamp;
  final DateTime createdAt;
  final bool isRead;
  final String? actionUrl;

  const NotificationItem({
    required this.id,
    required this.title,
    required this.body,
    required this.badge,
    required this.badgeColorHex,
    required this.timestamp,
    required this.createdAt,
    this.isRead = false,
    this.actionUrl,
  });

  NotificationItem copyWith({
    String? id,
    String? title,
    String? body,
    String? badge,
    String? badgeColorHex,
    String? timestamp,
    DateTime? createdAt,
    bool? isRead,
    String? actionUrl,
  }) {
    return NotificationItem(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      badge: badge ?? this.badge,
      badgeColorHex: badgeColorHex ?? this.badgeColorHex,
      timestamp: timestamp ?? this.timestamp,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
      actionUrl: actionUrl ?? this.actionUrl,
    );
  }

  Color get badgeColor {
    try {
      final hex = badgeColorHex.replaceAll('#', '');
      if (hex.length == 6) {
        return Color(int.parse('0xFF$hex'));
      } else if (hex.length == 8) {
        return Color(int.parse('0x$hex'));
      }
    } catch (_) {}
    return NelfundColors.emerald;
  }

  factory NotificationItem.fromMap(Map<String, dynamic> map, [String? docId]) {
    DateTime parsedDate;
    final createdVal = map['createdAt'];
    if (createdVal is DateTime) {
      parsedDate = createdVal;
    } else if (createdVal != null && createdVal.runtimeType.toString().contains('Timestamp')) {
      // Handle cloud_firestore Timestamp dynamically
      try {
        parsedDate = (createdVal as dynamic).toDate();
      } catch (_) {
        parsedDate = DateTime.now();
      }
    } else if (createdVal is String) {
      parsedDate = DateTime.tryParse(createdVal) ?? DateTime.now();
    } else if (createdVal is int) {
      parsedDate = DateTime.fromMillisecondsSinceEpoch(createdVal);
    } else {
      parsedDate = DateTime.now();
    }

    return NotificationItem(
      id: docId ?? map['id']?.toString() ?? UniqueKey().toString(),
      title: map['title']?.toString() ?? 'Notification',
      body: map['body']?.toString() ?? '',
      badge: map['badge']?.toString() ?? 'Advisory',
      badgeColorHex: map['badgeColorHex']?.toString() ?? '#0D5C3A',
      timestamp: map['timestamp']?.toString() ?? '',
      createdAt: parsedDate,
      isRead: map['isRead'] == true,
      actionUrl: map['actionUrl']?.toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'badge': badge,
      'badgeColorHex': badgeColorHex,
      'timestamp': timestamp,
      'createdAt': createdAt.toIso8601String(),
      'isRead': isRead,
      'actionUrl': actionUrl,
    };
  }
}
