import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:queuex/features/orders/domain/models/order_model.dart';
import 'package:queuex/features/payments/data/repositories/payment_repository.dart';
import 'package:queuex/features/payments/data/services/payment_service.dart';
import 'package:queuex/features/payments/domain/models/payment_model.dart';
import 'package:queuex/features/payments/presentation/providers/payment_provider.dart';

class MockPaymentRepository implements PaymentRepository {
  @override
  Future<PaymentModel> verifyAndRecordPayment({
    required String orderId,
    required String customerId,
    required String stallId,
    required double amount,
    required PaymentMethod paymentMethod,
    String razorpayOrderId = '',
    String razorpayPaymentId = '',
    String razorpaySignature = '',
    PaymentRecordStatus status = PaymentRecordStatus.completed,
  }) async {
    return PaymentModel(
      paymentId: 'pay_rec_99',
      orderId: orderId,
      customerId: customerId,
      stallId: stallId,
      amount: amount,
      paymentMethod: paymentMethod,
      razorpayOrderId: razorpayOrderId,
      razorpayPaymentId: razorpayPaymentId,
      razorpaySignature: razorpaySignature,
      status: status,
      createdAt: DateTime.now(),
    );
  }

  @override
  Future<PaymentModel?> getPaymentByOrderId(String orderId) async => null;
}

void main() {
  group('PaymentProcessingNotifier Unit Tests', () {
    late ProviderContainer container;

    final fakeOrder = OrderModel(
      orderId: 'order_1',
      customerId: 'user_1',
      stallId: 'stall_1',
      slotId: 'slot_1',
      totalAmount: 200.0,
      status: OrderStatus.pending,
      paymentStatus: PaymentStatus.pending,
      paymentMethod: PaymentMethod.online,
      qrToken: 'QX-TOKEN123',
      slotStartTime: DateTime(2026, 8, 21, 10, 0),
      slotEndTime: DateTime(2026, 8, 21, 10, 15),
    );

    setUp(() {
      container = ProviderContainer(
        overrides: [
          paymentServiceProvider.overrideWithValue(
            const MockPaymentService(shouldSucceed: true),
          ),
          paymentRepositoryProvider.overrideWithValue(MockPaymentRepository()),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('Initial payment processing state is idle', () {
      final state = container.read(paymentProcessingProvider);
      expect(state, isA<PaymentProcessingIdleState>());
    });

    test('processPayment processes online payment successfully', () async {
      final notifier = container.read(paymentProcessingProvider.notifier);

      final payment = await notifier.processPayment(
        order: fakeOrder,
        customerName: 'Jane Doe',
        customerPhone: '+919999999999',
      );

      expect(payment, isNotNull);
      expect(payment!.paymentId, 'pay_rec_99');
      expect(payment.status, PaymentRecordStatus.completed);
      expect(container.read(paymentProcessingProvider),
          isA<PaymentProcessingSuccessState>());
    });
  });
}
