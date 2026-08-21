import 'package:flutter_test/flutter_test.dart';
import 'package:queuex/features/orders/domain/models/order_model.dart';

void main() {
  group('OrderModel Unit Tests', () {
    test('OrderStatus values and labels parse correctly', () {
      expect(OrderStatusX.fromString('pending'), OrderStatus.pending);
      expect(OrderStatusX.fromString('accepted'), OrderStatus.accepted);
      expect(OrderStatusX.fromString('preparing'), OrderStatus.preparing);
      expect(OrderStatusX.fromString('ready'), OrderStatus.ready);
      expect(OrderStatusX.fromString('completed'), OrderStatus.completed);
      expect(OrderStatusX.fromString('rejected'), OrderStatus.rejected);
      expect(OrderStatusX.fromString('cancelled'), OrderStatus.cancelled);

      expect(OrderStatus.pending.label, 'Pending');
      expect(OrderStatus.ready.label, 'Ready for Pickup');
    });

    test('PaymentMethod values and labels parse correctly', () {
      expect(PaymentMethodX.fromString('online'), PaymentMethod.online);
      expect(PaymentMethodX.fromString('offline'), PaymentMethod.offline);

      expect(PaymentMethod.online.label, contains('Online'));
      expect(PaymentMethod.offline.label, contains('Cash'));
    });

    test('OrderModel fromMap parses map correctly', () {
      final map = {
        'customerId': 'user_1',
        'stallId': 'stall_1',
        'slotId': 'slot_101',
        'totalAmount': 250.0,
        'status': 'pending',
        'paymentStatus': 'pending',
        'paymentMethod': 'online',
        'qrToken': 'QX-ABC123XYZ',
      };

      final order = OrderModel.fromMap(map, 'order_1');

      expect(order.orderId, 'order_1');
      expect(order.customerId, 'user_1');
      expect(order.totalAmount, 250.0);
      expect(order.status, OrderStatus.pending);
      expect(order.paymentMethod, PaymentMethod.online);
      expect(order.qrToken, 'QX-ABC123XYZ');
    });
  });
}
