import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../domain/models/order_model.dart';

class OrderTimelineStepper extends StatelessWidget {
  final OrderStatus currentStatus;

  const OrderTimelineStepper({
    super.key,
    required this.currentStatus,
  });

  int get _activeStepIndex {
    switch (currentStatus) {
      case OrderStatus.pending:
        return 0;
      case OrderStatus.accepted:
        return 1;
      case OrderStatus.preparing:
        return 2;
      case OrderStatus.ready:
        return 3;
      case OrderStatus.completed:
        return 4;
      case OrderStatus.rejected:
      case OrderStatus.cancelled:
      case OrderStatus.expired:
        return -1;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (currentStatus == OrderStatus.rejected ||
        currentStatus == OrderStatus.cancelled ||
        currentStatus == OrderStatus.expired) {
      return _buildTerminalErrorCard();
    }

    final steps = [
      {'title': 'Order Placed', 'subtitle': 'Waiting for stall acceptance'},
      {'title': 'Accepted', 'subtitle': 'Stall confirmed your order'},
      {'title': 'Preparing', 'subtitle': 'Items being prepared'},
      {'title': 'Ready for Pickup', 'subtitle': 'Show QR token at stall'},
      {'title': 'Completed', 'subtitle': 'Order picked up'},
    ];

    final activeIndex = _activeStepIndex;

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.divider),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Order Status Timeline',
              style: AppTypography.titleMedium,
            ),
            const SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: steps.length,
              itemBuilder: (context, index) {
                final isCompleted = index < activeIndex;
                final isCurrent = index == activeIndex;
                final isLast = index == steps.length - 1;

                Color circleColor = AppColors.divider;
                IconData iconData = Icons.circle_outlined;

                if (isCompleted) {
                  circleColor = AppColors.success;
                  iconData = Icons.check_circle_rounded;
                } else if (isCurrent) {
                  circleColor = AppColors.primary;
                  iconData = Icons.radio_button_checked_rounded;
                }

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      children: [
                        Icon(
                          iconData,
                          size: 24,
                          color: circleColor,
                        ),
                        if (!isLast)
                          Container(
                            width: 2,
                            height: 36,
                            color: isCompleted ? AppColors.success : AppColors.divider,
                          ),
                      ],
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              steps[index]['title']!,
                              style: AppTypography.titleMedium.copyWith(
                                color: isCurrent
                                    ? AppColors.primary
                                    : (isCompleted
                                        ? AppColors.textPrimary
                                        : AppColors.textSecondary),
                                fontWeight: isCurrent
                                    ? FontWeight.bold
                                    : FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              steps[index]['subtitle']!,
                              style: AppTypography.labelSmall.copyWith(
                                color: isCurrent
                                    ? AppColors.primary
                                    : AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTerminalErrorCard() {
    String title = 'Order Cancelled';
    String description = 'This order has been cancelled.';

    if (currentStatus == OrderStatus.rejected) {
      title = 'Order Rejected';
      description = 'The stall was unable to accept this order.';
    } else if (currentStatus == OrderStatus.expired) {
      title = 'Order Expired';
      description = 'Pickup slot grace period passed without pickup.';
    }

    return Card(
      elevation: 1,
      color: AppColors.error.withValues(alpha: 0.08),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: AppColors.error.withValues(alpha: 0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            const Icon(
              Icons.cancel_rounded,
              color: AppColors.error,
              size: 36,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.titleMedium.copyWith(
                      color: AppColors.error,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.error,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
