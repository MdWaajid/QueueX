import 'package:cloud_firestore/cloud_firestore.dart';

enum QrVerificationStatus {
  success,
  failed,
}

extension QrVerificationStatusX on QrVerificationStatus {
  String get value => name;

  static QrVerificationStatus fromString(String raw) {
    switch (raw.toLowerCase()) {
      case 'failed':
      case 'error':
        return QrVerificationStatus.failed;
      case 'success':
      default:
        return QrVerificationStatus.success;
    }
  }
}

class QrVerificationModel {
  final String verificationId;
  final String qrToken;
  final String orderId;
  final String stallId;
  final String ownerId;
  final DateTime? verifiedAt;
  final QrVerificationStatus status;

  const QrVerificationModel({
    required this.verificationId,
    required this.qrToken,
    required this.orderId,
    required this.stallId,
    required this.ownerId,
    this.verifiedAt,
    required this.status,
  });

  factory QrVerificationModel.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return QrVerificationModel.fromMap(data, doc.id);
  }

  factory QrVerificationModel.fromMap(Map<String, dynamic> map, String id) {
    return QrVerificationModel(
      verificationId: id,
      qrToken: map['qrToken'] as String? ?? '',
      orderId: map['orderId'] as String? ?? '',
      stallId: map['stallId'] as String? ?? '',
      ownerId: map['ownerId'] as String? ?? '',
      verifiedAt: map['verifiedAt'] != null
          ? (map['verifiedAt'] as Timestamp).toDate()
          : null,
      status: QrVerificationStatusX.fromString(map['status'] as String? ?? 'success'),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'verificationId': verificationId,
      'qrToken': qrToken,
      'orderId': orderId,
      'stallId': stallId,
      'ownerId': ownerId,
      'verifiedAt': verifiedAt != null ? Timestamp.fromDate(verifiedAt!) : null,
      'status': status.value,
    };
  }
}
