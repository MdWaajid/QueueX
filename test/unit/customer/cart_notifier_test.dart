import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:queuex/features/customer/domain/models/menu_item_model.dart';
import 'package:queuex/features/customer/presentation/providers/cart_provider.dart';

void main() {
  group('CartNotifier Unit Tests', () {
    late ProviderContainer container;

    const item1 = MenuItemModel(
      itemId: 'item_1',
      stallId: 'stall_1',
      categoryId: 'cat_1',
      itemName: 'Burger',
      description: 'Tasty burger',
      price: 150.0,
      imageUrl: '',
      preparationTimeMinutes: 10,
      isAvailable: true,
    );

    const item2 = MenuItemModel(
      itemId: 'item_2',
      stallId: 'stall_1',
      categoryId: 'cat_1',
      itemName: 'Fries',
      description: 'Crispy fries',
      price: 80.0,
      imageUrl: '',
      preparationTimeMinutes: 5,
      isAvailable: true,
    );

    const itemOtherStall = MenuItemModel(
      itemId: 'item_3',
      stallId: 'stall_2',
      categoryId: 'cat_1',
      itemName: 'Pizza',
      description: 'Cheese pizza',
      price: 250.0,
      imageUrl: '',
      preparationTimeMinutes: 15,
      isAvailable: true,
    );

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('Initial cart is empty', () {
      final cart = container.read(cartProvider);
      expect(cart.isEmpty, isTrue);
      expect(cart.totalItemCount, 0);
      expect(cart.totalAmount, 0.0);
    });

    test('addItem adds item and calculates total correctly', () {
      final cartNotifier = container.read(cartProvider.notifier);

      cartNotifier.addItem(item1, 'Burger Hub');

      var cart = container.read(cartProvider);
      expect(cart.totalItemCount, 1);
      expect(cart.totalAmount, 150.0);
      expect(cart.stallId, 'stall_1');

      cartNotifier.addItem(item1, 'Burger Hub');
      cart = container.read(cartProvider);
      expect(cart.totalItemCount, 2);
      expect(cart.totalAmount, 300.0);

      cartNotifier.addItem(item2, 'Burger Hub');
      cart = container.read(cartProvider);
      expect(cart.totalItemCount, 3);
      expect(cart.totalAmount, 380.0);
    });

    test('updateQuantity increments, decrements, and removes on 0', () {
      final cartNotifier = container.read(cartProvider.notifier);
      cartNotifier.addItem(item1, 'Burger Hub');

      cartNotifier.updateQuantity('item_1', 1);
      expect(container.read(cartProvider).totalItemCount, 2);

      cartNotifier.updateQuantity('item_1', -1);
      expect(container.read(cartProvider).totalItemCount, 1);

      cartNotifier.updateQuantity('item_1', -1);
      expect(container.read(cartProvider).isEmpty, isTrue);
    });

    test('addItem from different stall throws StallConflictException', () {
      final cartNotifier = container.read(cartProvider.notifier);
      cartNotifier.addItem(item1, 'Burger Hub');

      expect(
        () => cartNotifier.addItem(itemOtherStall, 'Pizza Place'),
        throwsA(isA<StallConflictException>()),
      );
    });

    test('clearCart empties cart completely', () {
      final cartNotifier = container.read(cartProvider.notifier);
      cartNotifier.addItem(item1, 'Burger Hub');
      cartNotifier.clearCart();

      final cart = container.read(cartProvider);
      expect(cart.isEmpty, isTrue);
      expect(cart.stallId, isNull);
    });
  });
}
