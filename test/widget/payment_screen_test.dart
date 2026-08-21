import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:queuex/features/auth/domain/models/user_model.dart';
import 'package:queuex/features/auth/domain/models/user_role.dart';
import 'package:queuex/features/auth/presentation/providers/auth_provider.dart';
import 'package:queuex/features/orders/domain/models/order_model.dart';
import 'package:queuex/features/orders/presentation/providers/order_provider.dart';
import 'package:queuex/features/payments/presentation/screens/payment_screen.dart';

class FakeAuthController extends AuthController {
  final AuthState _initialState;

  FakeAuthController(this._initialState);

  @override
  AuthState build() {
    return _initialState;
  }
}

void main() {
  final fakeOrder = OrderModel(
    orderId: 'order_1',
    customerId: 'user_1',
    stallId: 'stall_1',
    slotId: 'slot_1',
    totalAmount: 250.0,
    status: OrderStatus.pending,
    paymentStatus: PaymentStatus.pending,
    paymentMethod: PaymentMethod.online,
    qrToken: 'QX-TOKEN123',
    slotStartTime: DateTime(2026, 8, 21, 10, 0),
    slotEndTime: DateTime(2026, 8, 21, 10, 15),
  );

  final fakeUser = UserModel(
    userId: 'user_1',
    phoneNumber: '+919999999999',
    name: 'Jane Doe',
    role: UserRole.customer,
    isActive: true,
    createdAt: DateTime.now(),
  );

  testWidgets('PaymentScreen renders order details and payment button',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authControllerProvider.overrideWith(
            () => FakeAuthController(AuthenticatedState(fakeUser)),
          ),
          orderDetailsProvider('order_1')
              .overrideWith((ref) => Future.value(fakeOrder)),
        ],
        child: const MaterialApp(
          home: PaymentScreen(orderId: 'order_1'),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Complete Payment'), findsOneWidget);
    expect(find.text('₹250'), findsWidgets);
    expect(find.text('256-Bit Razorpay Encrypted Gateway'), findsOneWidget);
    expect(find.text('Pay ₹250 via Razorpay'), findsOneWidget);
  });
}
