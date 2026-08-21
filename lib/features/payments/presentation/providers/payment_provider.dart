import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/payment_repository.dart';
import '../../data/services/payment_service.dart';
import '../../../orders/domain/models/order_model.dart';
import '../../domain/models/payment_model.dart';

final paymentServiceProvider = Provider<PaymentService>((ref) {
  return const MockPaymentService();
});

final paymentRepositoryProvider = Provider<PaymentRepository>((ref) {
  return FirebasePaymentRepository();
});

sealed class PaymentProcessingState {
  const PaymentProcessingState();
}

class PaymentProcessingIdleState extends PaymentProcessingState {
  const PaymentProcessingIdleState();
}

class PaymentProcessingLoadingState extends PaymentProcessingState {
  const PaymentProcessingLoadingState();
}

class PaymentProcessingSuccessState extends PaymentProcessingState {
  final PaymentModel payment;
  const PaymentProcessingSuccessState(this.payment);
}

class PaymentProcessingFailedState extends PaymentProcessingState {
  final String errorMessage;
  const PaymentProcessingFailedState(this.errorMessage);
}

class PaymentProcessingNotifier extends Notifier<PaymentProcessingState> {
  @override
  PaymentProcessingState build() => const PaymentProcessingIdleState();

  Future<PaymentModel?> processPayment({
    required OrderModel order,
    required String customerName,
    required String customerPhone,
  }) async {
    state = const PaymentProcessingLoadingState();

    try {
      final service = ref.read(paymentServiceProvider);
      final repository = ref.read(paymentRepositoryProvider);

      PaymentResult result;
      if (order.paymentMethod == PaymentMethod.online) {
        result = await service.processOnlinePayment(
          orderId: order.orderId,
          amount: order.totalAmount,
          customerName: customerName,
          customerPhone: customerPhone,
        );
      } else {
        result = await service.processOfflinePayment(
          orderId: order.orderId,
          amount: order.totalAmount,
        );
      }

      if (!result.isSuccess) {
        state = PaymentProcessingFailedState(
            result.errorMessage ?? 'Payment process failed.');
        return null;
      }

      final paymentRecord = await repository.verifyAndRecordPayment(
        orderId: order.orderId,
        customerId: order.customerId,
        stallId: order.stallId,
        amount: order.totalAmount,
        paymentMethod: order.paymentMethod,
        razorpayOrderId: result.razorpayOrderId,
        razorpayPaymentId: result.razorpayPaymentId,
        razorpaySignature: result.razorpaySignature,
        status: PaymentRecordStatus.completed,
      );

      state = PaymentProcessingSuccessState(paymentRecord);
      return paymentRecord;
    } catch (e) {
      state = PaymentProcessingFailedState(e.toString());
      return null;
    }
  }

  void reset() {
    state = const PaymentProcessingIdleState();
  }
}

final paymentProcessingProvider =
    NotifierProvider<PaymentProcessingNotifier, PaymentProcessingState>(
        PaymentProcessingNotifier.new);

final paymentDetailsProvider =
    FutureProvider.family<PaymentModel?, String>((ref, orderId) async {
  final repository = ref.watch(paymentRepositoryProvider);
  return repository.getPaymentByOrderId(orderId);
});
