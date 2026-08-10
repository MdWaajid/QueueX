enum UserRole {
  customer,
  stallOwner,
}

extension UserRoleX on UserRole {
  String get nameString {
    switch (this) {
      case UserRole.customer:
        return 'Customer';
      case UserRole.stallOwner:
        return 'Stall Owner';
    }
  }

  static UserRole? fromString(String? role) {
    if (role == null) return null;
    switch (role.toLowerCase()) {
      case 'customer':
        return UserRole.customer;
      case 'owner':
      case 'stall_owner':
      case 'stallowner':
        return UserRole.stallOwner;
      default:
        return null;
    }
  }
}
