import 'package:flutter_test/flutter_test.dart';
import 'package:queuex/features/orders/domain/models/order_model.dart';

void main() {
  group('Owner Order State Transition Rules Unit Tests', () {
    final pendingOrder = OrderModel(
      orderId: 'order_1',
      customerId: 'user_1',
      stallId: 'stall_1',
      slotId: 'slot_1',
      totalAmount: 250.0,
      status: OrderStatus.pending,
      paymentStatus: PaymentStatus.pending,
      paymentMethod: PaymentMethod.online,
      qrToken: 'QX-TOKEN1',
      slotStartTime: DateTime(2026, 8, 21, 10, 0),
      slotEndTime: DateTime(2026, 8, 21, 10, 15),
    );

    final acceptedOrder = pendingOrder.copyWith(status: OrderStatus.accepted);
    final preparingOrder = pendingOrder.copyWith(status: OrderStatus.preparing);
    final readyOrder = pendingOrder.copyWith(status: OrderStatus.ready);

    bool isValidTransition(OrderStatus current, OrderStatus next) {
      return (current == OrderStatus.pending &&
              (next == OrderStatus.accepted || next == OrderStatus.rejected)) ||
          (current == OrderStatus.accepted && next == OrderStatus.preparing) ||
          (current == OrderStatus.preparing && next == OrderStatus.ready) ||
          (current == OrderStatus.ready && next == OrderStatus.completed);
    }

    test('Pending can transition to Accepted or Rejected', () {
      expect(isValidTransition(pendingOrder.status, OrderStatus.accepted), isTrue);
      expect(isValidTransition(pendingOrder.status, OrderStatus.rejected), isTrue);
      expect(isValidTransition(pendingOrder.status, OrderStatus.completed), isFalse);
    });

    test('Accepted can transition to Preparing', () {
      expect(isValidTransition(acceptedOrder.status, OrderStatus.preparing), isTrue);
      expect(isValidTransition(acceptedOrder.status, OrderStatus.ready), isFalse);
    });

    test('Preparing can transition to Ready', () {
      expect(isValidTransition(preparingOrder.status, OrderStatus.ready), isTrue);
      expect(isValidTransition(preparingOrder.status, OrderStatus.completed), isFalse);
    });

    test('Ready can transition to Completed', () {
      expect(isValidTransition(readyOrder.status, OrderStatus.completed), isTrue);
      expect(isValidTransition(readyOrder.status, OrderStatus.accepted), isFalse);
    });
  });
}
