import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:queuex/features/auth/domain/models/user_model.dart';
import 'package:queuex/features/auth/domain/models/user_role.dart';
import 'package:queuex/features/auth/presentation/providers/auth_provider.dart';
import 'package:queuex/features/customer/domain/models/menu_item_model.dart';
import 'package:queuex/features/owner/presentation/providers/owner_menu_provider.dart';
import 'package:queuex/features/owner/presentation/screens/owner_menu_screen.dart';

class FakeOwnerAuthController extends AuthController {
  final AuthState _initialState;

  FakeOwnerAuthController(this._initialState);

  @override
  AuthState build() {
    return _initialState;
  }
}

void main() {
  final fakeOwner = UserModel(
    userId: 'owner_1',
    phoneNumber: '+919876543210',
    name: 'Stall Owner Jane',
    role: UserRole.stallOwner,
    stallId: 'stall_1',
    isActive: true,
    createdAt: DateTime.now(),
  );

  final fakeMenuItems = [
    const MenuItemModel(
      itemId: 'item_1',
      stallId: 'stall_1',
      categoryId: 'Main Course',
      itemName: 'Paneer Butter Masala',
      description: 'Rich cottage cheese curry',
      price: 180.0,
      imageUrl: '',
      preparationTimeMinutes: 15,
      isAvailable: true,
    ),
  ];

  testWidgets('OwnerMenuScreen renders menu items and Add Item FAB button',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authControllerProvider.overrideWith(
            () => FakeOwnerAuthController(AuthenticatedState(fakeOwner)),
          ),
          ownerMenuItemsStreamProvider('stall_1')
              .overrideWith((ref) => Stream.value(fakeMenuItems)),
        ],
        child: const MaterialApp(
          home: OwnerMenuScreen(stallId: 'stall_1'),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Manage Menu'), findsOneWidget);
    expect(find.text('Paneer Butter Masala'), findsOneWidget);
    expect(find.text('₹180'), findsOneWidget);
    expect(find.text('Add Item'), findsOneWidget);
    expect(find.byType(Switch), findsOneWidget);
  });
}
