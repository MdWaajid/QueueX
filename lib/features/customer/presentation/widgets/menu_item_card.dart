import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../domain/models/menu_item_model.dart';

class MenuItemCard extends StatelessWidget {
  final MenuItemModel menuItem;
  final int cartQuantity;
  final VoidCallback onAdd;
  final ValueChanged<int> onQuantityChanged;
  final VoidCallback? onTap;

  const MenuItemCard({
    super.key,
    required this.menuItem,
    required this.cartQuantity,
    required this.onAdd,
    required this.onQuantityChanged,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isOutofStock = !menuItem.isAvailable;

    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(
          color: AppColors.divider,
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image / Thumbnail
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      width: 80,
                      height: 80,
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
                  if (isOutofStock)
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          'OUT OF\nSTOCK',
                          textAlign: TextAlign.center,
                          style: AppTypography.labelSmall.copyWith(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 12),

              // Item Information
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      menuItem.itemName,
                      style: AppTypography.titleMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    if (menuItem.description.isNotEmpty) ...[
                      Text(
                        menuItem.description,
                        style: AppTypography.labelSmall,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                    ],
                    Row(
                      children: [
                        const Icon(
                          Icons.timer_outlined,
                          size: 14,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${menuItem.preparationTimeMinutes} mins',
                          style: AppTypography.labelSmall,
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '₹${menuItem.price.toStringAsFixed(0)}',
                      style: AppTypography.titleMedium.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              // Action / Quantity Controls
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (isOutofStock)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.textDisabled.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Unavailable',
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.textDisabled,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )
                  else if (cartQuantity == 0)
                    ElevatedButton(
                      onPressed: onAdd,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(64, 32),
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('ADD'),
                    )
                  else
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.primary),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove, size: 16),
                            onPressed: () => onQuantityChanged(-1),
                            color: AppColors.primary,
                            constraints: const BoxConstraints(
                              minWidth: 32,
                              minHeight: 32,
                            ),
                            padding: EdgeInsets.zero,
                          ),
                          Text(
                            '$cartQuantity',
                            style: AppTypography.titleMedium.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add, size: 16),
                            onPressed: () => onQuantityChanged(1),
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
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: AppColors.primary.withValues(alpha: 0.08),
      child: const Center(
        child: Icon(
          Icons.fastfood_outlined,
          size: 32,
          color: AppColors.primary,
        ),
      ),
    );
  }
}
