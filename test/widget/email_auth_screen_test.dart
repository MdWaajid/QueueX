import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:queuex/features/auth/presentation/providers/auth_provider.dart';
import 'package:queuex/features/auth/presentation/screens/email_auth_screen.dart';
import 'phone_login_screen_test.dart';

void main() {
  group('EmailAuthScreen Widget Tests', () {
    testWidgets('renders email sign in form with inputs and submit button',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authRepositoryProvider.overrideWithValue(FakeAuthRepository()),
          ],
          child: const MaterialApp(
            home: EmailAuthScreen(),
          ),
        ),
      );

      expect(find.text('Email Sign In'), findsOneWidget);
      expect(find.text('Email Address'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Sign In'), findsOneWidget);
    });

    testWidgets('toggles to sign up mode on link click',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authRepositoryProvider.overrideWithValue(FakeAuthRepository()),
          ],
          child: const MaterialApp(
            home: EmailAuthScreen(),
          ),
        ),
      );

      final toggleButton =
          find.text('Don\'t have an account? Register with Email');
      expect(toggleButton, findsOneWidget);

      await tester.tap(toggleButton);
      await tester.pumpAndSettle();

      expect(find.text('Create Email Account'), findsOneWidget);
      expect(find.text('Confirm Password'), findsOneWidget);
      expect(find.text('Register Account'), findsOneWidget);
    });
  });
}
