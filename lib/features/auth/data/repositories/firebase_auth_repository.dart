import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/models/user_model.dart';
import '../../domain/models/user_role.dart';
import '../../domain/repositories/auth_repository.dart';

class FirebaseAuthRepository implements AuthRepository {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  FirebaseAuthRepository({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  @override
  User? get currentUser => _auth.currentUser;

  @override
  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required void Function(String verificationId, int? resendToken) onCodeSent,
    required void Function(String message) onError,
    required void Function(PhoneAuthCredential credential) onVerificationCompleted,
    required void Function(String verificationId) onAutoRetrievalTimeout,
  }) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      timeout: const Duration(seconds: 60),
      verificationCompleted: onVerificationCompleted,
      verificationFailed: (FirebaseAuthException e) {
        onError(e.message ?? 'Phone verification failed');
      },
      codeSent: onCodeSent,
      codeAutoRetrievalTimeout: onAutoRetrievalTimeout,
    );
  }

  @override
  Future<UserCredential> signInWithOtp({
    required String verificationId,
    required String smsCode,
  }) async {
    final credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode,
    );
    return await _auth.signInWithCredential(credential);
  }

  @override
  Future<UserModel?> getUserProfile(String uid) async {
    final docSnapshot = await _firestore.collection('users').doc(uid).get();
    if (!docSnapshot.exists || docSnapshot.data() == null) {
      return null;
    }
    final userModel = UserModel.fromFirestore(docSnapshot);
    
    // Update last login timestamp in background
    _firestore.collection('users').doc(uid).update({
      'lastLoginAt': FieldValue.serverTimestamp(),
    }).catchError((_) {});

    return userModel;
  }

  @override
  Future<UserModel> createUserProfile({
    required String uid,
    required String phoneNumber,
    required UserRole role,
    String? name,
  }) async {
    final docRef = _firestore.collection('users').doc(uid);
    final docSnapshot = await docRef.get();

    // If doc already exists, return existing profile to prevent role mutation
    if (docSnapshot.exists && docSnapshot.data() != null) {
      return UserModel.fromFirestore(docSnapshot);
    }

    final newUser = UserModel(
      userId: uid,
      phoneNumber: phoneNumber,
      name: name,
      role: role,
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      lastLoginAt: DateTime.now(),
    );

    await docRef.set(newUser.toFirestore());
    return newUser;
  }

  @override
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
