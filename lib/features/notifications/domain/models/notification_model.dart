import 'package:cloud_firestore/cloud_firestore.dart';

enum NotificationType {
  orderStatus,
  paymentUpdate,
  system,
}

extension NotificationTypeX on NotificationType {
  String get value => name;

  static NotificationType fromString(String raw) {
    switch (raw.toLowerCase()) {
      case 'payment_update':
      case 'paymentupdate':
      case 'payment':
        return NotificationType.paymentUpdate;
      case 'system':
        return NotificationType.system;
      case 'order_status':
      case 'orderstatus':
      case 'order':
      default:
        return NotificationType.orderStatus;
    }
  }
}

class NotificationModel {
  final String notificationId;
  final String userId;
  final String title;
  final String body;
  final NotificationType type;
  final String? orderId;
  final bool isRead;
  final DateTime? createdAt;

  const NotificationModel({
    required this.notificationId,
    required this.userId,
    required this.title,
    required this.body,
    required this.type,
    this.orderId,
    this.isRead = false,
    this.createdAt,
  });

  factory NotificationModel.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return NotificationModel.fromMap(data, doc.id);
  }

  factory NotificationModel.fromMap(Map<String, dynamic> map, String id) {
    return NotificationModel(
      notificationId: id,
      userId: map['userId'] as String? ?? '',
      title: map['title'] as String? ?? '',
      body: map['body'] as String? ?? '',
      type: NotificationTypeX.fromString(map['type'] as String? ?? 'order_status'),
      orderId: map['orderId'] as String?,
      isRead: map['isRead'] as bool? ?? false,
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'notificationId': notificationId,
      'userId': userId,
      'title': title,
      'body': body,
      'type': type.value,
      'orderId': orderId,
      'isRead': isRead,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : null,
    };
  }

  NotificationModel copyWith({
    String? notificationId,
    String? userId,
    String? title,
    String? body,
    NotificationType? type,
    String? orderId,
    bool? isRead,
    DateTime? createdAt,
  }) {
    return NotificationModel(
      notificationId: notificationId ?? this.notificationId,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      body: body ?? this.body,
      type: type ?? this.type,
      orderId: orderId ?? this.orderId,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
