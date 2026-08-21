import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/cart_item_model.dart';
import '../../domain/models/cart_model.dart';
import '../../domain/models/menu_item_model.dart';

class StallConflictException implements Exception {
  final String currentStallName;
  final String newStallName;
  final MenuItemModel pendingItem;

  StallConflictException({
    required this.currentStallName,
    required this.newStallName,
    required this.pendingItem,
  });

  @override
  String toString() =>
      'Your cart already contains items from $currentStallName. Would you like to clear your cart and add items from $newStallName instead?';
}

class CartNotifier extends Notifier<CartModel> {
  @override
  CartModel build() {
    return const CartModel();
  }

  void addItem(MenuItemModel menuItem, String stallName) {
    if (!menuItem.isAvailable) return;

    if (state.isNotEmpty && state.stallId != menuItem.stallId) {
      throw StallConflictException(
        currentStallName: state.stallName ?? 'another stall',
        newStallName: stallName,
        pendingItem: menuItem,
      );
    }

    final existingIndex =
        state.items.indexWhere((item) => item.menuItem.itemId == menuItem.itemId);

    List<CartItemModel> updatedItems;
    if (existingIndex >= 0) {
      final existingItem = state.items[existingIndex];
      final updatedItem = existingItem.copyWith(quantity: existingItem.quantity + 1);
      updatedItems = List.from(state.items);
      updatedItems[existingIndex] = updatedItem;
    } else {
      updatedItems = [
        ...state.items,
        CartItemModel(menuItem: menuItem, quantity: 1),
      ];
    }

    state = CartModel(
      stallId: menuItem.stallId,
      stallName: stallName,
      items: updatedItems,
    );
  }

  void updateQuantity(String itemId, int delta) {
    if (state.isEmpty) return;

    final existingIndex =
        state.items.indexWhere((item) => item.menuItem.itemId == itemId);

    if (existingIndex < 0) return;

    final existingItem = state.items[existingIndex];
    final newQuantity = existingItem.quantity + delta;

    List<CartItemModel> updatedItems = List.from(state.items);

    if (newQuantity <= 0) {
      updatedItems.removeAt(existingIndex);
    } else {
      updatedItems[existingIndex] = existingItem.copyWith(quantity: newQuantity);
    }

    if (updatedItems.isEmpty) {
      state = const CartModel();
    } else {
      state = state.copyWith(items: updatedItems);
    }
  }

  void removeItem(String itemId) {
    if (state.isEmpty) return;

    final updatedItems =
        state.items.where((item) => item.menuItem.itemId != itemId).toList();

    if (updatedItems.isEmpty) {
      state = const CartModel();
    } else {
      state = state.copyWith(items: updatedItems);
    }
  }

  void replaceCart(MenuItemModel menuItem, String stallName) {
    if (!menuItem.isAvailable) return;

    state = CartModel(
      stallId: menuItem.stallId,
      stallName: stallName,
      items: [
        CartItemModel(menuItem: menuItem, quantity: 1),
      ],
    );
  }

  void clearCart() {
    state = const CartModel();
  }
}

final cartProvider = NotifierProvider<CartNotifier, CartModel>(CartNotifier.new);
