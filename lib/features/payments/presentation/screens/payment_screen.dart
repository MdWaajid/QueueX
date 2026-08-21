import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/widgets/app_error_widget.dart';
import '../../../../core/widgets/app_loading_indicator.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../orders/domain/models/order_model.dart';
import '../../../orders/presentation/providers/order_provider.dart';
import '../providers/payment_provider.dart';

class PaymentScreen extends ConsumerWidget {
  final String orderId;

  const PaymentScreen({
    super.key,
    required this.orderId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderAsync = ref.watch(orderDetailsProvider(orderId));
    final authState = ref.watch(authControllerProvider);
    final paymentState = ref.watch(paymentProcessingProvider);

    final isLoading = paymentState is PaymentProcessingLoadingState;

    ref.listen<PaymentProcessingState>(paymentProcessingProvider, (previous, next) {
      if (next is PaymentProcessingSuccessState) {
        context.go('/customer/order-confirmation/$orderId');
      } else if (next is PaymentProcessingFailedState) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage),
            backgroundColor: AppColors.error,
          ),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Complete Payment'),
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

          final customerName =
              authState is AuthenticatedState ? (authState.user.name ?? 'Customer') : 'Customer';
          final customerPhone =
              authState is AuthenticatedState ? authState.user.phoneNumber : '';

          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
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
                        const Text('Order Summary',
                            style: AppTypography.titleLarge),
                        const Divider(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Order ID', style: AppTypography.bodyMedium),
                            Text(
                              '#${order.orderId.substring(0, order.orderId.length > 8 ? 8 : order.orderId.length).toUpperCase()}',
                              style: AppTypography.titleMedium,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
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
                        const Divider(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Total Amount Payable',
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
                ),
                const SizedBox(height: 24),

                // Gateway Simulation Box
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.shield_outlined,
                            color: AppColors.primary,
                          ),
                          SizedBox(width: 8),
                          Text(
                            '256-Bit Razorpay Encrypted Gateway',
                            style: AppTypography.titleMedium,
                          ),
                        ],
                      ),
                      SizedBox(height: 6),
                      Text(
                        'Supports UPI (GPay, PhonePe, Paytm), Credit/Debit Cards, and NetBanking.',
                        style: AppTypography.labelSmall,
                      ),
                    ],
                  ),
                ),
                const Spacer(),

                // Action Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isLoading
                        ? null
                        : () {
                            ref
                                .read(paymentProcessingProvider.notifier)
                                .processPayment(
                                  order: order,
                                  customerName: customerName,
                                  customerPhone: customerPhone,
                                );
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: isLoading
                        ? const AppLoadingIndicator()
                        : Text(order.paymentMethod == PaymentMethod.online
                            ? 'Pay ₹${order.totalAmount.toStringAsFixed(0)} via Razorpay'
                            : 'Confirm Cash Order'),
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          );
        },
        loading: () => const Center(
          child: AppLoadingIndicator(
            message: 'Loading payment details...',
          ),
        ),
        error: (error, _) => Center(
          child: AppErrorWidget(
            title: 'Failed to load payment details',
            message: error.toString(),
            onRetry: () {
              ref.invalidate(orderDetailsProvider(orderId));
            },
          ),
        ),
      ),
    );
  }
}
