import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:queuex/features/orders/data/repositories/order_repository.dart';
import 'package:queuex/features/orders/domain/models/order_item_model.dart';
import 'package:queuex/features/orders/domain/models/order_model.dart';
import 'package:queuex/features/orders/presentation/providers/order_provider.dart';
import 'package:queuex/features/qr/data/repositories/qr_repository.dart';
import 'package:queuex/features/qr/domain/models/qr_verification_model.dart';
import 'package:queuex/features/qr/presentation/providers/qr_provider.dart';

class MockQrRepository implements QrRepository {
  bool shouldFail;

  MockQrRepository({this.shouldFail = false});

  @override
  Future<QrVerificationModel?> getVerificationByToken(String qrToken) async => null;

  @override
  Future<QrVerificationModel> verifyAndRedeemToken({
    required String qrToken,
    required String stallId,
    required String ownerId,
  }) async {
    if (shouldFail) {
      throw Exception('QR token has already been verified/redeemed');
    }
    return QrVerificationModel(
      verificationId: 'ver_999',
      qrToken: qrToken,
      orderId: 'order_1',
      stallId: stallId,
      ownerId: ownerId,
      verifiedAt: DateTime.now(),
      status: QrVerificationStatus.success,
    );
  }
}

class MockOrderRepositoryForQr implements OrderRepository {
  final OrderModel _fakeOrder = OrderModel(
    orderId: 'order_1',
    customerId: 'user_1',
    stallId: 'stall_1',
    slotId: 'slot_1',
    totalAmount: 250.0,
    status: OrderStatus.completed,
    paymentStatus: PaymentStatus.paid,
    paymentMethod: PaymentMethod.online,
    qrToken: 'QX-TESTTOKEN',
    slotStartTime: DateTime.now(),
    slotEndTime: DateTime.now().add(const Duration(minutes: 15)),
  );

  @override
  Future<OrderModel?> getOrderById(String orderId) async => _fakeOrder;

  @override
  Future<OrderModel> createOrder({
    required String customerId,
    required String stallId,
    required String slotId,
    required DateTime slotStartTime,
    required DateTime slotEndTime,
    required double totalAmount,
    required PaymentMethod paymentMethod,
    required List<OrderItemModel> items,
  }) async => _fakeOrder;

  @override
  Future<List<OrderItemModel>> getOrderItems(String orderId) async => [];

  @override
  Stream<OrderModel?> streamOrder(String orderId) => Stream.value(_fakeOrder);

  @override
  Stream<List<OrderModel>> streamCustomerOrders(String customerId) => Stream.value([_fakeOrder]);

  @override
  Stream<List<OrderModel>> streamStallOrders(String stallId) => Stream.value([_fakeOrder]);

  @override
  Future<void> cancelOrder({required String orderId, required String customerId}) async {}

  @override
  Future<void> updateOrderStatus({required String orderId, required OrderStatus newStatus, String? rejectionReason}) async {}
}

void main() {
  group('QrRedemptionNotifier Unit Tests', () {
    late ProviderContainer container;
    late MockQrRepository mockQrRepo;

    setUp(() {
      mockQrRepo = MockQrRepository();
      container = ProviderContainer(
        overrides: [
          qrRepositoryProvider.overrideWithValue(mockQrRepo),
          orderRepositoryProvider.overrideWithValue(MockOrderRepositoryForQr()),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('Initial QR redemption state is idle', () {
      final state = container.read(qrRedemptionProvider);
      expect(state, isA<QrRedemptionIdleState>());
    });

    test('redeemToken verifies and redeems valid token successfully', () async {
      final notifier = container.read(qrRedemptionProvider.notifier);

      final verification = await notifier.redeemToken(
        qrToken: 'QX-TESTTOKEN',
        stallId: 'stall_1',
        ownerId: 'owner_1',
      );

      expect(verification, isNotNull);
      expect(verification!.verificationId, 'ver_999');
      expect(container.read(qrRedemptionProvider), isA<QrRedemptionSuccessState>());
    });

    test('redeemToken fails when token is already verified', () async {
      mockQrRepo.shouldFail = true;
      final notifier = container.read(qrRedemptionProvider.notifier);

      final verification = await notifier.redeemToken(
        qrToken: 'QX-TESTTOKEN',
        stallId: 'stall_1',
        ownerId: 'owner_1',
      );

      expect(verification, isNull);
      final state = container.read(qrRedemptionProvider);
      expect(state, isA<QrRedemptionErrorState>());
      expect((state as QrRedemptionErrorState).message, contains('already been verified'));
    });
  });
}
