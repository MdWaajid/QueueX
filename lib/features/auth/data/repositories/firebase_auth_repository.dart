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
  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    return await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  @override
  Future<UserCredential> signUpWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    return await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
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

    if (userModel.role == UserRole.stallOwner && (userModel.stallId == null || userModel.stallId!.isEmpty)) {
      return await resolveStallIdForOwner(userModel);
    }

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

    if (docSnapshot.exists && docSnapshot.data() != null) {
      final existingUser = UserModel.fromFirestore(docSnapshot);
      if (role == UserRole.stallOwner && (existingUser.stallId == null || existingUser.stallId!.isEmpty)) {
        return await resolveStallIdForOwner(existingUser);
      }
      return existingUser;
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

    if (role == UserRole.stallOwner) {
      return await resolveStallIdForOwner(newUser);
    }

    return newUser;
  }

  @override
  Future<UserModel> resolveStallIdForOwner(UserModel user) async {
    if (user.role != UserRole.stallOwner) return user;

    if (user.stallId != null && user.stallId!.isNotEmpty) {
      return user;
    }

    try {
      // Check if a stall already exists for this owner
      final stallQuery = await _firestore
          .collection('stalls')
          .where('ownerId', isEqualTo: user.userId)
          .limit(1)
          .get();

      String targetStallId = '';

      if (stallQuery.docs.isNotEmpty) {
        targetStallId = stallQuery.docs.first.id;
      } else {
        // Fallback: check if stall_1 exists or create new stall
        final stall1Doc = await _firestore.collection('stalls').doc('stall_1').get();
        if (stall1Doc.exists && (stall1Doc.data()?['ownerId'] == '' || stall1Doc.data()?['ownerId'] == null)) {
          targetStallId = 'stall_1';
          await _firestore.collection('stalls').doc('stall_1').update({
            'ownerId': user.userId,
            'updatedAt': FieldValue.serverTimestamp(),
          });
        } else {
          // Create new stall document
          final newStallRef = _firestore.collection('stalls').doc();
          targetStallId = newStallRef.id;

          await newStallRef.set({
            'stallId': targetStallId,
            'ownerId': user.userId,
            'stallName': user.name != null && user.name!.isNotEmpty ? '${user.name}\'s Stall' : 'My Food Stall',
            'description': 'Delicious campus food court items',
            'stallImage': '',
            'phoneNumber': user.phoneNumber,
            'locationName': 'Campus Food Court',
            'status': 'active',
            'openingTime': '09:00',
            'closingTime': '21:00',
            'timezone': 'Asia/Kolkata',
            'isPeakModeEnabled': false,
            'createdAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }
      }

      // Update user profile document with stallId
      await _firestore.collection('users').doc(user.userId).update({
        'stallId': targetStallId,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return user.copyWith(stallId: targetStallId);
    } catch (_) {
      // Default fallback stall_1
      return user.copyWith(stallId: 'stall_1');
    }
  }

  @override
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
