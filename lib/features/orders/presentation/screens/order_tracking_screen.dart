import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/widgets/app_error_widget.dart';
import '../../../../core/widgets/app_loading_indicator.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../customer/presentation/providers/customer_discovery_provider.dart';
import '../../../qr/domain/services/qr_validation_service.dart';
import '../../../qr/presentation/providers/qr_provider.dart';
import '../../../qr/presentation/widgets/qr_token_card.dart';
import '../../domain/models/order_model.dart';
import '../providers/order_provider.dart';
import '../widgets/order_timeline_stepper.dart';

class OrderTrackingScreen extends ConsumerWidget {
  final String orderId;

  const OrderTrackingScreen({
    super.key,
    required this.orderId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderAsync = ref.watch(activeOrderStreamProvider(orderId));
    final itemsAsync = ref.watch(orderItemsProvider(orderId));
    final authState = ref.watch(authControllerProvider);
    final cancellationState = ref.watch(orderCancellationProvider);

    final isCancelling = cancellationState is OrderCancellationLoadingState;

    ref.listen<OrderCancellationState>(orderCancellationProvider, (prev, next) {
      if (next is OrderCancellationSuccessState) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Order has been cancelled successfully.'),
            backgroundColor: AppColors.success,
          ),
        );
      } else if (next is OrderCancellationErrorState) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.message),
            backgroundColor: AppColors.error,
          ),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Track Order'),
      ),
      body: orderAsync.when(
        data: (order) {
          if (order == null) {
            return const Center(
              child: Text(
                'Order details not found.',
                style: AppTypography.titleMedium,
              ),
            );
          }

          final stallAsync = ref.watch(stallDetailsProvider(order.stallId));
          final qrValidationAsync = ref.watch(qrValidationProvider(order));
          final isPending = order.status == OrderStatus.pending;
          final userId = authState is AuthenticatedState ? authState.user.userId : '';

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Stall Name Header
                stallAsync.when(
                  data: (stall) => Text(
                    stall?.stallName ?? 'Stall #${order.stallId.substring(0, 4)}',
                    style: AppTypography.displayLarge,
                  ),
                  loading: () => const Text('Loading Stall...', style: AppTypography.displayLarge),
                  error: (err, stack) => const Text('Stall Info', style: AppTypography.displayLarge),
                ),
                const SizedBox(height: 4),
                Text(
                  'Order ID: #${order.orderId.substring(0, order.orderId.length > 8 ? 8 : order.orderId.length).toUpperCase()}',
                  style: AppTypography.labelSmall,
                ),
                const SizedBox(height: 20),

                // Real-Time Timeline Stepper
                OrderTimelineStepper(currentStatus: order.status),
                const SizedBox(height: 24),

                // Interactive Vector QR Token Card
                qrValidationAsync.when(
                  data: (validation) => QrTokenCard(
                    qrToken: order.qrToken,
                    validationResult: validation,
                  ),
                  loading: () => const Center(
                    child: AppLoadingIndicator(message: 'Generating QR token...'),
                  ),
                  error: (err, stack) => QrTokenCard(
                    qrToken: order.qrToken,
                    validationResult: QrValidationService.validate(
                      order: order,
                      targetStallId: order.stallId,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Pickup Time Slot & Payment Details Card
                Card(
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: const BorderSide(color: AppColors.divider),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Pickup Time Slot', style: AppTypography.bodyMedium),
                            Text(
                              '${_formatTime(order.slotStartTime)} - ${_formatTime(order.slotEndTime)}',
                              style: AppTypography.titleMedium.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Payment Method', style: AppTypography.bodyMedium),
                            Text(
                              order.paymentMethod.label,
                              style: AppTypography.labelSmall.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Payment Status', style: AppTypography.bodyMedium),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
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
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Order Items Breakdown Card
                itemsAsync.when(
                  data: (items) {
                    if (items.isEmpty) return const SizedBox.shrink();
                    return Card(
                      elevation: 1,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(color: AppColors.divider),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Order Items', style: AppTypography.titleMedium),
                            const SizedBox(height: 8),
                            ...items.map((item) => Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 4),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        '${item.itemName} × ${item.quantity}',
                                        style: AppTypography.bodyMedium,
                                      ),
                                      Text(
                                        '₹${item.subtotal.toStringAsFixed(0)}',
                                        style: AppTypography.bodyMedium.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                )),
                            const Divider(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Total', style: AppTypography.titleMedium),
                                Text(
                                  '₹${order.totalAmount.toStringAsFixed(0)}',
                                  style: AppTypography.titleLarge.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  loading: () => const SizedBox.shrink(),
                  error: (err, stack) => const SizedBox.shrink(),
                ),
                const SizedBox(height: 24),

                // Conditional Customer Cancellation Button (Pending state only)
                if (isPending)
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: isCancelling
                          ? null
                          : () {
                              _showCancellationConfirmDialog(
                                context,
                                ref,
                                orderId: order.orderId,
                                userId: userId,
                              );
                            },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error,
                        side: const BorderSide(color: AppColors.error),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: isCancelling
                          ? const AppLoadingIndicator()
                          : const Text('Cancel Order'),
                    ),
                  ),
                const SizedBox(height: 16),
              ],
            ),
          );
        },
        loading: () => const Center(
          child: AppLoadingIndicator(message: 'Tracking order progress...'),
        ),
        error: (error, _) => Center(
          child: AppErrorWidget(
            title: 'Failed to track order',
            message: error.toString(),
            onRetry: () {
              ref.invalidate(activeOrderStreamProvider(orderId));
            },
          ),
        ),
      ),
    );
  }

  void _showCancellationConfirmDialog(
    BuildContext context,
    WidgetRef ref, {
    required String orderId,
    required String userId,
  }) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Order?'),
        content: const Text(
          'Are you sure you want to cancel this order? This action cannot be undone and will release your booked slot.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Keep Order'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ref.read(orderCancellationProvider.notifier).cancelOrder(
                    orderId: orderId,
                    customerId: userId,
                  );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Confirm Cancel'),
          ),
        ],
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
