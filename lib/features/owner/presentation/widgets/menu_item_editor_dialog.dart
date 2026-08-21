import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../customer/domain/models/menu_item_model.dart';
import '../providers/owner_menu_provider.dart';

class MenuItemEditorDialog extends ConsumerStatefulWidget {
  final String stallId;
  final MenuItemModel? itemToEdit;

  const MenuItemEditorDialog({
    super.key,
    required this.stallId,
    this.itemToEdit,
  });

  @override
  ConsumerState<MenuItemEditorDialog> createState() =>
      _MenuItemEditorDialogState();
}

class _MenuItemEditorDialogState extends ConsumerState<MenuItemEditorDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;
  late TextEditingController _imageUrlController;
  late String _selectedCategory;
  late bool _isAvailable;

  final List<String> _categories = [
    'Main Course',
    'Starters',
    'Snacks',
    'Beverages',
    'Desserts',
  ];

  @override
  void initState() {
    super.initState();
    final item = widget.itemToEdit;
    _nameController = TextEditingController(text: item?.name ?? '');
    _descriptionController = TextEditingController(text: item?.description ?? '');
    _priceController =
        TextEditingController(text: item != null ? item.price.toStringAsFixed(0) : '');
    _imageUrlController = TextEditingController(text: item?.imageUrl ?? '');

    _selectedCategory = item != null && _categories.contains(item.category)
        ? item.category
        : _categories.first;

    _isAvailable = item?.isAvailable ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.itemToEdit != null;
    final formState = ref.watch(ownerMenuFormProvider);
    final isLoading = formState is OwnerMenuFormLoadingState;

    return AlertDialog(
      title: Text(
        isEditing ? 'Edit Menu Item' : 'Add New Menu Item',
        style: AppTypography.titleMedium,
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Item Name *',
                  hintText: 'e.g. Paneer Butter Masala',
                ),
                validator: (val) =>
                    val == null || val.trim().isEmpty ? 'Enter item name' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description *',
                  hintText: 'e.g. Rich creamy cottage cheese curry',
                ),
                maxLines: 2,
                validator: (val) =>
                    val == null || val.trim().isEmpty ? 'Enter description' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Price (₹) *',
                  hintText: 'e.g. 180',
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return 'Enter price';
                  final price = double.tryParse(val.trim());
                  if (price == null || price <= 0) return 'Enter valid positive price';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Category *',
                ),
                items: _categories
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _selectedCategory = val;
                    });
                  }
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _imageUrlController,
                decoration: const InputDecoration(
                  labelText: 'Image URL (Optional)',
                  hintText: 'https://example.com/image.jpg',
                ),
              ),
              const SizedBox(height: 12),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Available in Stock', style: AppTypography.bodyMedium),
                subtitle: Text(
                  _isAvailable ? 'Item visible & purchasable' : 'Item marked Out of Stock',
                  style: AppTypography.labelSmall,
                ),
                value: _isAvailable,
                activeThumbColor: AppColors.success,
                onChanged: (val) {
                  setState(() {
                    _isAvailable = val;
                  });
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: isLoading ? null : _saveForm,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
          ),
          child: Text(isEditing ? 'Save Changes' : 'Add Item'),
        ),
      ],
    );
  }

  void _saveForm() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final name = _nameController.text.trim();
    final description = _descriptionController.text.trim();
    final price = double.parse(_priceController.text.trim());
    final imageUrl = _imageUrlController.text.trim();

    bool success = false;

    if (widget.itemToEdit != null) {
      final updatedItem = widget.itemToEdit!.copyWith(
        name: name,
        description: description,
        price: price,
        category: _selectedCategory,
        imageUrl: imageUrl,
        isAvailable: _isAvailable,
      );

      success = await ref
          .read(ownerMenuFormProvider.notifier)
          .updateMenuItem(updatedItem);
    } else {
      success = await ref.read(ownerMenuFormProvider.notifier).addMenuItem(
            stallId: widget.stallId,
            name: name,
            description: description,
            price: price,
            category: _selectedCategory,
            imageUrl: imageUrl,
            isAvailable: _isAvailable,
          );
    }

    if (success && mounted && context.mounted) {
      Navigator.of(context).pop();
    }
  }
}
