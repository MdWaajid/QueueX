import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/widgets/app_loading_indicator.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../customer/presentation/providers/cart_provider.dart';
import '../../../customer/presentation/providers/customer_discovery_provider.dart';
import '../../../slots/presentation/providers/slot_provider.dart';
import '../../domain/models/order_item_model.dart';
import '../../domain/models/order_model.dart';
import '../providers/order_provider.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  PaymentMethod _selectedPaymentMethod = PaymentMethod.online;

  @override
  Widget build(BuildContext context) {
    final cart = ref.watch(cartProvider);
    final selectedSlot = ref.watch(selectedSlotProvider);
    final authState = ref.watch(authControllerProvider);
    final orderCreationState = ref.watch(orderCreationProvider);

    final String stallId = cart.stallId ?? '';
    final stallAsync = ref.watch(stallDetailsProvider(stallId));

    final isPeakMode = stallAsync.when(
      data: (stall) => stall?.isPeakModeEnabled ?? false,
      loading: () => false,
      error: (_, _) => false,
    );

    ref.listen<OrderCreationState>(orderCreationProvider, (previous, next) {
      if (next is OrderCreationErrorState) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.message),
            backgroundColor: AppColors.error,
          ),
        );
      }
    });

    if (cart.isEmpty || selectedSlot == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Checkout')),
        body: const Center(
          child: Text(
            'Your cart or pickup slot selection is missing.',
            style: AppTypography.titleMedium,
          ),
        ),
      );
    }

    final isLoading = orderCreationState is OrderCreationLoadingState;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout & Payment'),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Stall & Pickup Slot Card
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
                          Row(
                            children: [
                              const Icon(
                                Icons.storefront_rounded,
                                color: AppColors.primary,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  cart.stallName ?? 'Food Stall',
                                  style: AppTypography.titleLarge,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 20),
                          Row(
                            children: [
                              const Icon(
                                Icons.access_time_filled_rounded,
                                size: 18,
                                color: AppColors.primary,
                              ),
                              const SizedBox(width: 8),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Pickup Slot Window',
                                    style: AppTypography.labelSmall,
                                  ),
                                  Text(
                                    '${_formatTime(selectedSlot.startTime)} - ${_formatTime(selectedSlot.endTime)}',
                                    style: AppTypography.titleMedium.copyWith(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Order Items Breakdown
                  const Text('Order Items', style: AppTypography.titleLarge),
                  const SizedBox(height: 10),
                  Card(
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(color: AppColors.divider),
                    ),
                    child: ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(16),
                      itemCount: cart.items.length,
                      separatorBuilder: (_, _) => const Divider(height: 16),
                      itemBuilder: (context, index) {
                        final item = cart.items[index];
                        return Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.menuItem.itemName,
                                    style: AppTypography.titleMedium,
                                  ),
                                  Text(
                                    'Qty: ${item.quantity} × ₹${item.menuItem.price.toStringAsFixed(0)}',
                                    style: AppTypography.labelSmall,
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              '₹${item.subtotal.toStringAsFixed(0)}',
                              style: AppTypography.titleMedium.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Peak Mode Warning Banner
                  if (isPeakMode)
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.error.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: AppColors.error.withValues(alpha: 0.3)),
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.local_fire_department_rounded,
                            color: AppColors.error,
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Peak Demand Mode Active! Pay Cash at Stall is disabled. Online payment is required for slot pickup.',
                              style: AppTypography.labelSmall,
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Payment Method Selector
                  const Text('Select Payment Method',
                      style: AppTypography.titleLarge),
                  const SizedBox(height: 10),
                  Card(
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(color: AppColors.divider),
                    ),
                    child: Column(
                      children: [
                        // ignore: deprecated_member_use
                        RadioListTile<PaymentMethod>(
                          title: Text(PaymentMethod.online.label),
                          subtitle: const Text('Instant confirmation & digital receipt'),
                          value: PaymentMethod.online,
                          // ignore: deprecated_member_use
                          groupValue: _selectedPaymentMethod,
                          activeColor: AppColors.primary,
                          // ignore: deprecated_member_use
                          onChanged: (val) {
                            if (val != null) {
                              setState(() {
                                _selectedPaymentMethod = val;
                              });
                            }
                          },
                        ),
                        const Divider(height: 1),
                        // ignore: deprecated_member_use
                        RadioListTile<PaymentMethod>(
                          title: Text(
                            PaymentMethod.offline.label,
                            style: TextStyle(
                              color: isPeakMode
                                  ? AppColors.textDisabled
                                  : AppColors.textPrimary,
                            ),
                          ),
                          subtitle: Text(
                            isPeakMode
                                ? 'Disabled during Peak Demand Mode'
                                : 'Pay at counter when picking up food',
                            style: TextStyle(
                              color: isPeakMode
                                  ? AppColors.error
                                  : AppColors.textSecondary,
                            ),
                          ),
                          value: PaymentMethod.offline,
                          // ignore: deprecated_member_use
                          groupValue: _selectedPaymentMethod,
                          activeColor: AppColors.primary,
                          // ignore: deprecated_member_use
                          onChanged: isPeakMode
                              ? null
                              : (val) {
                                  if (val != null) {
                                    setState(() {
                                      _selectedPaymentMethod = val;
                                    });
                                  }
                                },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Total Price & Place Order Action
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 10,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total Amount', style: AppTypography.bodyMedium),
                      Text(
                        '₹${cart.totalAmount.toStringAsFixed(0)}',
                        style: AppTypography.titleLarge.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : () => _handlePlaceOrder(context, authState, isPeakMode),
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
                          : const Text('Place Order'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handlePlaceOrder(
      BuildContext context, AuthState authState, bool isPeakMode) async {
    if (authState is! AuthenticatedState) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to place an order.')),
      );
      return;
    }

    final cart = ref.read(cartProvider);
    final selectedSlot = ref.read(selectedSlotProvider);

    if (cart.isEmpty || selectedSlot == null || cart.stallId == null) return;

    final orderItems = cart.items
        .map(
          (ci) => OrderItemModel(
            orderItemId: '',
            orderId: '',
            itemId: ci.menuItem.itemId,
            itemName: ci.menuItem.itemName,
            unitPrice: ci.menuItem.price,
            quantity: ci.quantity,
            subtotal: ci.subtotal,
          ),
        )
        .toList();

    final order = await ref.read(orderCreationProvider.notifier).placeOrder(
          customerId: authState.user.userId,
          stallId: cart.stallId!,
          slotId: selectedSlot.slotId,
          slotStartTime: selectedSlot.startTime,
          slotEndTime: selectedSlot.endTime,
          totalAmount: cart.totalAmount,
          paymentMethod: _selectedPaymentMethod,
          isPeakModeEnabled: isPeakMode,
          items: orderItems,
        );

    if (order != null && mounted && context.mounted) {
      ref.read(cartProvider.notifier).clearCart();
      ref.read(selectedSlotProvider.notifier).clearSelection();
      if (order.paymentMethod == PaymentMethod.online) {
        context.go('/customer/payment/${order.orderId}');
      } else {
        context.go('/customer/order-confirmation/${order.orderId}');
      }
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
