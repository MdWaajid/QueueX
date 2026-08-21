import 'menu_item_model.dart';

class CartItemModel {
  final MenuItemModel menuItem;
  final int quantity;

  const CartItemModel({
    required this.menuItem,
    required this.quantity,
  });

  double get subtotal => menuItem.price * quantity;

  CartItemModel copyWith({
    MenuItemModel? menuItem,
    int? quantity,
  }) {
    return CartItemModel(
      menuItem: menuItem ?? this.menuItem,
      quantity: quantity ?? this.quantity,
    );
  }
}
