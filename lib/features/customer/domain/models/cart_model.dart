import 'cart_item_model.dart';

class CartModel {
  final String? stallId;
  final String? stallName;
  final List<CartItemModel> items;

  const CartModel({
    this.stallId,
    this.stallName,
    this.items = const [],
  });

  bool get isEmpty => items.isEmpty;
  bool get isNotEmpty => items.isNotEmpty;

  int get totalItemCount {
    return items.fold(0, (sum, item) => sum + item.quantity);
  }

  double get totalAmount {
    return items.fold(0.0, (sum, item) => sum + item.subtotal);
  }

  CartModel copyWith({
    String? stallId,
    String? stallName,
    List<CartItemModel>? items,
  }) {
    return CartModel(
      stallId: stallId ?? this.stallId,
      stallName: stallName ?? this.stallName,
      items: items ?? this.items,
    );
  }
}
