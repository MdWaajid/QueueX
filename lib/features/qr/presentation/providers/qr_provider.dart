import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/qr_repository.dart';
import '../../domain/models/qr_verification_model.dart';
import '../../domain/services/qr_validation_service.dart';
import '../../../orders/domain/models/order_model.dart';
import '../../../orders/presentation/providers/order_provider.dart';

final qrRepositoryProvider = Provider<QrRepository>((ref) {
  return FirebaseQrRepository();
});

final qrValidationProvider =
    FutureProvider.family<QrValidationResult, OrderModel>((ref, order) async {
  final repository = ref.watch(qrRepositoryProvider);
  final verification = await repository.getVerificationByToken(order.qrToken);
  final isVerified = verification != null;

  return QrValidationService.validate(
    order: order,
    targetStallId: order.stallId,
    isAlreadyVerified: isVerified,
  );
});

sealed class QrRedemptionState {
  const QrRedemptionState();
}

class QrRedemptionIdleState extends QrRedemptionState {
  const QrRedemptionIdleState();
}

class QrRedemptionLoadingState extends QrRedemptionState {
  const QrRedemptionLoadingState();
}

class QrRedemptionSuccessState extends QrRedemptionState {
  final OrderModel order;
  final QrVerificationModel verification;
  const QrRedemptionSuccessState(this.order, this.verification);
}

class QrRedemptionErrorState extends QrRedemptionState {
  final String message;
  const QrRedemptionErrorState(this.message);
}

class QrRedemptionNotifier extends Notifier<QrRedemptionState> {
  @override
  QrRedemptionState build() => const QrRedemptionIdleState();

  Future<QrVerificationModel?> redeemToken({
    required String qrToken,
    required String stallId,
    required String ownerId,
  }) async {
    state = const QrRedemptionLoadingState();

    try {
      final repository = ref.read(qrRepositoryProvider);
      final orderRepository = ref.read(orderRepositoryProvider);

      final verification = await repository.verifyAndRedeemToken(
        qrToken: qrToken,
        stallId: stallId,
        ownerId: ownerId,
      );

      final order = await orderRepository.getOrderById(verification.orderId);

      if (order != null) {
        state = QrRedemptionSuccessState(order, verification);
      } else {
        state = const QrRedemptionErrorState('Verification recorded, but order details could not be loaded.');
      }

      return verification;
    } catch (e) {
      state = QrRedemptionErrorState(e.toString().replaceAll('Exception: ', ''));
      return null;
    }
  }

  void reset() {
    state = const QrRedemptionIdleState();
  }
}

final qrRedemptionProvider =
    NotifierProvider<QrRedemptionNotifier, QrRedemptionState>(
        QrRedemptionNotifier.new);
