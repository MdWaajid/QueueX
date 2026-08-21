import 'package:cloud_firestore/cloud_firestore.dart';
import 'user_role.dart';

class UserModel {
  final String userId;
  final String phoneNumber;
  final String? name;
  final UserRole role;
  final String? stallId;
  final String? profileImage;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? lastLoginAt;

  const UserModel({
    required this.userId,
    required this.phoneNumber,
    this.name,
    required this.role,
    this.stallId,
    this.profileImage,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
    this.lastLoginAt,
  });

  factory UserModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return UserModel(
      userId: doc.id,
      phoneNumber: data['phoneNumber'] as String? ?? '',
      name: data['name'] as String?,
      role: UserRoleX.fromString(data['role'] as String?) ?? UserRole.customer,
      stallId: data['stallId'] as String?,
      profileImage: data['profileImage'] as String?,
      isActive: data['isActive'] as bool? ?? true,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
      lastLoginAt: (data['lastLoginAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'phoneNumber': phoneNumber,
      'name': name,
      'role': role.nameString == 'Stall Owner' ? 'stallOwner' : 'customer',
      'stallId': stallId,
      'profileImage': profileImage,
      'isActive': isActive,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'lastLoginAt': lastLoginAt != null ? Timestamp.fromDate(lastLoginAt!) : FieldValue.serverTimestamp(),
    };
  }

  UserModel copyWith({
    String? userId,
    String? phoneNumber,
    String? name,
    UserRole? role,
    String? stallId,
    String? profileImage,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastLoginAt,
  }) {
    return UserModel(
      userId: userId ?? this.userId,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      name: name ?? this.name,
      role: role ?? this.role,
      stallId: stallId ?? this.stallId,
      profileImage: profileImage ?? this.profileImage,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
    );
  }
}
