import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../orders/domain/models/order_model.dart';
import '../../domain/models/owner_reports_model.dart';

abstract class OwnerReportsRepository {
  Stream<StallAnalyticsSummary> streamDailyAnalytics(String stallId);
}

class FirebaseOwnerReportsRepository implements OwnerReportsRepository {
  final FirebaseFirestore _firestore;

  FirebaseOwnerReportsRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Stream<StallAnalyticsSummary> streamDailyAnalytics(String stallId) {
    if (stallId.isEmpty) return Stream.value(StallAnalyticsSummary.empty());

    return _firestore
        .collection('orders')
        .where('stallId', isEqualTo: stallId)
        .snapshots()
        .map((snapshot) {
      double totalRevenue = 0.0;
      int totalOrders = snapshot.docs.length;
      int completedCount = 0;
      int pendingCount = 0;
      double onlineRevenue = 0.0;
      double cashRevenue = 0.0;

      for (final doc in snapshot.docs) {
        final order = OrderModel.fromFirestore(doc);

        if (order.status == OrderStatus.completed) {
          completedCount++;
          totalRevenue += order.totalAmount;

          if (order.paymentMethod == PaymentMethod.online) {
            onlineRevenue += order.totalAmount;
          } else {
            cashRevenue += order.totalAmount;
          }
        } else if (order.status == OrderStatus.pending) {
          pendingCount++;
        }
      }

      return StallAnalyticsSummary(
        totalRevenueToday: totalRevenue,
        totalOrdersToday: totalOrders,
        completedOrdersCount: completedCount,
        pendingOrdersCount: pendingCount,
        onlinePaymentRevenue: onlineRevenue,
        cashPaymentRevenue: cashRevenue,
      );
    });
  }
}
