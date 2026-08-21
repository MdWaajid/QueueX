import 'package:flutter_test/flutter_test.dart';
import 'package:queuex/features/customer/domain/models/menu_item_model.dart';

void main() {
  group('MenuItemModel Unit Tests', () {
    test('MenuItemModel fromMap parses correctly', () {
      final map = {
        'stallId': 'stall_1',
        'categoryId': 'cat_1',
        'itemName': 'Paneer Butter Masala',
        'description': 'Rich creamy gravy',
        'price': 220.0,
        'imageUrl': 'https://example.com/paneer.jpg',
        'preparationTimeMinutes': 15,
        'isAvailable': true,
      };

      final menuItem = MenuItemModel.fromMap(map, 'item_101');

      expect(menuItem.itemId, 'item_101');
      expect(menuItem.stallId, 'stall_1');
      expect(menuItem.itemName, 'Paneer Butter Masala');
      expect(menuItem.price, 220.0);
      expect(menuItem.preparationTimeMinutes, 15);
      expect(menuItem.isAvailable, isTrue);
    });

    test('MenuItemModel toMap formats timestamps correctly', () {
      const item = MenuItemModel(
        itemId: 'item_1',
        stallId: 'stall_1',
        categoryId: 'cat_1',
        itemName: 'Cold Coffee',
        description: 'Chilled coffee with ice cream',
        price: 90.0,
        imageUrl: '',
        preparationTimeMinutes: 5,
        isAvailable: false,
      );

      final map = item.toMap();

      expect(map['itemId'], 'item_1');
      expect(map['itemName'], 'Cold Coffee');
      expect(map['price'], 90.0);
      expect(map['isAvailable'], isFalse);
    });
  });
}
