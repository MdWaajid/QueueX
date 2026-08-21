import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:queuex/features/auth/domain/models/user_model.dart';
import 'package:queuex/features/auth/domain/models/user_role.dart';
import 'package:queuex/features/auth/domain/repositories/auth_repository.dart';
import 'package:queuex/features/auth/presentation/providers/auth_provider.dart';
import 'package:queuex/features/auth/presentation/screens/phone_login_screen.dart';

class FakeAuthRepository implements AuthRepository {
  @override
  Stream<User?> get authStateChanges => const Stream.empty();

  @override
  User? get currentUser => null;

  @override
  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required void Function(String verificationId, int? resendToken) onCodeSent,
    required void Function(String message) onError,
    required void Function(PhoneAuthCredential credential) onVerificationCompleted,
    required void Function(String verificationId) onAutoRetrievalTimeout,
  }) async {}

  @override
  Future<UserCredential> signInWithOtp({
    required String verificationId,
    required String smsCode,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<UserCredential> signUpWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<UserModel?> getUserProfile(String uid) async => null;

  @override
  Future<UserModel> createUserProfile({
    required String uid,
    required String phoneNumber,
    required UserRole role,
    String? name,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<UserModel> resolveStallIdForOwner(UserModel user) async => user;

  @override
  Future<void> signOut() async {}
}

void main() {
  group('PhoneLoginScreen Widget Tests', () {
    testWidgets('renders phone login UI with mobile input field only', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authRepositoryProvider.overrideWithValue(FakeAuthRepository()),
          ],
          child: const MaterialApp(
            home: PhoneLoginScreen(),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Enter Mobile Number'), findsOneWidget);
      expect(find.text('+91'), findsOneWidget);
      expect(find.text('Get OTP'), findsOneWidget);

      // Verify NO role selector tiles or role choices exist on login screen
      expect(find.text('Stall Owner'), findsNothing);
      expect(find.text('Super Admin'), findsNothing);
    });

    testWidgets('validates empty phone input on submit', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authRepositoryProvider.overrideWithValue(FakeAuthRepository()),
          ],
          child: const MaterialApp(
            home: PhoneLoginScreen(),
          ),
        ),
      );
      await tester.pump();

      final buttonFinder = find.text('Get OTP');
      await tester.tap(buttonFinder);
      await tester.pump();

      expect(find.text('Please enter mobile number'), findsOneWidget);
    });
  });
}
