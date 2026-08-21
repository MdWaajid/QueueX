import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../orders/domain/models/order_model.dart';
import '../../../orders/presentation/providers/order_provider.dart';

class OwnerOrderCard extends ConsumerWidget {
  final OrderModel order;

  const OwnerOrderCard({
    super.key,
    required this.order,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemsAsync = ref.watch(orderItemsProvider(order.orderId));
    final updateState = ref.watch(orderStatusUpdateProvider);
    final isLoading = updateState is OrderStatusUpdateLoadingState;

    return Card(
      elevation: 1.5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.divider),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order ID & Status Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Order #${order.orderId.substring(0, order.orderId.length > 8 ? 8 : order.orderId.length).toUpperCase()}',
                  style: AppTypography.titleMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(order.status).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    order.status.label,
                    style: AppTypography.labelSmall.copyWith(
                      color: _getStatusColor(order.status),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Pickup Slot & Payment Status Badges
            Row(
              children: [
                const Icon(
                  Icons.access_time_rounded,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    'Pickup: ${_formatTime(order.slotStartTime)} - ${_formatTime(order.slotEndTime)}',
                    style: AppTypography.labelSmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: (order.paymentStatus == PaymentStatus.paid
                            ? AppColors.success
                            : AppColors.warning)
                        .withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    order.paymentStatus == PaymentStatus.paid
                        ? 'PAID'
                        : 'PAY CASH AT PICKUP',
                    style: AppTypography.labelSmall.copyWith(
                      color: order.paymentStatus == PaymentStatus.paid
                          ? AppColors.success
                          : AppColors.warning,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 20),

            // Order Items Breakdown
            itemsAsync.when(
              data: (items) {
                if (items.isEmpty) return const SizedBox.shrink();
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: items
                      .map((item) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${item.quantity}× ${item.itemName}',
                                  style: AppTypography.bodyMedium,
                                ),
                                Text(
                                  '₹${item.subtotal.toStringAsFixed(0)}',
                                  style: AppTypography.bodyMedium.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ))
                      .toList(),
                );
              },
              loading: () => const Text('Loading items...', style: AppTypography.labelSmall),
              error: (err, stack) => const SizedBox.shrink(),
            ),
            const SizedBox(height: 8),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total Amount', style: AppTypography.labelSmall),
                Text(
                  '₹${order.totalAmount.toStringAsFixed(0)}',
                  style: AppTypography.titleLarge.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Action Buttons
            _buildActionButtons(context, ref, isLoading: isLoading),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(
    BuildContext context,
    WidgetRef ref, {
    required bool isLoading,
  }) {
    final notifier = ref.read(orderStatusUpdateProvider.notifier);

    switch (order.status) {
      case OrderStatus.pending:
        return Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: isLoading
                    ? null
                    : () {
                        _showRejectDialog(context, ref, order.orderId);
                      },
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.error,
                  side: const BorderSide(color: AppColors.error),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text('Reject'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: isLoading
                    ? null
                    : () {
                        notifier.updateStatus(
                          orderId: order.orderId,
                          newStatus: OrderStatus.accepted,
                        );
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.success,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text('Accept Order'),
              ),
            ),
          ],
        );

      case OrderStatus.accepted:
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: isLoading
                ? null
                : () {
                    notifier.updateStatus(
                      orderId: order.orderId,
                      newStatus: OrderStatus.preparing,
                    );
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            child: const Text('Start Preparing'),
          ),
        );

      case OrderStatus.preparing:
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: isLoading
                ? null
                : () {
                    notifier.updateStatus(
                      orderId: order.orderId,
                      newStatus: OrderStatus.ready,
                    );
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            child: const Text('Mark Ready for Pickup'),
          ),
        );

      case OrderStatus.ready:
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: isLoading
                ? null
                : () {
                    notifier.updateStatus(
                      orderId: order.orderId,
                      newStatus: OrderStatus.completed,
                    );
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            child: const Text('Mark Completed'),
          ),
        );

      case OrderStatus.completed:
      case OrderStatus.rejected:
      case OrderStatus.cancelled:
      case OrderStatus.expired:
        return const SizedBox.shrink();
    }
  }

  void _showRejectDialog(
    BuildContext context,
    WidgetRef ref,
    String orderId,
  ) {
    final controller = TextEditingController();

    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Order?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Please provide an optional reason for rejection:'),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                hintText: 'e.g. Item out of stock / Kitchen overloaded',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ref.read(orderStatusUpdateProvider.notifier).updateStatus(
                    orderId: orderId,
                    newStatus: OrderStatus.rejected,
                    rejectionReason: controller.text.trim(),
                  );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Confirm Reject'),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
      case OrderStatus.accepted:
        return AppColors.warning;
      case OrderStatus.preparing:
      case OrderStatus.ready:
        return AppColors.primary;
      case OrderStatus.completed:
        return AppColors.success;
      case OrderStatus.rejected:
      case OrderStatus.cancelled:
      case OrderStatus.expired:
        return AppColors.error;
    }
  }

  String _formatTime(DateTime time) {
    final hour = time.hour > 12
        ? time.hour - 12
        : (time.hour == 0 ? 12 : time.hour);
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }
}
