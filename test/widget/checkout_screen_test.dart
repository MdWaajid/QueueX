import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:queuex/features/auth/domain/models/user_model.dart';
import 'package:queuex/features/auth/domain/models/user_role.dart';
import 'package:queuex/features/auth/presentation/providers/auth_provider.dart';
import 'package:queuex/features/customer/domain/models/menu_item_model.dart';
import 'package:queuex/features/customer/domain/models/stall_model.dart';
import 'package:queuex/features/customer/presentation/providers/cart_provider.dart';
import 'package:queuex/features/customer/presentation/providers/customer_discovery_provider.dart';
import 'package:queuex/features/orders/presentation/screens/checkout_screen.dart';
import 'package:queuex/features/slots/domain/models/slot_model.dart';
import 'package:queuex/features/slots/presentation/providers/slot_provider.dart';

class FakeAuthController extends AuthController {
  final AuthState _initialState;

  FakeAuthController(this._initialState);

  @override
  AuthState build() {
    return _initialState;
  }
}

void main() {
  const fakeMenuItem = MenuItemModel(
    itemId: 'item_1',
    stallId: 'stall_1',
    categoryId: 'cat_1',
    itemName: 'Veg Burger',
    description: 'Fresh patty',
    price: 120.0,
    imageUrl: '',
    preparationTimeMinutes: 10,
    isAvailable: true,
  );

  final fakeSlot = SlotModel(
    slotId: 'slot_1',
    stallId: 'stall_1',
    startTime: DateTime(2026, 8, 21, 10, 0),
    endTime: DateTime(2026, 8, 21, 10, 15),
    capacity: 10,
    bookedCount: 0,
    status: 'active',
    isPeak: false,
  );

  const fakeStall = StallModel(
    stallId: 'stall_1',
    ownerId: 'owner_1',
    stallName: 'Burger Hub',
    description: 'Best burgers in town',
    stallImage: '',
    phoneNumber: '1234567890',
    locationName: 'Court 1',
    status: 'active',
    openingTime: '09:00',
    closingTime: '21:00',
    timezone: 'Asia/Kolkata',
    isPeakModeEnabled: false,
  );

  final fakeUser = UserModel(
    userId: 'user_1',
    phoneNumber: '+919999999999',
    name: 'Jane Doe',
    role: UserRole.customer,
    isActive: true,
    createdAt: DateTime.now(),
  );

  testWidgets('CheckoutScreen renders order items and payment options',
      (WidgetTester tester) async {
    final container = ProviderContainer(
      overrides: [
        authControllerProvider.overrideWith(
          () => FakeAuthController(AuthenticatedState(fakeUser)),
        ),
        stallDetailsProvider('stall_1')
            .overrideWith((ref) => Stream.value(fakeStall)),
      ],
    );

    // Populate cart and selected slot
    container.read(cartProvider.notifier).addItem(fakeMenuItem, 'Burger Hub');
    container.read(selectedSlotProvider.notifier).selectSlot(fakeSlot);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          home: CheckoutScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Checkout & Payment'), findsOneWidget);
    expect(find.text('Burger Hub'), findsOneWidget);
    expect(find.text('Veg Burger'), findsOneWidget);
    expect(find.text('₹120'), findsWidgets);
    expect(find.text('Select Payment Method'), findsOneWidget);
    expect(find.text('Place Order'), findsOneWidget);
  });
}
