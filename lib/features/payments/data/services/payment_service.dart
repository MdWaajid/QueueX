import 'dart:math';

class PaymentResult {
  final bool isSuccess;
  final String transactionId;
  final String razorpayOrderId;
  final String razorpayPaymentId;
  final String razorpaySignature;
  final String? errorMessage;

  const PaymentResult({
    required this.isSuccess,
    this.transactionId = '',
    this.razorpayOrderId = '',
    this.razorpayPaymentId = '',
    this.razorpaySignature = '',
    this.errorMessage,
  });

  factory PaymentResult.success({
    required String transactionId,
    String razorpayOrderId = '',
    String razorpayPaymentId = '',
    String razorpaySignature = '',
  }) {
    return PaymentResult(
      isSuccess: true,
      transactionId: transactionId,
      razorpayOrderId: razorpayOrderId,
      razorpayPaymentId: razorpayPaymentId,
      razorpaySignature: razorpaySignature,
    );
  }

  factory PaymentResult.failure(String errorMessage) {
    return PaymentResult(
      isSuccess: false,
      errorMessage: errorMessage,
    );
  }
}

abstract class PaymentService {
  Future<PaymentResult> processOnlinePayment({
    required String orderId,
    required double amount,
    required String customerName,
    required String customerPhone,
  });

  Future<PaymentResult> processOfflinePayment({
    required String orderId,
    required double amount,
  });
}

class MockPaymentService implements PaymentService {
  final bool shouldSucceed;

  const MockPaymentService({this.shouldSucceed = true});

  @override
  Future<PaymentResult> processOnlinePayment({
    required String orderId,
    required double amount,
    required String customerName,
    required String customerPhone,
  }) async {
    // ignore: inference_failure_on_instance_creation
    await Future.delayed(const Duration(milliseconds: 1500));

    if (!shouldSucceed) {
      return PaymentResult.failure('Online payment transaction failed or cancelled by user.');
    }

    final random = Random();
    final rzpPaymentId = 'pay_${random.nextInt(89999999) + 10000000}';
    final rzpOrderId = 'order_rzp_${random.nextInt(899999) + 100000}';
    final rzpSig = 'sig_${random.nextInt(89999999) + 10000000}';

    return PaymentResult.success(
      transactionId: rzpPaymentId,
      razorpayOrderId: rzpOrderId,
      razorpayPaymentId: rzpPaymentId,
      razorpaySignature: rzpSig,
    );
  }

  @override
  Future<PaymentResult> processOfflinePayment({
    required String orderId,
    required double amount,
  }) async {
    // ignore: inference_failure_on_instance_creation
    await Future.delayed(const Duration(milliseconds: 300));
    final random = Random();
    final cashTxId = 'CASH-${random.nextInt(899999) + 100000}';

    return PaymentResult.success(
      transactionId: cashTxId,
    );
  }
}
