import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/widgets/app_loading_indicator.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../customer/presentation/providers/customer_discovery_provider.dart';
import '../../domain/models/owner_reports_model.dart';
import '../providers/owner_reports_provider.dart';

class OwnerDashboardScreen extends ConsumerWidget {
  final String stallId;

  const OwnerDashboardScreen({
    super.key,
    required this.stallId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final targetStallId = stallId.isNotEmpty ? stallId : _getOwnerStallId(ref);

    if (targetStallId.isEmpty) {
      return const Scaffold(
        body: Center(
          child: Text(
            'No stall configured for this owner account.',
            style: AppTypography.titleMedium,
          ),
        ),
      );
    }

    final analyticsAsync = ref.watch(ownerDailyAnalyticsStreamProvider(targetStallId));
    final stallAsync = ref.watch(stallDetailsProvider(targetStallId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Stall Dashboard'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Welcome & Stall Status Banner
            stallAsync.when(
              data: (stall) {
                if (stall == null) return const SizedBox.shrink();
                final isPeak = stall.isPeakModeEnabled;

                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          stall.name,
                          style: AppTypography.displayLarge,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Operational Overview',
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: isPeak
                            ? AppColors.warning.withValues(alpha: 0.15)
                            : AppColors.success.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isPeak ? AppColors.warning : AppColors.success,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isPeak ? Icons.bolt_rounded : Icons.check_circle_outline,
                            size: 16,
                            color: isPeak ? AppColors.warning : AppColors.success,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            isPeak ? 'PEAK MODE' : 'STANDARD MODE',
                            style: AppTypography.labelSmall.copyWith(
                              color: isPeak ? AppColors.warning : AppColors.success,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
              loading: () => const AppLoadingIndicator(),
              error: (err, stack) => const SizedBox.shrink(),
            ),
            const SizedBox(height: 20),

            // Analytics Overview Grid
            analyticsAsync.when(
              data: (analytics) => _buildAnalyticsOverview(context, analytics),
              loading: () => const Center(
                child: AppLoadingIndicator(message: 'Loading metrics...'),
              ),
              error: (err, stack) => Text('Failed to load metrics: $err'),
            ),
            const SizedBox(height: 24),

            // Quick Actions Shortcut Section
            const Text(
              'Quick Actions',
              style: AppTypography.titleMedium,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      context.push('/owner/scan-qr');
                    },
                    icon: const Icon(Icons.qr_code_scanner_rounded),
                    label: const Text('Scan QR Code'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalyticsOverview(
      BuildContext context, StallAnalyticsSummary analytics) {
    return Column(
      children: [
        // Metric Cards Grid
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.5,
          children: [
            _buildMetricCard(
              title: "Today's Revenue",
              value: '₹${analytics.totalRevenueToday.toStringAsFixed(0)}',
              icon: Icons.currency_rupee_rounded,
              color: AppColors.success,
            ),
            _buildMetricCard(
              title: 'Total Orders',
              value: '${analytics.totalOrdersToday}',
              icon: Icons.shopping_bag_outlined,
              color: AppColors.primary,
            ),
            _buildMetricCard(
              title: 'Completed',
              value: '${analytics.completedOrdersCount}',
              icon: Icons.task_alt_rounded,
              color: AppColors.success,
            ),
            _buildMetricCard(
              title: 'Pending',
              value: '${analytics.pendingOrdersCount}',
              icon: Icons.hourglass_top_rounded,
              color: AppColors.warning,
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Payment Method Split Card
        Card(
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: const BorderSide(color: AppColors.divider),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Payment Method Breakdown',
                  style: AppTypography.titleMedium,
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Text('Online Gateway', style: AppTypography.bodyMedium),
                      ],
                    ),
                    Text(
                      '₹${analytics.onlinePaymentRevenue.toStringAsFixed(0)}',
                      style: AppTypography.titleMedium.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: const BoxDecoration(
                            color: AppColors.success,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Text('Cash at Stall', style: AppTypography.bodyMedium),
                      ],
                    ),
                    Text(
                      '₹${analytics.cashPaymentRevenue.toStringAsFixed(0)}',
                      style: AppTypography.titleMedium.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: AppColors.divider),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    title,
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: AppTypography.displayLarge.copyWith(
                fontSize: 22,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getOwnerStallId(WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    if (authState is AuthenticatedState) {
      final stallId = authState.user.stallId;
      if (stallId != null && stallId.isNotEmpty) return stallId;
    }
    return 'stall_1';
  }
}
