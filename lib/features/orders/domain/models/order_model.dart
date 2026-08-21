import 'package:cloud_firestore/cloud_firestore.dart';

enum OrderStatus {
  pending,
  accepted,
  preparing,
  ready,
  completed,
  rejected,
  cancelled,
  expired,
}

extension OrderStatusX on OrderStatus {
  String get value => name;

  String get label {
    switch (this) {
      case OrderStatus.pending:
        return 'Pending';
      case OrderStatus.accepted:
        return 'Accepted';
      case OrderStatus.preparing:
        return 'Preparing';
      case OrderStatus.ready:
        return 'Ready for Pickup';
      case OrderStatus.completed:
        return 'Completed';
      case OrderStatus.rejected:
        return 'Rejected';
      case OrderStatus.cancelled:
        return 'Cancelled';
      case OrderStatus.expired:
        return 'Expired';
    }
  }

  static OrderStatus fromString(String raw) {
    switch (raw.toLowerCase()) {
      case 'accepted':
        return OrderStatus.accepted;
      case 'preparing':
        return OrderStatus.preparing;
      case 'ready':
        return OrderStatus.ready;
      case 'completed':
        return OrderStatus.completed;
      case 'rejected':
        return OrderStatus.rejected;
      case 'cancelled':
        return OrderStatus.cancelled;
      case 'expired':
        return OrderStatus.expired;
      case 'pending':
      default:
        return OrderStatus.pending;
    }
  }
}

enum PaymentStatus {
  pending,
  paid,
  failed,
  refunded,
}

extension PaymentStatusX on PaymentStatus {
  String get value => name;

  static PaymentStatus fromString(String raw) {
    switch (raw.toLowerCase()) {
      case 'paid':
      case 'completed':
        return PaymentStatus.paid;
      case 'failed':
        return PaymentStatus.failed;
      case 'refunded':
        return PaymentStatus.refunded;
      case 'pending':
      default:
        return PaymentStatus.pending;
    }
  }
}

enum PaymentMethod {
  online,
  offline,
}

extension PaymentMethodX on PaymentMethod {
  String get value => name;

  String get label {
    switch (this) {
      case PaymentMethod.online:
        return 'Online Payment (UPI / Cards)';
      case PaymentMethod.offline:
        return 'Pay Cash at Stall Pickup';
    }
  }

  static PaymentMethod fromString(String raw) {
    switch (raw.toLowerCase()) {
      case 'offline':
      case 'cash':
        return PaymentMethod.offline;
      case 'online':
      default:
        return PaymentMethod.online;
    }
  }
}

class OrderModel {
  final String orderId;
  final String customerId;
  final String stallId;
  final String slotId;
  final double totalAmount;
  final OrderStatus status;
  final PaymentStatus paymentStatus;
  final PaymentMethod paymentMethod;
  final String qrToken;
  final DateTime slotStartTime;
  final DateTime slotEndTime;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const OrderModel({
    required this.orderId,
    required this.customerId,
    required this.stallId,
    required this.slotId,
    required this.totalAmount,
    required this.status,
    required this.paymentStatus,
    required this.paymentMethod,
    required this.qrToken,
    required this.slotStartTime,
    required this.slotEndTime,
    this.createdAt,
    this.updatedAt,
  });

  factory OrderModel.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return OrderModel.fromMap(data, doc.id);
  }

  factory OrderModel.fromMap(Map<String, dynamic> map, String id) {
    return OrderModel(
      orderId: id,
      customerId: map['customerId'] as String? ?? '',
      stallId: map['stallId'] as String? ?? '',
      slotId: map['slotId'] as String? ?? '',
      totalAmount: (map['totalAmount'] as num?)?.toDouble() ?? 0.0,
      status: OrderStatusX.fromString(map['status'] as String? ?? 'pending'),
      paymentStatus:
          PaymentStatusX.fromString(map['paymentStatus'] as String? ?? 'pending'),
      paymentMethod:
          PaymentMethodX.fromString(map['paymentMethod'] as String? ?? 'online'),
      qrToken: map['qrToken'] as String? ?? '',
      slotStartTime: map['slotStartTime'] != null
          ? (map['slotStartTime'] as Timestamp).toDate()
          : DateTime.now(),
      slotEndTime: map['slotEndTime'] != null
          ? (map['slotEndTime'] as Timestamp).toDate()
          : DateTime.now().add(const Duration(minutes: 15)),
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
      'orderId': orderId,
      'customerId': customerId,
      'stallId': stallId,
      'slotId': slotId,
      'totalAmount': totalAmount,
      'status': status.value,
      'paymentStatus': paymentStatus.value,
      'paymentMethod': paymentMethod.value,
      'qrToken': qrToken,
      'slotStartTime': Timestamp.fromDate(slotStartTime),
      'slotEndTime': Timestamp.fromDate(slotEndTime),
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : null,
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  OrderModel copyWith({
    String? orderId,
    String? customerId,
    String? stallId,
    String? slotId,
    double? totalAmount,
    OrderStatus? status,
    PaymentStatus? paymentStatus,
    PaymentMethod? paymentMethod,
    String? qrToken,
    DateTime? slotStartTime,
    DateTime? slotEndTime,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return OrderModel(
      orderId: orderId ?? this.orderId,
      customerId: customerId ?? this.customerId,
      stallId: stallId ?? this.stallId,
      slotId: slotId ?? this.slotId,
      totalAmount: totalAmount ?? this.totalAmount,
      status: status ?? this.status,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      qrToken: qrToken ?? this.qrToken,
      slotStartTime: slotStartTime ?? this.slotStartTime,
      slotEndTime: slotEndTime ?? this.slotEndTime,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
