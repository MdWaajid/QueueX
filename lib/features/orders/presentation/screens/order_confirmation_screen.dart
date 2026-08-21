import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/widgets/app_error_widget.dart';
import '../../../../core/widgets/app_loading_indicator.dart';
import '../../../qr/domain/services/qr_validation_service.dart';
import '../../../qr/presentation/providers/qr_provider.dart';
import '../../../qr/presentation/widgets/qr_token_card.dart';
import '../../domain/models/order_model.dart';
import '../providers/order_provider.dart';

class OrderConfirmationScreen extends ConsumerWidget {
  final String orderId;

  const OrderConfirmationScreen({
    super.key,
    required this.orderId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderAsync = ref.watch(orderDetailsProvider(orderId));
    final itemsAsync = ref.watch(orderItemsProvider(orderId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Confirmation'),
        automaticallyImplyLeading: false,
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

          final qrValidationAsync = ref.watch(qrValidationProvider(order));

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Success Badge Header
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: AppColors.success,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    color: Colors.white,
                    size: 48,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Order Placed Successfully!',
                  style: AppTypography.displayLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  'Order ID: #${order.orderId.substring(0, order.orderId.length > 8 ? 8 : order.orderId.length).toUpperCase()}',
                  style: AppTypography.labelSmall,
                ),
                const SizedBox(height: 20),

                // Order Status & Pickup Card
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
                            const Text('Order Status',
                                style: AppTypography.bodyMedium),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.warning.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                order.status.label,
                                style: AppTypography.labelSmall.copyWith(
                                  color: AppColors.warning,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Payment Method',
                                style: AppTypography.bodyMedium),
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
                            const Text('Payment Status',
                                style: AppTypography.bodyMedium),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
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
                        const Divider(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Pickup Time',
                                style: AppTypography.bodyMedium),
                            Text(
                              '${_formatTime(order.slotStartTime)} - ${_formatTime(order.slotEndTime)}',
                              style: AppTypography.titleMedium.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
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
                  error: (_, _) => QrTokenCard(
                    qrToken: order.qrToken,
                    validationResult: QrValidationService.validate(
                      order: order,
                      targetStallId: order.stallId,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Items List Card
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
                            const Text('Items Breakdown',
                                style: AppTypography.titleMedium),
                            const SizedBox(height: 8),
                            ...items.map((item) => Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 4),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
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
                                const Text('Total Paid',
                                    style: AppTypography.titleMedium),
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
                  error: (_, _) => const SizedBox.shrink(),
                ),
                const SizedBox(height: 32),

                // Back to Home Action Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      context.go('/customer');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Back to Customer Home'),
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(
          child: AppLoadingIndicator(
            message: 'Loading order confirmation...',
          ),
        ),
        error: (error, _) => Center(
          child: AppErrorWidget(
            title: 'Failed to load order details',
            message: error.toString(),
            onRetry: () {
              ref.invalidate(orderDetailsProvider(orderId));
            },
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
