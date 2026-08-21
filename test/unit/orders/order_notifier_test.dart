import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:queuex/features/orders/data/repositories/order_repository.dart';
import 'package:queuex/features/orders/domain/models/order_item_model.dart';
import 'package:queuex/features/orders/domain/models/order_model.dart';
import 'package:queuex/features/orders/presentation/providers/order_provider.dart';

class MockOrderRepository implements OrderRepository {
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
  }) async {
    return OrderModel(
      orderId: 'order_99',
      customerId: customerId,
      stallId: stallId,
      slotId: slotId,
      totalAmount: totalAmount,
      status: OrderStatus.pending,
      paymentStatus: PaymentStatus.pending,
      paymentMethod: paymentMethod,
      qrToken: 'QX-MOCKTOKEN123',
      slotStartTime: slotStartTime,
      slotEndTime: slotEndTime,
      createdAt: DateTime.now(),
    );
  }

  @override
  Future<OrderModel?> getOrderById(String orderId) async => null;

  @override
  Future<List<OrderItemModel>> getOrderItems(String orderId) async => [];

  @override
  Stream<OrderModel?> streamOrder(String orderId) => Stream.value(null);

  @override
  Stream<List<OrderModel>> streamCustomerOrders(String customerId) =>
      Stream.value([]);

  @override
  Stream<List<OrderModel>> streamStallOrders(String stallId) =>
      Stream.value([]);

  @override
  Future<void> cancelOrder({
    required String orderId,
    required String customerId,
  }) async {}

  @override
  Future<void> updateOrderStatus({
    required String orderId,
    required OrderStatus newStatus,
    String? rejectionReason,
  }) async {}
}

void main() {
  group('OrderCreationNotifier Unit Tests', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer(
        overrides: [
          orderRepositoryProvider.overrideWithValue(MockOrderRepository()),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('Initial order creation state is idle', () {
      final state = container.read(orderCreationProvider);
      expect(state, isA<OrderCreationIdleState>());
    });

    test('placeOrder creates order successfully when valid', () async {
      final notifier = container.read(orderCreationProvider.notifier);

      final order = await notifier.placeOrder(
        customerId: 'user_1',
        stallId: 'stall_1',
        slotId: 'slot_1',
        slotStartTime: DateTime.now(),
        slotEndTime: DateTime.now().add(const Duration(minutes: 15)),
        totalAmount: 180.0,
        paymentMethod: PaymentMethod.online,
        isPeakModeEnabled: false,
        items: [],
      );

      expect(order, isNotNull);
      expect(order!.orderId, 'order_99');
      expect(container.read(orderCreationProvider),
          isA<OrderCreationSuccessState>());
    });

    test('placeOrder fails when offline payment is selected during peak mode',
        () async {
      final notifier = container.read(orderCreationProvider.notifier);

      final order = await notifier.placeOrder(
        customerId: 'user_1',
        stallId: 'stall_1',
        slotId: 'slot_1',
        slotStartTime: DateTime.now(),
        slotEndTime: DateTime.now().add(const Duration(minutes: 15)),
        totalAmount: 180.0,
        paymentMethod: PaymentMethod.offline,
        isPeakModeEnabled: true,
        items: [],
      );

      expect(order, isNull);
      final state = container.read(orderCreationProvider);
      expect(state, isA<OrderCreationErrorState>());
      final errorState = state as OrderCreationErrorState;
      expect(errorState.message, contains('Peak Demand Mode'));
    });
  });
}
