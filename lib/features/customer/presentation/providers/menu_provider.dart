import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/menu_item_model.dart';
import 'customer_discovery_provider.dart';

class MenuItemsArgs {
  final String stallId;
  final String? categoryId;

  const MenuItemsArgs({
    required this.stallId,
    this.categoryId,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MenuItemsArgs &&
          runtimeType == other.runtimeType &&
          stallId == other.stallId &&
          categoryId == other.categoryId;

  @override
  int get hashCode => stallId.hashCode ^ categoryId.hashCode;
}

final menuItemsProvider =
    FutureProvider.family<List<MenuItemModel>, MenuItemsArgs>(
        (ref, args) async {
  final repository = ref.watch(customerDiscoveryRepositoryProvider);
  return repository.getMenuItems(
    stallId: args.stallId,
    categoryId: args.categoryId,
  );
});

final menuItemDetailProvider =
    FutureProvider.family<MenuItemModel?, String>((ref, itemId) async {
  final repository = ref.watch(customerDiscoveryRepositoryProvider);
  return repository.getMenuItemById(itemId);
});
