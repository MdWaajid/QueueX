import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../orders/domain/models/order_model.dart';
import '../../domain/models/payment_model.dart';

abstract class PaymentRepository {
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
  });

  Future<PaymentModel?> getPaymentByOrderId(String orderId);
}

class FirebasePaymentRepository implements PaymentRepository {
  final FirebaseFirestore _firestore;

  FirebasePaymentRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

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
    final paymentRef = _firestore.collection('payments').doc();
    final orderRef = _firestore.collection('orders').doc(orderId);
    final now = DateTime.now();

    final paymentRecord = PaymentModel(
      paymentId: paymentRef.id,
      orderId: orderId,
      customerId: customerId,
      stallId: stallId,
      amount: amount,
      paymentMethod: paymentMethod,
      razorpayOrderId: razorpayOrderId,
      razorpayPaymentId: razorpayPaymentId,
      razorpaySignature: razorpaySignature,
      status: status,
      createdAt: now,
      updatedAt: now,
    );

    // Idempotent Transaction
    await _firestore.runTransaction((transaction) async {
      transaction.set(paymentRef, paymentRecord.toMap());

      if (status == PaymentRecordStatus.completed) {
        transaction.update(orderRef, {
          'paymentStatus': PaymentStatus.paid.value,
          'status': OrderStatus.accepted.value,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    });

    return paymentRecord;
  }

  @override
  Future<PaymentModel?> getPaymentByOrderId(String orderId) async {
    final snapshot = await _firestore
        .collection('payments')
        .where('orderId', isEqualTo: orderId)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return null;
    return PaymentModel.fromFirestore(snapshot.docs.first);
  }
}
