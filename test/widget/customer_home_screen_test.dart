import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:queuex/features/auth/domain/models/user_model.dart';
import 'package:queuex/features/auth/domain/models/user_role.dart';
import 'package:queuex/features/auth/presentation/providers/auth_provider.dart';
import 'package:queuex/features/customer/data/repositories/customer_discovery_repository.dart';
import 'package:queuex/features/customer/domain/models/food_category_model.dart';
import 'package:queuex/features/customer/domain/models/menu_item_model.dart';
import 'package:queuex/features/customer/domain/models/stall_model.dart';
import 'package:queuex/features/customer/presentation/providers/customer_discovery_provider.dart';
import 'package:queuex/features/customer/presentation/screens/customer_home_screen.dart';

class MockCustomerDiscoveryRepository implements CustomerDiscoveryRepository {
  final List<StallModel> stalls;
  final List<FoodCategoryModel> categories;
  final List<MenuItemModel> menuItems;

  MockCustomerDiscoveryRepository({
    this.stalls = const [],
    this.categories = const [],
    this.menuItems = const [],
  });

  @override
  Future<List<StallModel>> getStalls() async {
    return stalls;
  }

  @override
  Future<StallModel?> getStallById(String stallId) async {
    return stalls.firstWhere((s) => s.stallId == stallId);
  }

  @override
  Stream<StallModel?> getStallStream(String stallId) {
    try {
      final stall = stalls.firstWhere((s) => s.stallId == stallId);
      return Stream.value(stall);
    } catch (_) {
      return Stream.value(null);
    }
  }

  @override
  Future<List<FoodCategoryModel>> getCategories({String? stallId}) async {
    return categories;
  }

  @override
  Future<List<MenuItemModel>> getMenuItems(
      {required String stallId, String? categoryId}) async {
    return menuItems;
  }

  @override
  Future<MenuItemModel?> getMenuItemById(String itemId) async {
    return menuItems.firstWhere((item) => item.itemId == itemId);
  }
}

class FakeAuthController extends AuthController {
  final AuthState _initialState;

  FakeAuthController(this._initialState);

  @override
  AuthState build() {
    return _initialState;
  }
}

void main() {
  testWidgets('CustomerHomeScreen renders search bar and stall list correctly',
      (WidgetTester tester) async {
    final mockStalls = [
      const StallModel(
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
      ),
    ];

    final mockRepo = MockCustomerDiscoveryRepository(stalls: mockStalls);

    final fakeUser = UserModel(
      userId: 'user_1',
      phoneNumber: '+919999999999',
      name: 'Jane Doe',
      role: UserRole.customer,
      isActive: true,
      createdAt: DateTime.now(),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          customerDiscoveryRepositoryProvider.overrideWithValue(mockRepo),
          authControllerProvider.overrideWith(
            () => FakeAuthController(AuthenticatedState(fakeUser)),
          ),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: CustomerHomeScreen(),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Hello, Jane Doe 👋'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
    expect(find.text('Burger Hub'), findsOneWidget);
    expect(find.text('Available Stalls'), findsOneWidget);
  });
}
