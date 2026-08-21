import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/widgets/app_empty_state.dart';
import 'package:go_router/go_router.dart';
import '../providers/cart_provider.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartProvider);
    final cartNotifier = ref.read(cartProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Cart'),
        actions: [
          if (cart.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded),
              tooltip: 'Clear Cart',
              onPressed: () {
                cartNotifier.clearCart();
              },
            ),
        ],
      ),
      body: cart.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: AppEmptyState(
                  title: 'Your Cart is Empty',
                  message:
                      'Browse food stalls and add items to your cart to start an order.',
                  icon: Icons.shopping_cart_outlined,
                ),
              ),
            )
          : Column(
              children: [
                // Stall Banner Header Card
                Container(
                  width: double.infinity,
                  color: AppColors.background,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.storefront_rounded,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Ordering from',
                              style: AppTypography.labelSmall,
                            ),
                            Text(
                              cart.stallName ?? 'Food Stall',
                              style: AppTypography.titleMedium,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Selected Items List
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: cart.items.length,
                    separatorBuilder: (_, _) => const Divider(height: 20),
                    itemBuilder: (context, index) {
                      final cartItem = cart.items[index];
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  cartItem.menuItem.itemName,
                                  style: AppTypography.titleMedium,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '₹${cartItem.menuItem.price.toStringAsFixed(0)} each',
                                  style: AppTypography.labelSmall,
                                ),
                              ],
                            ),
                          ),

                          // Quantity Controls
                          Container(
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove, size: 16),
                                  onPressed: () => cartNotifier.updateQuantity(
                                      cartItem.menuItem.itemId, -1),
                                  color: AppColors.primary,
                                  constraints: const BoxConstraints(
                                    minWidth: 32,
                                    minHeight: 32,
                                  ),
                                  padding: EdgeInsets.zero,
                                ),
                                Text(
                                  '${cartItem.quantity}',
                                  style: AppTypography.titleMedium.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.add, size: 16),
                                  onPressed: () => cartNotifier.updateQuantity(
                                      cartItem.menuItem.itemId, 1),
                                  color: AppColors.primary,
                                  constraints: const BoxConstraints(
                                    minWidth: 32,
                                    minHeight: 32,
                                  ),
                                  padding: EdgeInsets.zero,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),

                          Text(
                            '₹${cartItem.subtotal.toStringAsFixed(0)}',
                            style: AppTypography.titleMedium.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),

                // Order Total Breakdown & Action Footer
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
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
                            const Text('Total Item Amount',
                                style: AppTypography.bodyMedium),
                            Text(
                              '₹${cart.totalAmount.toStringAsFixed(0)}',
                              style: AppTypography.titleLarge.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: cart.stallId != null
                                ? () {
                                    context.push('/customer/slots/${cart.stallId}');
                                  }
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text('Proceed to Slot Selection'),
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
}
