import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/widgets/app_error_widget.dart';
import '../../../../core/widgets/app_loading_indicator.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../customer/domain/models/menu_item_model.dart';
import '../providers/owner_menu_provider.dart';
import '../widgets/menu_item_editor_dialog.dart';

class OwnerMenuScreen extends ConsumerStatefulWidget {
  final String stallId;

  const OwnerMenuScreen({
    super.key,
    required this.stallId,
  });

  @override
  ConsumerState<OwnerMenuScreen> createState() => _OwnerMenuScreenState();
}

class _OwnerMenuScreenState extends ConsumerState<OwnerMenuScreen> {
  String _selectedCategory = 'All';

  final List<String> _categories = [
    'All',
    'Main Course',
    'Starters',
    'Snacks',
    'Beverages',
    'Desserts',
  ];

  @override
  Widget build(BuildContext context) {
    ref.listen<OwnerMenuFormState>(ownerMenuFormProvider, (prev, next) {
      if (next is OwnerMenuFormSuccessState) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.message),
            backgroundColor: AppColors.success,
          ),
        );
      } else if (next is OwnerMenuFormErrorState) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.message),
            backgroundColor: AppColors.error,
          ),
        );
      }
    });

    final targetStallId = widget.stallId.isNotEmpty ? widget.stallId : _getOwnerStallId(ref);

    if (targetStallId.isEmpty) {
      return const Scaffold(
        body: Center(
          child: Text(
            'No stall configured for this owner account.',
            style: AppTypography.titleMedium,
          ),
        ),
      );
    }

    final menuItemsAsync = ref.watch(ownerMenuItemsStreamProvider(targetStallId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Menu'),
      ),
      body: Column(
        children: [
          // Category Filter Bar
          SizedBox(
            height: 48,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                final isSelected = category == _selectedCategory;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(category),
                    selected: isSelected,
                    selectedColor: AppColors.primary,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : AppColors.textPrimary,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategory = category;
                      });
                    },
                  ),
                );
              },
            ),
          ),
          const Divider(height: 1),

          // Menu Items List
          Expanded(
            child: menuItemsAsync.when(
              data: (items) {
                final filteredItems = _selectedCategory == 'All'
                    ? items
                    : items.where((i) => i.category == _selectedCategory).toList();

                if (filteredItems.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.restaurant_menu_outlined,
                          size: 64,
                          color: AppColors.textSecondary.withValues(alpha: 0.5),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'No menu items found in $_selectedCategory.',
                          style: AppTypography.titleMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredItems.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final item = filteredItems[index];
                    return _buildOwnerMenuItemCard(context, ref, item, targetStallId);
                  },
                );
              },
              loading: () => const Center(
                child: AppLoadingIndicator(message: 'Loading stall menu...'),
              ),
              error: (error, _) => Center(
                child: AppErrorWidget(
                  title: 'Failed to load menu items',
                  message: error.toString(),
                  onRetry: () {
                    ref.invalidate(ownerMenuItemsStreamProvider(targetStallId));
                  },
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _showEditorDialog(context, targetStallId, null);
        },
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Item'),
      ),
    );
  }

  Widget _buildOwnerMenuItemCard(
    BuildContext context,
    WidgetRef ref,
    MenuItemModel item,
    String stallId,
  ) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: AppColors.divider),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            item.name,
                            style: AppTypography.titleMedium.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              item.category,
                              style: AppTypography.labelSmall.copyWith(
                                color: AppColors.primary,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.description,
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '₹${item.price.toStringAsFixed(0)}',
                        style: AppTypography.titleMedium.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                // Availability Switch Toggle
                Column(
                  children: [
                    Switch(
                      value: item.isAvailable,
                      activeThumbColor: AppColors.success,
                      onChanged: (val) {
                        ref
                            .read(ownerMenuFormProvider.notifier)
                            .toggleAvailability(
                              itemId: item.itemId,
                              isAvailable: val,
                            );
                      },
                    ),
                    Text(
                      item.isAvailable ? 'In Stock' : 'Out of Stock',
                      style: AppTypography.labelSmall.copyWith(
                        color: item.isAvailable
                            ? AppColors.success
                            : AppColors.error,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const Divider(height: 16),

            // Action Buttons (Edit & Delete)
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit_outlined, size: 20),
                  color: AppColors.primary,
                  tooltip: 'Edit Item',
                  onPressed: () {
                    _showEditorDialog(context, stallId, item);
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded, size: 20),
                  color: AppColors.error,
                  tooltip: 'Delete Item',
                  onPressed: () {
                    _showDeleteConfirmDialog(context, ref, item);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showEditorDialog(
    BuildContext context,
    String stallId,
    MenuItemModel? itemToEdit,
  ) {
    showDialog<void>(
      context: context,
      builder: (context) => MenuItemEditorDialog(
        stallId: stallId,
        itemToEdit: itemToEdit,
      ),
    );
  }

  void _showDeleteConfirmDialog(
    BuildContext context,
    WidgetRef ref,
    MenuItemModel item,
  ) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Menu Item?'),
        content: Text(
          'Are you sure you want to delete "${item.name}"? This action cannot be undone. (Historical orders will preserve their original purchased prices).',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ref
                  .read(ownerMenuFormProvider.notifier)
                  .deleteMenuItem(item.itemId);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Confirm Delete'),
          ),
        ],
      ),
    );
  }

  String _getOwnerStallId(WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    if (authState is AuthenticatedState) {
      final stallId = authState.user.stallId;
      if (stallId != null && stallId.isNotEmpty) return stallId;
    }
    return 'stall_1';
  }
}
