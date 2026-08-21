import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:queuex/features/auth/domain/models/user_model.dart';
import 'package:queuex/features/auth/domain/models/user_role.dart';
import 'package:queuex/features/auth/presentation/providers/auth_provider.dart';
import 'package:queuex/features/customer/domain/models/stall_model.dart';
import 'package:queuex/features/customer/presentation/providers/customer_discovery_provider.dart';
import 'package:queuex/features/owner/domain/models/owner_reports_model.dart';
import 'package:queuex/features/owner/presentation/providers/owner_reports_provider.dart';
import 'package:queuex/features/owner/presentation/screens/owner_dashboard_screen.dart';

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

  const fakeStall = StallModel(
    stallId: 'stall_1',
    ownerId: 'owner_1',
    stallName: 'Royal Spice',
    description: 'Indian delicacy',
    stallImage: '',
    phoneNumber: '+919876543210',
    locationName: 'Campus Food Court',
    status: 'active',
    openingTime: '09:00',
    closingTime: '21:00',
    timezone: 'Asia/Kolkata',
    isPeakModeEnabled: false,
  );

  const fakeAnalytics = StallAnalyticsSummary(
    totalRevenueToday: 600.0,
    totalOrdersToday: 4,
    completedOrdersCount: 3,
    pendingOrdersCount: 1,
    onlinePaymentRevenue: 400.0,
    cashPaymentRevenue: 200.0,
  );

  testWidgets('OwnerDashboardScreen renders metric cards and payment split',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authControllerProvider.overrideWith(
            () => FakeOwnerAuthController(AuthenticatedState(fakeOwner)),
          ),
          stallDetailsProvider('stall_1')
              .overrideWith((ref) => Stream.value(fakeStall)),
          ownerDailyAnalyticsStreamProvider('stall_1')
              .overrideWith((ref) => Stream.value(fakeAnalytics)),
        ],
        child: const MaterialApp(
          home: OwnerDashboardScreen(stallId: 'stall_1'),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Stall Dashboard'), findsOneWidget);
    expect(find.text('Royal Spice'), findsOneWidget);
    expect(find.text("Today's Revenue"), findsOneWidget);
    expect(find.text('₹600'), findsOneWidget);
    expect(find.text('Total Orders'), findsOneWidget);
    expect(find.text('Payment Method Breakdown'), findsOneWidget);
    expect(find.text('Scan QR Code'), findsOneWidget);
  });
}
