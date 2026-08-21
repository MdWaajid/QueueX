import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../domain/models/menu_item_model.dart';

class ItemDetailsDialog extends StatelessWidget {
  final MenuItemModel menuItem;
  final VoidCallback? onAddToCart;

  const ItemDetailsDialog({
    super.key,
    required this.menuItem,
    this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner Image Header
          Stack(
            children: [
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16)),
                child: Container(
                  height: 160,
                  width: double.infinity,
                  color: AppColors.background,
                  child: menuItem.imageUrl.startsWith('http')
                      ? Image.network(
                          menuItem.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => _buildPlaceholder(),
                        )
                      : _buildPlaceholder(),
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: IconButton(
                  icon: const Icon(Icons.close_rounded, color: Colors.white),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.black.withValues(alpha: 0.5),
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        menuItem.itemName,
                        style: AppTypography.titleLarge,
                      ),
                    ),
                    Text(
                      '₹${menuItem.price.toStringAsFixed(0)}',
                      style: AppTypography.titleLarge.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.timer_outlined,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Preparation Time: ${menuItem.preparationTimeMinutes} mins',
                      style: AppTypography.labelSmall,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (menuItem.description.isNotEmpty) ...[
                  Text(
                    menuItem.description,
                    style: AppTypography.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                ],
                if (!menuItem.isAvailable)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'This item is currently out of stock.',
                      textAlign: TextAlign.center,
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.error,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                else if (onAddToCart != null)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        onAddToCart!();
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text('Add to Cart'),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: AppColors.primary.withValues(alpha: 0.08),
      child: const Center(
        child: Icon(
          Icons.fastfood_outlined,
          size: 48,
          color: AppColors.primary,
        ),
      ),
    );
  }
}
