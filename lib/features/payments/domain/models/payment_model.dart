import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../orders/domain/models/order_model.dart';

enum PaymentRecordStatus {
  pending,
  completed,
  failed,
  refunded,
}

extension PaymentRecordStatusX on PaymentRecordStatus {
  String get value => name;

  String get label {
    switch (this) {
      case PaymentRecordStatus.pending:
        return 'Pending';
      case PaymentRecordStatus.completed:
        return 'Paid';
      case PaymentRecordStatus.failed:
        return 'Failed';
      case PaymentRecordStatus.refunded:
        return 'Refunded';
    }
  }

  static PaymentRecordStatus fromString(String raw) {
    switch (raw.toLowerCase()) {
      case 'completed':
      case 'paid':
      case 'success':
        return PaymentRecordStatus.completed;
      case 'failed':
        return PaymentRecordStatus.failed;
      case 'refunded':
        return PaymentRecordStatus.refunded;
      case 'pending':
      default:
        return PaymentRecordStatus.pending;
    }
  }
}

class PaymentModel {
  final String paymentId;
  final String orderId;
  final String customerId;
  final String stallId;
  final double amount;
  final PaymentMethod paymentMethod;
  final String razorpayOrderId;
  final String razorpayPaymentId;
  final String razorpaySignature;
  final PaymentRecordStatus status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const PaymentModel({
    required this.paymentId,
    required this.orderId,
    required this.customerId,
    required this.stallId,
    required this.amount,
    required this.paymentMethod,
    this.razorpayOrderId = '',
    this.razorpayPaymentId = '',
    this.razorpaySignature = '',
    required this.status,
    this.createdAt,
    this.updatedAt,
  });

  factory PaymentModel.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return PaymentModel.fromMap(data, doc.id);
  }

  factory PaymentModel.fromMap(Map<String, dynamic> map, String id) {
    return PaymentModel(
      paymentId: id,
      orderId: map['orderId'] as String? ?? '',
      customerId: map['customerId'] as String? ?? '',
      stallId: map['stallId'] as String? ?? '',
      amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
      paymentMethod: PaymentMethodX.fromString(map['paymentMethod'] as String? ?? 'online'),
      razorpayOrderId: map['razorpayOrderId'] as String? ?? '',
      razorpayPaymentId: map['razorpayPaymentId'] as String? ?? '',
      razorpaySignature: map['razorpaySignature'] as String? ?? '',
      status: PaymentRecordStatusX.fromString(map['status'] as String? ?? 'pending'),
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] as Timestamp).toDate()
          : null,
      updatedAt: map['updatedAt'] != null
          ? (map['updatedAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'paymentId': paymentId,
      'orderId': orderId,
      'customerId': customerId,
      'stallId': stallId,
      'amount': amount,
      'paymentMethod': paymentMethod.value,
      'razorpayOrderId': razorpayOrderId,
      'razorpayPaymentId': razorpayPaymentId,
      'razorpaySignature': razorpaySignature,
      'status': status.value,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : null,
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }
}
