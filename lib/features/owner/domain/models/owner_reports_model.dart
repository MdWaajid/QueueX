class StallAnalyticsSummary {
  final double totalRevenueToday;
  final int totalOrdersToday;
  final int completedOrdersCount;
  final int pendingOrdersCount;
  final double onlinePaymentRevenue;
  final double cashPaymentRevenue;

  const StallAnalyticsSummary({
    required this.totalRevenueToday,
    required this.totalOrdersToday,
    required this.completedOrdersCount,
    required this.pendingOrdersCount,
    required this.onlinePaymentRevenue,
    required this.cashPaymentRevenue,
  });

  factory StallAnalyticsSummary.empty() {
    return const StallAnalyticsSummary(
      totalRevenueToday: 0.0,
      totalOrdersToday: 0,
      completedOrdersCount: 0,
      pendingOrdersCount: 0,
      onlinePaymentRevenue: 0.0,
      cashPaymentRevenue: 0.0,
    );
  }
}
