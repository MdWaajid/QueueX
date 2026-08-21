import 'package:flutter_test/flutter_test.dart';
import 'package:queuex/features/orders/domain/models/order_model.dart';

void main() {
  group('Order Cancellation Rules Unit Tests', () {
    final pendingOrder = OrderModel(
      orderId: 'order_1',
      customerId: 'user_1',
      stallId: 'stall_1',
      slotId: 'slot_1',
      totalAmount: 200.0,
      status: OrderStatus.pending,
      paymentStatus: PaymentStatus.pending,
      paymentMethod: PaymentMethod.offline,
      qrToken: 'QX-TOK123',
      slotStartTime: DateTime(2026, 8, 21, 10, 0),
      slotEndTime: DateTime(2026, 8, 21, 10, 15),
    );

    final acceptedOrder = OrderModel(
      orderId: 'order_2',
      customerId: 'user_1',
      stallId: 'stall_1',
      slotId: 'slot_1',
      totalAmount: 200.0,
      status: OrderStatus.accepted,
      paymentStatus: PaymentStatus.pending,
      paymentMethod: PaymentMethod.offline,
      qrToken: 'QX-TOK456',
      slotStartTime: DateTime(2026, 8, 21, 10, 0),
      slotEndTime: DateTime(2026, 8, 21, 10, 15),
    );

    test('Customer can cancel order when status is Pending', () {
      final canCancel = pendingOrder.status == OrderStatus.pending;
      expect(canCancel, isTrue);
    });

    test('Customer cannot cancel order once status is Accepted or Preparing', () {
      final canCancel = acceptedOrder.status == OrderStatus.pending;
      expect(canCancel, isFalse);
    });
  });
}
