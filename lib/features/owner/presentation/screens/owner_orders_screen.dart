import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/widgets/app_error_widget.dart';
import '../../../../core/widgets/app_loading_indicator.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../orders/domain/models/order_model.dart';
import '../../../orders/presentation/providers/order_provider.dart';
import '../widgets/owner_order_card.dart';

class OwnerOrdersScreen extends ConsumerWidget {
  final String stallId;

  const OwnerOrdersScreen({
    super.key,
    required this.stallId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<OrderStatusUpdateState>(orderStatusUpdateProvider, (prev, next) {
      if (next is OrderStatusUpdateSuccessState) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Order status updated to ${next.newStatus.label}'),
            backgroundColor: AppColors.success,
          ),
        );
      } else if (next is OrderStatusUpdateErrorState) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.message),
            backgroundColor: AppColors.error,
          ),
        );
      }
    });

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

    final ordersAsync = ref.watch(stallOrdersStreamProvider(targetStallId));

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Stall Orders Dashboard'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Active Orders'),
              Tab(text: 'Past History'),
            ],
          ),
        ),
        body: ordersAsync.when(
          data: (orders) {
            final activeOrders = orders.where((o) =>
                o.status == OrderStatus.pending ||
                o.status == OrderStatus.accepted ||
                o.status == OrderStatus.preparing ||
                o.status == OrderStatus.ready).toList();

            final pastOrders = orders.where((o) =>
                o.status == OrderStatus.completed ||
                o.status == OrderStatus.rejected ||
                o.status == OrderStatus.cancelled ||
                o.status == OrderStatus.expired).toList();

            return TabBarView(
              children: [
                _buildOrderList(
                  context,
                  orders: activeOrders,
                  emptyMessage: 'No incoming active orders right now.',
                ),
                _buildOrderList(
                  context,
                  orders: pastOrders,
                  emptyMessage: 'No completed order history found.',
                ),
              ],
            );
          },
          loading: () => const Center(
            child: AppLoadingIndicator(message: 'Streaming stall orders...'),
          ),
          error: (error, _) => Center(
            child: AppErrorWidget(
              title: 'Failed to load stall orders',
              message: error.toString(),
              onRetry: () {
                ref.invalidate(stallOrdersStreamProvider(targetStallId));
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOrderList(
    BuildContext context, {
    required List<OrderModel> orders,
    required String emptyMessage,
  }) {
    if (orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.storefront_outlined,
              size: 64,
              color: AppColors.textSecondary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 12),
            Text(
              emptyMessage,
              style: AppTypography.titleMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: orders.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return OwnerOrderCard(order: orders[index]);
      },
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
