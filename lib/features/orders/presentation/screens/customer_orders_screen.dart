import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/widgets/app_error_widget.dart';
import '../../../../core/widgets/app_loading_indicator.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/models/order_model.dart';
import '../providers/order_provider.dart';
import '../widgets/customer_order_card.dart';

class CustomerOrdersScreen extends ConsumerWidget {
  const CustomerOrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final userId = authState is AuthenticatedState ? authState.user.userId : '';

    if (userId.isEmpty) {
      return const Scaffold(
        body: Center(
          child: Text('Please log in to view your orders.'),
        ),
      );
    }

    final ordersAsync = ref.watch(customerOrdersStreamProvider(userId));

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('My Orders'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Active Orders'),
              Tab(text: 'Order History'),
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
                  emptyMessage: 'No active orders right now.',
                ),
                _buildOrderList(
                  context,
                  orders: pastOrders,
                  emptyMessage: 'No past order history found.',
                ),
              ],
            );
          },
          loading: () => const Center(
            child: AppLoadingIndicator(message: 'Fetching your orders...'),
          ),
          error: (error, _) => Center(
            child: AppErrorWidget(
              title: 'Failed to load orders',
              message: error.toString(),
              onRetry: () {
                ref.invalidate(customerOrdersStreamProvider(userId));
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
              Icons.receipt_long_outlined,
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
        return CustomerOrderCard(order: orders[index]);
      },
    );
  }
}
