import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../models/user_role.dart';

abstract class AuthRepository {
  Stream<User?> get authStateChanges;

  User? get currentUser;

  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required void Function(String verificationId, int? resendToken) onCodeSent,
    required void Function(String message) onError,
    required void Function(PhoneAuthCredential credential) onVerificationCompleted,
    required void Function(String verificationId) onAutoRetrievalTimeout,
  });

  Future<UserCredential> signInWithOtp({
    required String verificationId,
    required String smsCode,
  });

  Future<UserModel?> getUserProfile(String uid);

  Future<UserModel> createUserProfile({
    required String uid,
    required String phoneNumber,
    required UserRole role,
    String? name,
  });

  Future<void> signOut();
}
