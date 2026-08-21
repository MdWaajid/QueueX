import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:queuex/features/auth/domain/models/user_model.dart';
import 'package:queuex/features/auth/domain/models/user_role.dart';
import 'package:queuex/features/auth/presentation/providers/auth_provider.dart';
import 'package:queuex/features/customer/domain/models/stall_model.dart';
import 'package:queuex/features/customer/presentation/providers/customer_discovery_provider.dart';
import 'package:queuex/features/owner/presentation/screens/owner_slot_screen.dart';
import 'package:queuex/features/slots/domain/models/slot_model.dart';
import 'package:queuex/features/slots/presentation/providers/slot_provider.dart';

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

  final fakeSlots = [
    SlotModel(
      slotId: 'slot_1',
      stallId: 'stall_1',
      startTime: DateTime.now(),
      endTime: DateTime.now().add(const Duration(minutes: 15)),
      capacity: 10,
      bookedCount: 3,
      status: 'active',
      isPeak: false,
    ),
  ];

  testWidgets('OwnerSlotScreen renders Peak Mode toggle banner and slot schedule',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authControllerProvider.overrideWith(
            () => FakeOwnerAuthController(AuthenticatedState(fakeOwner)),
          ),
          stallDetailsProvider('stall_1')
              .overrideWith((ref) => Stream.value(fakeStall)),
          stallSlotsStreamProvider('stall_1')
              .overrideWith((ref) => Stream.value(fakeSlots)),
        ],
        child: const MaterialApp(
          home: OwnerSlotScreen(stallId: 'stall_1'),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Slot & Peak Management'), findsOneWidget);
    expect(find.text('Peak Mode'), findsOneWidget);
    expect(find.text('15-Minute Slot Configuration'), findsOneWidget);
    expect(find.text('Booked: 3/10'), findsOneWidget);
    expect(find.byType(Switch), findsOneWidget);
  });
}
