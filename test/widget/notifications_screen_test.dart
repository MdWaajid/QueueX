import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:queuex/features/auth/domain/models/user_model.dart';
import 'package:queuex/features/auth/domain/models/user_role.dart';
import 'package:queuex/features/auth/presentation/providers/auth_provider.dart';
import 'package:queuex/features/notifications/domain/models/notification_model.dart';
import 'package:queuex/features/notifications/presentation/providers/notification_provider.dart';
import 'package:queuex/features/notifications/presentation/screens/notifications_screen.dart';

class FakeAuthController extends AuthController {
  final AuthState _initialState;

  FakeAuthController(this._initialState);

  @override
  AuthState build() {
    return _initialState;
  }
}

void main() {
  final fakeUser = UserModel(
    userId: 'user_1',
    phoneNumber: '+919999999999',
    name: 'Jane Doe',
    role: UserRole.customer,
    isActive: true,
    createdAt: DateTime.now(),
  );

  final fakeNotifications = [
    NotificationModel(
      notificationId: 'notif_1',
      userId: 'user_1',
      title: 'Order Ready for Pickup',
      body: 'Your order #QX-123 is ready at the stall.',
      type: NotificationType.orderStatus,
      orderId: 'order_1',
      isRead: false,
      createdAt: DateTime.now(),
    ),
  ];

  testWidgets('NotificationsScreen renders notifications list and header actions',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authControllerProvider.overrideWith(
            () => FakeAuthController(AuthenticatedState(fakeUser)),
          ),
          userNotificationsStreamProvider('user_1')
              .overrideWith((ref) => Stream.value(fakeNotifications)),
        ],
        child: const MaterialApp(
          home: NotificationsScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Notifications'), findsOneWidget);
    expect(find.text('Order Ready for Pickup'), findsOneWidget);
    expect(find.text('Your order #QX-123 is ready at the stall.'), findsOneWidget);
    expect(find.text('Mark all read'), findsOneWidget);
  });
}
