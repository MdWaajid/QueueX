import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/models/order_item_model.dart';
import '../../domain/models/order_model.dart';

class SlotFullException implements Exception {
  final String message;
  SlotFullException([this.message = 'The selected slot is fully booked. Please select another slot.']);

  @override
  String toString() => message;
}

abstract class OrderRepository {
  Future<OrderModel> createOrder({
    required String customerId,
    required String stallId,
    required String slotId,
    required DateTime slotStartTime,
    required DateTime slotEndTime,
    required double totalAmount,
    required PaymentMethod paymentMethod,
    required List<OrderItemModel> items,
  });

  Future<OrderModel?> getOrderById(String orderId);
  Future<List<OrderItemModel>> getOrderItems(String orderId);
  Stream<OrderModel?> streamOrder(String orderId);
  Stream<List<OrderModel>> streamCustomerOrders(String customerId);
  Stream<List<OrderModel>> streamStallOrders(String stallId);
  Future<void> cancelOrder({required String orderId, required String customerId});
  Future<void> updateOrderStatus({
    required String orderId,
    required OrderStatus newStatus,
    String? rejectionReason,
  });
}

class FirebaseOrderRepository implements OrderRepository {
  final FirebaseFirestore _firestore;

  FirebaseOrderRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

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
    final orderRef = _firestore.collection('orders').doc();
    final slotRef = _firestore.collection('slots').doc(slotId);
    final qrToken = _generateSecureQrToken();

    final now = DateTime.now();

    final order = OrderModel(
      orderId: orderRef.id,
      customerId: customerId,
      stallId: stallId,
      slotId: slotId,
      totalAmount: totalAmount,
      status: OrderStatus.pending,
      paymentStatus: paymentMethod == PaymentMethod.online
          ? PaymentStatus.pending
          : PaymentStatus.pending,
      paymentMethod: paymentMethod,
      qrToken: qrToken,
      slotStartTime: slotStartTime,
      slotEndTime: slotEndTime,
      createdAt: now,
      updatedAt: now,
    );

    await _firestore.runTransaction((transaction) async {
      final slotDoc = await transaction.get(slotRef);

      if (slotDoc.exists) {
        final data = slotDoc.data() ?? {};
        final bookedCount = data['bookedCount'] as int? ?? 0;
        final capacity = data['capacity'] as int? ?? 10;
        final status = data['status'] as String? ?? 'active';

        if (bookedCount >= capacity || status.toLowerCase() == 'disabled') {
          throw SlotFullException();
        }

        transaction.update(slotRef, {
          'bookedCount': FieldValue.increment(1),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      } else {
        // Create slot document with 1 booking if virtual slot
        transaction.set(slotRef, {
          'slotId': slotId,
          'stallId': stallId,
          'startTime': Timestamp.fromDate(slotStartTime),
          'endTime': Timestamp.fromDate(slotEndTime),
          'capacity': 10,
          'bookedCount': 1,
          'status': 'active',
          'isPeak': false,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      // Write Order Document
      transaction.set(orderRef, order.toMap());

      // Write Order Items
      for (final item in items) {
        final itemRef = orderRef.collection('orderItems').doc();
        final orderItem = OrderItemModel(
          orderItemId: itemRef.id,
          orderId: orderRef.id,
          itemId: item.itemId,
          itemName: item.itemName,
          unitPrice: item.unitPrice,
          quantity: item.quantity,
          subtotal: item.subtotal,
        );
        transaction.set(itemRef, orderItem.toMap());
      }
    });

    return order;
  }

  @override
  Future<OrderModel?> getOrderById(String orderId) async {
    final doc = await _firestore.collection('orders').doc(orderId).get();
    if (!doc.exists) return null;
    return OrderModel.fromFirestore(doc);
  }

  @override
  Future<List<OrderItemModel>> getOrderItems(String orderId) async {
    final snapshot = await _firestore
        .collection('orders')
        .doc(orderId)
        .collection('orderItems')
        .get();

    return snapshot.docs
        .map((doc) => OrderItemModel.fromFirestore(doc))
        .toList();
  }

  @override
  Stream<OrderModel?> streamOrder(String orderId) {
    return _firestore
        .collection('orders')
        .doc(orderId)
        .snapshots()
        .map((doc) => doc.exists ? OrderModel.fromFirestore(doc) : null);
  }

  @override
  Stream<List<OrderModel>> streamCustomerOrders(String customerId) {
    return _firestore
        .collection('orders')
        .where('customerId', isEqualTo: customerId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => OrderModel.fromFirestore(doc))
            .toList()
          ..sort((a, b) => (b.createdAt ?? DateTime(2000))
              .compareTo(a.createdAt ?? DateTime(2000))));
  }

  @override
  Stream<List<OrderModel>> streamStallOrders(String stallId) {
    return _firestore
        .collection('orders')
        .where('stallId', isEqualTo: stallId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => OrderModel.fromFirestore(doc))
            .toList()
          ..sort((a, b) => (b.createdAt ?? DateTime(2000))
              .compareTo(a.createdAt ?? DateTime(2000))));
  }

  @override
  Future<void> cancelOrder(
      {required String orderId, required String customerId}) async {
    final orderRef = _firestore.collection('orders').doc(orderId);

    await _firestore.runTransaction((transaction) async {
      final doc = await transaction.get(orderRef);
      if (!doc.exists) {
        throw Exception('Order not found');
      }

      final order = OrderModel.fromFirestore(doc);
      if (order.status != OrderStatus.pending) {
        throw Exception('Order cannot be cancelled once accepted or preparing');
      }

      transaction.update(orderRef, {
        'status': OrderStatus.cancelled.value,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (order.slotId.isNotEmpty) {
        final slotRef = _firestore.collection('slots').doc(order.slotId);
        transaction.update(slotRef, {
          'bookedCount': FieldValue.increment(-1),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    });
  }

  @override
  Future<void> updateOrderStatus({
    required String orderId,
    required OrderStatus newStatus,
    String? rejectionReason,
  }) async {
    final orderRef = _firestore.collection('orders').doc(orderId);

    await _firestore.runTransaction((transaction) async {
      final doc = await transaction.get(orderRef);
      if (!doc.exists) {
        throw Exception('Order not found');
      }

      final currentOrder = OrderModel.fromFirestore(doc);
      _validateStateTransition(currentOrder.status, newStatus);

      final updates = <String, dynamic>{
        'status': newStatus.value,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (rejectionReason != null && rejectionReason.isNotEmpty) {
        updates['rejectionReason'] = rejectionReason;
      }

      transaction.update(orderRef, updates);
    });
  }

  void _validateStateTransition(OrderStatus current, OrderStatus next) {
    final isValid = (current == OrderStatus.pending &&
            (next == OrderStatus.accepted || next == OrderStatus.rejected)) ||
        (current == OrderStatus.accepted && next == OrderStatus.preparing) ||
        (current == OrderStatus.preparing && next == OrderStatus.ready) ||
        (current == OrderStatus.ready && next == OrderStatus.completed);

    if (!isValid) {
      throw Exception(
          'Invalid order status transition from ${current.label} to ${next.label}');
    }
  }

  String _generateSecureQrToken() {
    final random = Random.secure();
    final values = List<int>.generate(16, (i) => random.nextInt(256));
    final hex = values.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
    return 'QX-$hex';
  }
}
