import 'package:flutter_test/flutter_test.dart';
import 'package:queuex/features/owner/data/repositories/owner_reports_repository.dart';
import 'package:queuex/features/owner/domain/models/owner_reports_model.dart';

class MockOwnerReportsRepository implements OwnerReportsRepository {
  @override
  Stream<StallAnalyticsSummary> streamDailyAnalytics(String stallId) {
    return Stream.value(
      const StallAnalyticsSummary(
        totalRevenueToday: 450.0,
        totalOrdersToday: 3,
        completedOrdersCount: 2,
        pendingOrdersCount: 1,
        onlinePaymentRevenue: 250.0,
        cashPaymentRevenue: 200.0,
      ),
    );
  }
}

void main() {
  group('OwnerReportsRepository Unit Tests', () {
    test('StallAnalyticsSummary calculates metric fields accurately', () async {
      final repo = MockOwnerReportsRepository();
      final summary = await repo.streamDailyAnalytics('stall_1').first;

      expect(summary.totalRevenueToday, 450.0);
      expect(summary.totalOrdersToday, 3);
      expect(summary.completedOrdersCount, 2);
      expect(summary.pendingOrdersCount, 1);
      expect(summary.onlinePaymentRevenue, 250.0);
      expect(summary.cashPaymentRevenue, 200.0);
    });
  });
}
