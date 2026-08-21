import 'package:flutter_test/flutter_test.dart';
import 'package:queuex/features/orders/domain/models/order_model.dart';
import 'package:queuex/features/qr/domain/services/qr_validation_service.dart';

void main() {
  group('QrValidationService Unit Tests', () {
    final baseSlotEnd = DateTime(2026, 8, 21, 10, 15);

    final validOrder = OrderModel(
      orderId: 'order_1',
      customerId: 'user_1',
      stallId: 'stall_1',
      slotId: 'slot_1',
      totalAmount: 150.0,
      status: OrderStatus.accepted,
      paymentStatus: PaymentStatus.paid,
      paymentMethod: PaymentMethod.online,
      qrToken: 'QX-VALIDTOKEN123',
      slotStartTime: DateTime(2026, 8, 21, 10, 0),
      slotEndTime: baseSlotEnd,
    );

    test('validate returns valid when within 15 minute grace period', () {
      // 10:20 AM is 5 minutes after slot end (10:15 AM), well within 15 min grace (until 10:30 AM)
      final currentTime = DateTime(2026, 8, 21, 10, 20);

      final result = QrValidationService.validate(
        order: validOrder,
        targetStallId: 'stall_1',
        currentTime: currentTime,
      );

      expect(result.isValid, isTrue);
      expect(result.reason, 'Valid for Pickup');
      expect(result.remainingGraceMinutes, 10);
    });

    test('validate returns invalid when current time is after slot end + 15 min grace', () {
      // 10:31 AM is past 10:30 AM (slot end + 15 min grace)
      final currentTime = DateTime(2026, 8, 21, 10, 31);

      final result = QrValidationService.validate(
        order: validOrder,
        targetStallId: 'stall_1',
        currentTime: currentTime,
      );

      expect(result.isValid, isFalse);
      expect(result.reason, contains('expired'));
    });

    test('validate returns invalid when QR token has already been verified', () {
      final result = QrValidationService.validate(
        order: validOrder,
        targetStallId: 'stall_1',
        isAlreadyVerified: true,
        currentTime: DateTime(2026, 8, 21, 10, 10),
      );

      expect(result.isValid, isFalse);
      expect(result.reason, contains('already been verified'));
    });

    test('validate returns invalid when stallId does not match', () {
      final result = QrValidationService.validate(
        order: validOrder,
        targetStallId: 'stall_different',
        currentTime: DateTime(2026, 8, 21, 10, 10),
      );

      expect(result.isValid, isFalse);
      expect(result.reason, contains('does not belong to this stall'));
    });

    test('validate returns invalid when online payment is not paid', () {
      final unpaidOrder = OrderModel(
        orderId: 'order_2',
        customerId: 'user_1',
        stallId: 'stall_1',
        slotId: 'slot_1',
        totalAmount: 150.0,
        status: OrderStatus.pending,
        paymentStatus: PaymentStatus.pending,
        paymentMethod: PaymentMethod.online,
        qrToken: 'QX-UNPAIDTOKEN',
        slotStartTime: DateTime(2026, 8, 21, 10, 0),
        slotEndTime: baseSlotEnd,
      );

      final result = QrValidationService.validate(
        order: unpaidOrder,
        targetStallId: 'stall_1',
        currentTime: DateTime(2026, 8, 21, 10, 10),
      );

      expect(result.isValid, isFalse);
      expect(result.reason, contains('Online payment has not been completed'));
    });
  });
}
