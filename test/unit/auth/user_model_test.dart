import 'package:flutter_test/flutter_test.dart';
import 'package:queuex/features/auth/domain/models/user_model.dart';
import 'package:queuex/features/auth/domain/models/user_role.dart';

void main() {
  group('UserModel Unit Tests', () {
    test('UserRole parsing from string works correctly', () {
      expect(UserRoleX.fromString('customer'), equals(UserRole.customer));
      expect(UserRoleX.fromString('CUSTOMER'), equals(UserRole.customer));
      expect(UserRoleX.fromString('stallOwner'), equals(UserRole.stallOwner));
      expect(UserRoleX.fromString('owner'), equals(UserRole.stallOwner));
      expect(UserRoleX.fromString('stall_owner'), equals(UserRole.stallOwner));
      expect(UserRoleX.fromString('superAdmin'), isNull);
      expect(UserRoleX.fromString('delivery'), isNull);
    });

    test('UserModel creation and copyWith properties', () {
      final user = UserModel(
        userId: 'user_123',
        phoneNumber: '+919876543210',
        name: 'Test Customer',
        role: UserRole.customer,
        isActive: true,
      );

      expect(user.userId, equals('user_123'));
      expect(user.phoneNumber, equals('+919876543210'));
      expect(user.role, equals(UserRole.customer));
      expect(user.isActive, isTrue);

      final updatedUser = user.copyWith(name: 'Updated Name', role: UserRole.stallOwner);
      expect(updatedUser.name, equals('Updated Name'));
      expect(updatedUser.role, equals(UserRole.stallOwner));
    });
  });
}
