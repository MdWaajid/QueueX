import '../../../orders/domain/models/order_model.dart';

class QrValidationResult {
  final bool isValid;
  final String reason;
  final DateTime expirationTime;
  final int remainingGraceMinutes;

  const QrValidationResult({
    required this.isValid,
    required this.reason,
    required this.expirationTime,
    required this.remainingGraceMinutes,
  });

  factory QrValidationResult.valid({
    required DateTime expirationTime,
    required int remainingGraceMinutes,
  }) {
    return QrValidationResult(
      isValid: true,
      reason: 'Valid for Pickup',
      expirationTime: expirationTime,
      remainingGraceMinutes: remainingGraceMinutes,
    );
  }

  factory QrValidationResult.invalid({
    required String reason,
    required DateTime expirationTime,
  }) {
    return QrValidationResult(
      isValid: false,
      reason: reason,
      expirationTime: expirationTime,
      remainingGraceMinutes: 0,
    );
  }
}

class QrValidationService {
  static const Duration gracePeriod = Duration(minutes: 15);

  static QrValidationResult validate({
    required OrderModel order,
    required String targetStallId,
    bool isAlreadyVerified = false,
    DateTime? currentTime,
  }) {
    final now = currentTime ?? DateTime.now();
    final expirationTime = order.slotEndTime.add(gracePeriod);

    // Rule 1: Token exists & non-empty
    if (order.qrToken.isEmpty) {
      return QrValidationResult.invalid(
        reason: 'Missing or empty QR token',
        expirationTime: expirationTime,
      );
    }

    // Rule 2: Stall ID match
    if (targetStallId.isNotEmpty && order.stallId != targetStallId) {
      return QrValidationResult.invalid(
        reason: 'QR token does not belong to this stall',
        expirationTime: expirationTime,
      );
    }

    // Rule 3: Single-use verification check
    if (isAlreadyVerified) {
      return QrValidationResult.invalid(
        reason: 'QR token has already been verified/redeemed',
        expirationTime: expirationTime,
      );
    }

    // Rule 4: Expiration grace period check (current time before slot end + 15 min)
    if (now.isAfter(expirationTime)) {
      return QrValidationResult.invalid(
        reason: 'QR token expired (past slot end time + 15 minute grace period)',
        expirationTime: expirationTime,
      );
    }

    // Rule 5: Order status eligibility
    final ineligibleStatuses = [
      OrderStatus.completed,
      OrderStatus.rejected,
      OrderStatus.cancelled,
      OrderStatus.expired,
    ];
    if (ineligibleStatuses.contains(order.status)) {
      return QrValidationResult.invalid(
        reason: 'Order status (${order.status.label}) is not eligible for pickup',
        expirationTime: expirationTime,
      );
    }

    // Rule 6: Payment conditions check
    if (order.paymentMethod == PaymentMethod.online &&
        order.paymentStatus != PaymentStatus.paid) {
      return QrValidationResult.invalid(
        reason: 'Online payment has not been completed',
        expirationTime: expirationTime,
      );
    }

    final diff = expirationTime.difference(now);
    final remainingMins = diff.inMinutes > 0 ? diff.inMinutes : 0;

    return QrValidationResult.valid(
      expirationTime: expirationTime,
      remainingGraceMinutes: remainingMins,
    );
  }
}
