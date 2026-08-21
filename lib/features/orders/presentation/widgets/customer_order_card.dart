import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../customer/presentation/providers/customer_discovery_provider.dart';
import '../../domain/models/order_model.dart';

class CustomerOrderCard extends ConsumerWidget {
  final OrderModel order;

  const CustomerOrderCard({
    super.key,
    required this.order,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stallAsync = ref.watch(stallDetailsProvider(order.stallId));

    Color badgeColor = AppColors.primary;
    switch (order.status) {
      case OrderStatus.pending:
      case OrderStatus.accepted:
        badgeColor = AppColors.warning;
        break;
      case OrderStatus.preparing:
      case OrderStatus.ready:
        badgeColor = AppColors.primary;
        break;
      case OrderStatus.completed:
        badgeColor = AppColors.success;
        break;
      case OrderStatus.rejected:
      case OrderStatus.cancelled:
      case OrderStatus.expired:
        badgeColor = AppColors.error;
        break;
    }

    return Card(
      elevation: 1.5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: AppColors.divider),
      ),
      child: InkWell(
        onTap: () {
          context.push('/customer/order/${order.orderId}');
        },
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: stallAsync.when(
                      data: (stall) => Text(
                        stall?.stallName ?? 'Stall #${order.stallId.substring(0, 4)}',
                        style: AppTypography.titleMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      loading: () => const Text(
                        'Loading stall...',
                        style: AppTypography.titleMedium,
                      ),
                      error: (err, stack) => const Text(
                        'Stall Info',
                        style: AppTypography.titleMedium,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: badgeColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      order.status.label,
                      style: AppTypography.labelSmall.copyWith(
                        color: badgeColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
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
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '₹${order.totalAmount.toStringAsFixed(0)}',
                    style: AppTypography.titleMedium.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'ID: #${order.orderId.substring(0, order.orderId.length > 8 ? 8 : order.orderId.length).toUpperCase()}',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 10,
                    ),
                  ),
                  const Row(
                    children: [
                      Text(
                        'Track Order',
                        style: AppTypography.labelSmall,
                      ),
                      SizedBox(width: 2),
                      Icon(
                        Icons.chevron_right_rounded,
                        size: 16,
                        color: AppColors.primary,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
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
