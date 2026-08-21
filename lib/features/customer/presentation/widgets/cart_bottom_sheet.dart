import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../providers/cart_provider.dart';

class CartBottomSheet extends ConsumerWidget {
  final VoidCallback? onProceedToCart;

  const CartBottomSheet({
    super.key,
    this.onProceedToCart,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartProvider);
    final cartNotifier = ref.read(cartProvider.notifier);

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.75,
      ),
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Header Title & Clear Action
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Your Cart', style: AppTypography.titleLarge),
                    if (cart.stallName != null)
                      Text(
                        cart.stallName!,
                        style: AppTypography.labelSmall,
                      ),
                  ],
                ),
                if (cart.isNotEmpty)
                  TextButton(
                    onPressed: () {
                      cartNotifier.clearCart();
                    },
                    child: Text(
                      'Clear Cart',
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.error,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const Divider(height: 24),

            // Items List
            if (cart.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 32),
                child: AppEmptyState(
                  title: 'Your cart is empty',
                  message: 'Add items from a stall to view them here.',
                  icon: Icons.shopping_cart_outlined,
                ),
              )
            else
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: cart.items.length,
                  separatorBuilder: (_, _) => const Divider(height: 16),
                  itemBuilder: (context, index) {
                    final cartItem = cart.items[index];
                    return Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                cartItem.menuItem.itemName,
                                style: AppTypography.titleMedium,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '₹${cartItem.menuItem.price.toStringAsFixed(0)} × ${cartItem.quantity}',
                                style: AppTypography.labelSmall,
                              ),
                            ],
                          ),
                        ),

                        // Quantity Selector
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
                                  minWidth: 28,
                                  minHeight: 28,
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
                                  minWidth: 28,
                                  minHeight: 28,
                                ),
                                padding: EdgeInsets.zero,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),

                        // Subtotal
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

            if (cart.isNotEmpty) ...[
              const Divider(height: 24),

              // Summary Totals
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Subtotal', style: AppTypography.titleMedium),
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

              // Action Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    if (onProceedToCart != null) {
                      onProceedToCart!();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Proceed to Cart'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
