import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/models/notification_model.dart';

abstract class NotificationRepository {
  Stream<List<NotificationModel>> streamUserNotifications(String userId);
  Future<void> sendNotification({
    required String userId,
    required String title,
    required String body,
    required NotificationType type,
    String? orderId,
  });
  Future<void> markAsRead(String notificationId);
  Future<void> markAllAsRead(String userId);
}

class FirebaseNotificationRepository implements NotificationRepository {
  final FirebaseFirestore _firestore;

  FirebaseNotificationRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Stream<List<NotificationModel>> streamUserNotifications(String userId) {
    if (userId.isEmpty) return Stream.value([]);

    return _firestore
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => NotificationModel.fromFirestore(doc))
            .toList()
          ..sort((a, b) => (b.createdAt ?? DateTime(2000))
              .compareTo(a.createdAt ?? DateTime(2000))));
  }

  @override
  Future<void> sendNotification({
    required String userId,
    required String title,
    required String body,
    required NotificationType type,
    String? orderId,
  }) async {
    final docRef = _firestore.collection('notifications').doc();
    final now = DateTime.now();

    final model = NotificationModel(
      notificationId: docRef.id,
      userId: userId,
      title: title,
      body: body,
      type: type,
      orderId: orderId,
      isRead: false,
      createdAt: now,
    );

    await docRef.set(model.toMap());
  }

  @override
  Future<void> markAsRead(String notificationId) async {
    if (notificationId.isEmpty) return;
    await _firestore
        .collection('notifications')
        .doc(notificationId)
        .update({'isRead': true});
  }

  @override
  Future<void> markAllAsRead(String userId) async {
    if (userId.isEmpty) return;

    final snapshot = await _firestore
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .get();

    final batch = _firestore.batch();
    for (final doc in snapshot.docs) {
      batch.update(doc.reference, {'isRead': true});
    }

    await batch.commit();
  }
}
