import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:queuex/features/auth/domain/models/user_model.dart';
import 'package:queuex/features/auth/domain/models/user_role.dart';
import 'package:queuex/features/auth/presentation/providers/auth_provider.dart';
import 'package:queuex/features/owner/presentation/screens/owner_qr_scanner_screen.dart';

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

  testWidgets('OwnerQrScannerScreen renders scanner box and manual token input',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authControllerProvider.overrideWith(
            () => FakeOwnerAuthController(AuthenticatedState(fakeOwner)),
          ),
        ],
        child: const MaterialApp(
          home: OwnerQrScannerScreen(),
        ),
      ),
    );

    expect(find.text('Scan Pickup QR Token'), findsOneWidget);
    expect(find.text('Or Enter Token Manually'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
    expect(find.text('Verify & Redeem Token'), findsOneWidget);
  });
}
