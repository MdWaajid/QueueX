import 'package:flutter_test/flutter_test.dart';
import 'package:queuex/features/notifications/domain/models/notification_model.dart';

void main() {
  group('NotificationModel Unit Tests', () {
    test('NotificationType parsing from string works correctly', () {
      expect(NotificationTypeX.fromString('order_status'), NotificationType.orderStatus);
      expect(NotificationTypeX.fromString('payment_update'), NotificationType.paymentUpdate);
      expect(NotificationTypeX.fromString('system'), NotificationType.system);
    });

    test('NotificationModel fromMap parses map fields correctly', () {
      final map = {
        'userId': 'user_1',
        'title': 'Order Accepted',
        'body': 'Your order #123 has been accepted by the stall.',
        'type': 'order_status',
        'orderId': 'order_123',
        'isRead': false,
      };

      final model = NotificationModel.fromMap(map, 'notif_1');

      expect(model.notificationId, 'notif_1');
      expect(model.userId, 'user_1');
      expect(model.title, 'Order Accepted');
      expect(model.type, NotificationType.orderStatus);
      expect(model.isRead, isFalse);
    });
  });
}
