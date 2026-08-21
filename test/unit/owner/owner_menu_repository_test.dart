import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:queuex/features/customer/domain/models/menu_item_model.dart';
import 'package:queuex/features/owner/data/repositories/owner_menu_repository.dart';
import 'package:queuex/features/owner/presentation/providers/owner_menu_provider.dart';

class MockOwnerMenuRepository implements OwnerMenuRepository {
  final List<MenuItemModel> _items = [
    const MenuItemModel(
      itemId: 'item_1',
      stallId: 'stall_1',
      categoryId: 'Snacks',
      itemName: 'Veg Burger',
      description: 'Tasty veg burger',
      price: 120.0,
      imageUrl: '',
      preparationTimeMinutes: 10,
      isAvailable: true,
    ),
  ];

  @override
  Stream<List<MenuItemModel>> streamStallMenuItems(String stallId) {
    return Stream.value(_items);
  }

  @override
  Future<MenuItemModel> addMenuItem({
    required String stallId,
    required String name,
    required String description,
    required double price,
    required String category,
    String? imageUrl,
    int preparationTimeMinutes = 10,
    bool isAvailable = true,
  }) async {
    final newItem = MenuItemModel(
      itemId: 'item_${_items.length + 1}',
      stallId: stallId,
      categoryId: category,
      itemName: name,
      description: description,
      price: price,
      imageUrl: imageUrl ?? '',
      preparationTimeMinutes: preparationTimeMinutes,
      isAvailable: isAvailable,
    );
    _items.add(newItem);
    return newItem;
  }

  @override
  Future<void> updateMenuItem(MenuItemModel item) async {
    final index = _items.indexWhere((i) => i.itemId == item.itemId);
    if (index != -1) {
      _items[index] = item;
    }
  }

  @override
  Future<void> toggleAvailability({
    required String itemId,
    required bool isAvailable,
  }) async {
    final index = _items.indexWhere((i) => i.itemId == itemId);
    if (index != -1) {
      _items[index] = _items[index].copyWith(isAvailable: isAvailable);
    }
  }

  @override
  Future<void> deleteMenuItem(String itemId) async {
    _items.removeWhere((i) => i.itemId == itemId);
  }
}

void main() {
  group('OwnerMenuFormNotifier Unit Tests', () {
    late ProviderContainer container;
    late MockOwnerMenuRepository mockRepo;

    setUp(() {
      mockRepo = MockOwnerMenuRepository();
      container = ProviderContainer(
        overrides: [
          ownerMenuRepositoryProvider.overrideWithValue(mockRepo),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('Initial menu form state is idle', () {
      final state = container.read(ownerMenuFormProvider);
      expect(state, isA<OwnerMenuFormIdleState>());
    });

    test('addMenuItem adds new item successfully', () async {
      final notifier = container.read(ownerMenuFormProvider.notifier);

      final success = await notifier.addMenuItem(
        stallId: 'stall_1',
        name: 'Cold Coffee',
        description: 'Chilled iced coffee',
        price: 80.0,
        category: 'Beverages',
      );

      expect(success, isTrue);
      expect(container.read(ownerMenuFormProvider),
          isA<OwnerMenuFormSuccessState>());
    });

    test('deleteMenuItem deletes item successfully', () async {
      final notifier = container.read(ownerMenuFormProvider.notifier);

      final success = await notifier.deleteMenuItem('item_1');

      expect(success, isTrue);
      expect(container.read(ownerMenuFormProvider),
          isA<OwnerMenuFormSuccessState>());
    });
  });
}
