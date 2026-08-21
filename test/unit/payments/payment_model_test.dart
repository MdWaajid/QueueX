import 'package:flutter_test/flutter_test.dart';
import 'package:queuex/features/orders/domain/models/order_model.dart';
import 'package:queuex/features/payments/domain/models/payment_model.dart';

void main() {
  group('PaymentModel Unit Tests', () {
    test('PaymentRecordStatus parsing works correctly', () {
      expect(PaymentRecordStatusX.fromString('completed'), PaymentRecordStatus.completed);
      expect(PaymentRecordStatusX.fromString('paid'), PaymentRecordStatus.completed);
      expect(PaymentRecordStatusX.fromString('failed'), PaymentRecordStatus.failed);
      expect(PaymentRecordStatusX.fromString('pending'), PaymentRecordStatus.pending);

      expect(PaymentRecordStatus.completed.label, 'Paid');
    });

    test('PaymentModel fromMap parses map correctly', () {
      final map = {
        'orderId': 'order_1',
        'customerId': 'user_1',
        'stallId': 'stall_1',
        'amount': 350.0,
        'paymentMethod': 'online',
        'razorpayOrderId': 'order_rzp_123',
        'razorpayPaymentId': 'pay_123',
        'razorpaySignature': 'sig_123',
        'status': 'completed',
      };

      final payment = PaymentModel.fromMap(map, 'pay_rec_1');

      expect(payment.paymentId, 'pay_rec_1');
      expect(payment.orderId, 'order_1');
      expect(payment.amount, 350.0);
      expect(payment.paymentMethod, PaymentMethod.online);
      expect(payment.razorpayPaymentId, 'pay_123');
      expect(payment.status, PaymentRecordStatus.completed);
    });
  });
}
