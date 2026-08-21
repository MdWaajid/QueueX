import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_error_widget.dart';
import '../../../../core/widgets/app_loading_indicator.dart';
import '../../domain/models/menu_item_model.dart';
import '../../domain/models/stall_model.dart';
import '../providers/cart_provider.dart';
import '../providers/customer_discovery_provider.dart';
import '../providers/menu_provider.dart';
import '../widgets/cart_bottom_sheet.dart';
import '../widgets/category_chip.dart';
import '../widgets/crowd_indicator_chip.dart';
import '../widgets/item_details_dialog.dart';
import '../widgets/menu_item_card.dart';
import '../widgets/persistent_cart_bar.dart';

class StallDetailsScreen extends ConsumerStatefulWidget {
  final String stallId;

  const StallDetailsScreen({
    super.key,
    required this.stallId,
  });

  @override
  ConsumerState<StallDetailsScreen> createState() => _StallDetailsScreenState();
}

class _StallDetailsScreenState extends ConsumerState<StallDetailsScreen> {
  String? _selectedCategoryId;

  @override
  Widget build(BuildContext context) {
    final stallAsync = ref.watch(stallDetailsProvider(widget.stallId));
    final categoriesAsync = ref.watch(stallCategoriesProvider(widget.stallId));
    final cart = ref.watch(cartProvider);
    final cartNotifier = ref.read(cartProvider.notifier);

    final menuArgs = MenuItemsArgs(
      stallId: widget.stallId,
      categoryId: _selectedCategoryId,
    );
    final menuItemsAsync = ref.watch(menuItemsProvider(menuArgs));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Stall Details'),
        actions: [
          if (cart.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.shopping_cart_outlined),
              onPressed: () => _openCartSheet(context),
            ),
        ],
      ),
      body: stallAsync.when(
        data: (stall) {
          if (stall == null) {
            return const Center(
              child: Text(
                'Stall not found',
                style: AppTypography.titleMedium,
              ),
            );
          }

          return Stack(
            children: [
              RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(stallDetailsProvider(widget.stallId));
                  ref.invalidate(stallCategoriesProvider(widget.stallId));
                  ref.invalidate(menuItemsProvider(menuArgs));
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.only(bottom: cart.isNotEmpty ? 80 : 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                    // Stall Banner Image
                    Container(
                      height: 200,
                      width: double.infinity,
                      color: AppColors.background,
                      child: stall.stallImage.startsWith('http')
                          ? Image.network(
                              stall.stallImage,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  _buildPlaceholderImage(),
                            )
                          : _buildPlaceholderImage(),
                    ),

                    // Closed Stall Warning Banner
                    if (stall.isClosed)
                      Container(
                        width: double.infinity,
                        color: AppColors.error.withValues(alpha: 0.12),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.info_outline_rounded,
                              color: AppColors.error,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'This stall is currently closed and not accepting new orders.',
                                style: AppTypography.labelSmall.copyWith(
                                  color: AppColors.error,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Stall Header Info
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      stall.stallName,
                                      style: AppTypography.titleLarge,
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.location_on_outlined,
                                          size: 16,
                                          color: AppColors.textSecondary,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          stall.locationName.isNotEmpty
                                              ? stall.locationName
                                              : 'Main Food Court',
                                          style: AppTypography.bodyMedium,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: stall.isOpen
                                          ? AppColors.success
                                          : AppColors.textDisabled,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      stall.isOpen ? 'OPEN' : 'CLOSED',
                                      style: AppTypography.labelSmall.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  if (stall.isOpen) ...[
                                    const SizedBox(height: 6),
                                    CrowdIndicatorChip(
                                      crowdState: stall.crowdState,
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          if (stall.description.isNotEmpty) ...[
                            Text(
                              stall.description,
                              style: AppTypography.bodyMedium,
                            ),
                            const SizedBox(height: 12),
                          ],

                          // Opening Hours & Phone
                          Card(
                            color: AppColors.background,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                              side: const BorderSide(color: AppColors.divider),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.access_time_rounded,
                                        size: 18,
                                        color: AppColors.primary,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Hours: ${stall.openingTime} - ${stall.closingTime}',
                                        style: AppTypography.labelSmall,
                                      ),
                                    ],
                                  ),
                                  if (stall.phoneNumber.isNotEmpty) ...[
                                    const Divider(height: 16),
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.phone_outlined,
                                          size: 18,
                                          color: AppColors.primary,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          stall.phoneNumber,
                                          style: AppTypography.labelSmall,
                                        ),
                                      ],
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Peak Mode Highlight
                          if (stall.isPeakModeEnabled)
                            Container(
                              width: double.infinity,
                              margin: const EdgeInsets.only(bottom: 20),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.error.withValues(alpha: 0.08),
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
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'High Demand Peak Mode Active! Online payment required for slot pickup.',
                                      style: AppTypography.labelSmall,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                          // Categories Tabs Header
                          categoriesAsync.when(
                            data: (categories) {
                              if (categories.isEmpty) return const SizedBox.shrink();
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Categories',
                                    style: AppTypography.titleLarge,
                                  ),
                                  const SizedBox(height: 8),
                                  SizedBox(
                                    height: 40,
                                    child: ListView.separated(
                                      scrollDirection: Axis.horizontal,
                                      itemCount: categories.length + 1,
                                      separatorBuilder: (_, _) =>
                                          const SizedBox(width: 8),
                                      itemBuilder: (context, index) {
                                        if (index == 0) {
                                          return CategoryChip(
                                            label: 'All Items',
                                            isSelected: _selectedCategoryId == null,
                                            onTap: () {
                                              setState(() {
                                                _selectedCategoryId = null;
                                              });
                                            },
                                          );
                                        }
                                        final cat = categories[index - 1];
                                        final isSelected =
                                            _selectedCategoryId == cat.categoryId;
                                        return CategoryChip(
                                          label: cat.name,
                                          isSelected: isSelected,
                                          onTap: () {
                                            setState(() {
                                              _selectedCategoryId = isSelected
                                                  ? null
                                                  : cat.categoryId;
                                            });
                                          },
                                        );
                                      },
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                ],
                              );
                            },
                            loading: () => const SizedBox.shrink(),
                            error: (_, _) => const SizedBox.shrink(),
                          ),

                          // Menu Items Header
                          const Text(
                            'Menu Items',
                            style: AppTypography.titleLarge,
                          ),
                          const SizedBox(height: 12),

                          // Menu Items Listing
                          menuItemsAsync.when(
                            data: (items) {
                              if (items.isEmpty) {
                                return const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 24),
                                  child: AppEmptyState(
                                    title: 'No Menu Items Available',
                                    message:
                                        'This stall hasn\'t added any items to this category yet.',
                                    icon: Icons.restaurant_outlined,
                                  ),
                                );
                              }

                              return ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: items.length,
                                itemBuilder: (context, index) {
                                  final menuItem = items[index];
                                  final cartItemIndex = cart.items.indexWhere(
                                      (i) => i.menuItem.itemId == menuItem.itemId);
                                  final cartQty = cartItemIndex >= 0
                                      ? cart.items[cartItemIndex].quantity
                                      : 0;

                                  return MenuItemCard(
                                    menuItem: menuItem,
                                    cartQuantity: cartQty,
                                    onTap: () =>
                                        _showItemDetailsDialog(context, menuItem, stall),
                                    onAdd: () =>
                                        _handleAddToCart(context, menuItem, stall),
                                    onQuantityChanged: (delta) {
                                      cartNotifier.updateQuantity(
                                          menuItem.itemId, delta);
                                    },
                                  );
                                },
                              );
                            },
                            loading: () => const Center(
                              child: Padding(
                                padding: EdgeInsets.all(24),
                                child: AppLoadingIndicator(
                                  message: 'Loading menu items...',
                                ),
                              ),
                            ),
                            error: (error, _) => AppErrorWidget(
                              title: 'Failed to load menu items',
                              message: error.toString(),
                              onRetry: () {
                                ref.invalidate(menuItemsProvider(menuArgs));
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

              // Persistent Cart Floating Bar
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: PersistentCartBar(
                  cart: cart,
                  onViewCart: () => _openCartSheet(context),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(
          child: AppLoadingIndicator(
            message: 'Loading stall details...',
          ),
        ),
        error: (error, stackTrace) => Center(
          child: AppErrorWidget(
            title: 'Failed to load stall details',
            message: error.toString(),
            onRetry: () {
              ref.invalidate(stallDetailsProvider(widget.stallId));
            },
          ),
        ),
      ),
    );
  }

  void _handleAddToCart(
      BuildContext context, MenuItemModel menuItem, StallModel stall) {
    if (stall.isClosed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cannot add items from a closed stall.'),
        ),
      );
      return;
    }

    try {
      ref
          .read(cartProvider.notifier)
          .addItem(menuItem, stall.stallName);
    } on StallConflictException catch (e) {
      _showStallConflictDialog(context, e);
    }
  }

  void _showStallConflictDialog(
      BuildContext context, StallConflictException exception) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Clear Existing Cart?'),
        content: Text(
          'Your cart contains items from "${exception.currentStallName}". Do you want to clear your cart and start a new order from "${exception.newStallName}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              ref
                  .read(cartProvider.notifier)
                  .replaceCart(exception.pendingItem, exception.newStallName);
              Navigator.of(dialogContext).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Clear & Add'),
          ),
        ],
      ),
    );
  }

  void _showItemDetailsDialog(
      BuildContext context, MenuItemModel menuItem, StallModel stall) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => ItemDetailsDialog(
        menuItem: menuItem,
        onAddToCart: stall.isOpen && menuItem.isAvailable
            ? () => _handleAddToCart(context, menuItem, stall)
            : null,
      ),
    );
  }

  void _openCartSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => CartBottomSheet(
        onProceedToCart: () {
          context.push('/customer/cart');
        },
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      color: AppColors.primary.withValues(alpha: 0.08),
      child: const Center(
        child: Icon(
          Icons.storefront_rounded,
          size: 64,
          color: AppColors.primary,
        ),
      ),
    );
  }
}
