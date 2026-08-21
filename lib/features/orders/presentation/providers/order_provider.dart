import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/order_repository.dart';
import '../../domain/models/order_item_model.dart';
import '../../domain/models/order_model.dart';

final orderRepositoryProvider = Provider<OrderRepository>((ref) {
  return FirebaseOrderRepository();
});

sealed class OrderCreationState {
  const OrderCreationState();
}

class OrderCreationIdleState extends OrderCreationState {
  const OrderCreationIdleState();
}

class OrderCreationLoadingState extends OrderCreationState {
  const OrderCreationLoadingState();
}

class OrderCreationSuccessState extends OrderCreationState {
  final OrderModel order;
  const OrderCreationSuccessState(this.order);
}

class OrderCreationErrorState extends OrderCreationState {
  final String message;
  const OrderCreationErrorState(this.message);
}

class OrderCreationNotifier extends Notifier<OrderCreationState> {
  @override
  OrderCreationState build() => const OrderCreationIdleState();

  Future<OrderModel?> placeOrder({
    required String customerId,
    required String stallId,
    required String slotId,
    required DateTime slotStartTime,
    required DateTime slotEndTime,
    required double totalAmount,
    required PaymentMethod paymentMethod,
    required bool isPeakModeEnabled,
    required List<OrderItemModel> items,
  }) async {
    if (isPeakModeEnabled && paymentMethod == PaymentMethod.offline) {
      state = const OrderCreationErrorState(
        'Pay Cash at Stall is not allowed during Peak Demand Mode. Please select Online Payment.',
      );
      return null;
    }

    state = const OrderCreationLoadingState();

    try {
      final repository = ref.read(orderRepositoryProvider);
      final order = await repository.createOrder(
        customerId: customerId,
        stallId: stallId,
        slotId: slotId,
        slotStartTime: slotStartTime,
        slotEndTime: slotEndTime,
        totalAmount: totalAmount,
        paymentMethod: paymentMethod,
        items: items,
      );

      state = OrderCreationSuccessState(order);
      return order;
    } catch (e) {
      state = OrderCreationErrorState(e.toString());
      return null;
    }
  }

  void reset() {
    state = const OrderCreationIdleState();
  }
}

final orderCreationProvider =
    NotifierProvider<OrderCreationNotifier, OrderCreationState>(
        OrderCreationNotifier.new);

final orderDetailsProvider =
    FutureProvider.family<OrderModel?, String>((ref, orderId) async {
  final repository = ref.watch(orderRepositoryProvider);
  return repository.getOrderById(orderId);
});

final activeOrderStreamProvider =
    StreamProvider.family<OrderModel?, String>((ref, orderId) {
  final repository = ref.watch(orderRepositoryProvider);
  return repository.streamOrder(orderId);
});

final customerOrdersStreamProvider =
    StreamProvider.family<List<OrderModel>, String>((ref, customerId) {
  final repository = ref.watch(orderRepositoryProvider);
  return repository.streamCustomerOrders(customerId);
});

final stallOrdersStreamProvider =
    StreamProvider.family<List<OrderModel>, String>((ref, stallId) {
  final repository = ref.watch(orderRepositoryProvider);
  return repository.streamStallOrders(stallId);
});

final orderItemsProvider =
    FutureProvider.family<List<OrderItemModel>, String>((ref, orderId) async {
  final repository = ref.watch(orderRepositoryProvider);
  return repository.getOrderItems(orderId);
});

sealed class OrderCancellationState {
  const OrderCancellationState();
}

class OrderCancellationIdleState extends OrderCancellationState {
  const OrderCancellationIdleState();
}

class OrderCancellationLoadingState extends OrderCancellationState {
  const OrderCancellationLoadingState();
}

class OrderCancellationSuccessState extends OrderCancellationState {
  const OrderCancellationSuccessState();
}

class OrderCancellationErrorState extends OrderCancellationState {
  final String message;
  const OrderCancellationErrorState(this.message);
}

class OrderCancellationNotifier extends Notifier<OrderCancellationState> {
  @override
  OrderCancellationState build() => const OrderCancellationIdleState();

  Future<bool> cancelOrder({
    required String orderId,
    required String customerId,
  }) async {
    state = const OrderCancellationLoadingState();
    try {
      final repository = ref.read(orderRepositoryProvider);
      await repository.cancelOrder(orderId: orderId, customerId: customerId);
      state = const OrderCancellationSuccessState();
      return true;
    } catch (e) {
      state = OrderCancellationErrorState(e.toString());
      return false;
    }
  }
}

final orderCancellationProvider =
    NotifierProvider<OrderCancellationNotifier, OrderCancellationState>(
        OrderCancellationNotifier.new);

sealed class OrderStatusUpdateState {
  const OrderStatusUpdateState();
}

class OrderStatusUpdateIdleState extends OrderStatusUpdateState {
  const OrderStatusUpdateIdleState();
}

class OrderStatusUpdateLoadingState extends OrderStatusUpdateState {
  const OrderStatusUpdateLoadingState();
}

class OrderStatusUpdateSuccessState extends OrderStatusUpdateState {
  final OrderStatus newStatus;
  const OrderStatusUpdateSuccessState(this.newStatus);
}

class OrderStatusUpdateErrorState extends OrderStatusUpdateState {
  final String message;
  const OrderStatusUpdateErrorState(this.message);
}

class OrderStatusUpdateNotifier extends Notifier<OrderStatusUpdateState> {
  @override
  OrderStatusUpdateState build() => const OrderStatusUpdateIdleState();

  Future<bool> updateStatus({
    required String orderId,
    required OrderStatus newStatus,
    String? rejectionReason,
  }) async {
    state = const OrderStatusUpdateLoadingState();
    try {
      final repository = ref.read(orderRepositoryProvider);
      await repository.updateOrderStatus(
        orderId: orderId,
        newStatus: newStatus,
        rejectionReason: rejectionReason,
      );
      state = OrderStatusUpdateSuccessState(newStatus);
      return true;
    } catch (e) {
      state = OrderStatusUpdateErrorState(e.toString());
      return false;
    }
  }
}

final orderStatusUpdateProvider =
    NotifierProvider<OrderStatusUpdateNotifier, OrderStatusUpdateState>(
        OrderStatusUpdateNotifier.new);
