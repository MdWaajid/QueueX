import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../orders/domain/models/order_model.dart';
import '../../domain/models/qr_verification_model.dart';
import '../../domain/services/qr_validation_service.dart';

abstract class QrRepository {
  Future<QrVerificationModel?> getVerificationByToken(String qrToken);
  Future<QrVerificationModel> verifyAndRedeemToken({
    required String qrToken,
    required String stallId,
    required String ownerId,
  });
}

class FirebaseQrRepository implements QrRepository {
  final FirebaseFirestore _firestore;

  FirebaseQrRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<QrVerificationModel?> getVerificationByToken(String qrToken) async {
    if (qrToken.isEmpty) return null;

    final snapshot = await _firestore
        .collection('qrVerifications')
        .where('qrToken', isEqualTo: qrToken)
        .where('status', isEqualTo: QrVerificationStatus.success.value)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return null;
    return QrVerificationModel.fromFirestore(snapshot.docs.first);
  }

  @override
  Future<QrVerificationModel> verifyAndRedeemToken({
    required String qrToken,
    required String stallId,
    required String ownerId,
  }) async {
    final cleanToken = qrToken.trim();
    if (cleanToken.isEmpty) {
      throw Exception('QR Token cannot be empty.');
    }

    // Query Order matching token
    final orderSnapshot = await _firestore
        .collection('orders')
        .where('qrToken', isEqualTo: cleanToken)
        .limit(1)
        .get();

    if (orderSnapshot.docs.isEmpty) {
      throw Exception('Invalid QR Token. No matching order found.');
    }

    final orderDoc = orderSnapshot.docs.first;
    final order = OrderModel.fromFirestore(orderDoc);

    // Check single-use verification in qrVerifications collection
    final existingVerification = await getVerificationByToken(cleanToken);
    final isAlreadyVerified = existingVerification != null;

    // Validate 7-point rules
    final validation = QrValidationService.validate(
      order: order,
      targetStallId: stallId,
      isAlreadyVerified: isAlreadyVerified,
    );

    if (!validation.isValid) {
      throw Exception(validation.reason);
    }

    final verificationRef = _firestore.collection('qrVerifications').doc();
    final orderRef = _firestore.collection('orders').doc(order.orderId);
    final now = DateTime.now();

    final verificationModel = QrVerificationModel(
      verificationId: verificationRef.id,
      qrToken: cleanToken,
      orderId: order.orderId,
      stallId: stallId,
      ownerId: ownerId,
      verifiedAt: now,
      status: QrVerificationStatus.success,
    );

    // Idempotent & Atomic Transaction
    await _firestore.runTransaction((transaction) async {
      transaction.set(verificationRef, verificationModel.toMap());

      transaction.update(orderRef, {
        'status': OrderStatus.completed.value,
        'paymentStatus': PaymentStatus.paid.value,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });

    return verificationModel;
  }
}
