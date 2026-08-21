import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:queuex/features/customer/domain/models/menu_item_model.dart';
import 'package:queuex/features/customer/presentation/widgets/menu_item_card.dart';

void main() {
  const availableItem = MenuItemModel(
    itemId: 'item_1',
    stallId: 'stall_1',
    categoryId: 'cat_1',
    itemName: 'Spring Rolls',
    description: 'Crispy veg rolls',
    price: 120.0,
    imageUrl: '',
    preparationTimeMinutes: 12,
    isAvailable: true,
  );

  const unavailableItem = MenuItemModel(
    itemId: 'item_2',
    stallId: 'stall_1',
    categoryId: 'cat_1',
    itemName: 'Momos',
    description: 'Steamed momos',
    price: 100.0,
    imageUrl: '',
    preparationTimeMinutes: 15,
    isAvailable: false,
  );

  testWidgets('MenuItemCard renders item details and ADD button when available',
      (WidgetTester tester) async {
    bool addPressed = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MenuItemCard(
            menuItem: availableItem,
            cartQuantity: 0,
            onAdd: () => addPressed = true,
            onQuantityChanged: (_) {},
          ),
        ),
      ),
    );

    expect(find.text('Spring Rolls'), findsOneWidget);
    expect(find.text('₹120'), findsOneWidget);
    expect(find.text('12 mins'), findsOneWidget);
    expect(find.text('ADD'), findsOneWidget);

    await tester.tap(find.text('ADD'));
    expect(addPressed, isTrue);
  });

  testWidgets('MenuItemCard renders OUT OF STOCK badge when unavailable',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MenuItemCard(
            menuItem: unavailableItem,
            cartQuantity: 0,
            onAdd: () {},
            onQuantityChanged: (_) {},
          ),
        ),
      ),
    );

    expect(find.text('Momos'), findsOneWidget);
    expect(find.text('OUT OF\nSTOCK'), findsOneWidget);
    expect(find.text('Unavailable'), findsOneWidget);
    expect(find.text('ADD'), findsNothing);
  });

  testWidgets('MenuItemCard renders quantity controller when cartQuantity > 0',
      (WidgetTester tester) async {
    int updatedDelta = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MenuItemCard(
            menuItem: availableItem,
            cartQuantity: 2,
            onAdd: () {},
            onQuantityChanged: (delta) => updatedDelta = delta,
          ),
        ),
      ),
    );

    expect(find.text('2'), findsOneWidget);
    expect(find.byIcon(Icons.add), findsOneWidget);
    expect(find.byIcon(Icons.remove), findsOneWidget);

    await tester.tap(find.byIcon(Icons.add));
    expect(updatedDelta, 1);
  });
}
