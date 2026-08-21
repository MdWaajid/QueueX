import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/firebase_auth_repository.dart';
import '../../domain/models/user_model.dart';
import '../../domain/models/user_role.dart';
import '../../domain/repositories/auth_repository.dart';

// Repository Provider
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return FirebaseAuthRepository();
});

// Auth States
sealed class AuthState {
  const AuthState();
}

class AuthInitialState extends AuthState {
  const AuthInitialState();
}

class AuthLoadingState extends AuthState {
  const AuthLoadingState();
}

class CodeSentState extends AuthState {
  final String verificationId;
  final String phoneNumber;
  final int? resendToken;

  const CodeSentState({
    required this.verificationId,
    required this.phoneNumber,
    this.resendToken,
  });
}

class AuthenticatedState extends AuthState {
  final UserModel user;

  const AuthenticatedState(this.user);
}

class NeedsRoleSetupState extends AuthState {
  final String uid;
  final String phoneNumber;

  const NeedsRoleSetupState({
    required this.uid,
    required this.phoneNumber,
  });
}

class AccountInactiveState extends AuthState {
  final String message;

  const AccountInactiveState(this.message);
}

class UnauthenticatedState extends AuthState {
  const UnauthenticatedState();
}

class AuthErrorState extends AuthState {
  final String message;

  const AuthErrorState(this.message);
}

// Controller Notifier (Riverpod 3.x)
class AuthController extends Notifier<AuthState> {
  late final AuthRepository _authRepository;

  @override
  AuthState build() {
    _authRepository = ref.watch(authRepositoryProvider);
    _listenToAuthState();
    return const AuthInitialState();
  }

  void _listenToAuthState() {
    _authRepository.authStateChanges.listen((firebaseUser) async {
      if (firebaseUser == null) {
        state = const UnauthenticatedState();
      } else {
        await _resolveUserProfile(firebaseUser.uid, firebaseUser.phoneNumber ?? '');
      }
    });
  }

  Future<void> _resolveUserProfile(String uid, String phoneNumber) async {
    try {
      final userProfile = await _authRepository.getUserProfile(uid);
      if (userProfile == null) {
        state = NeedsRoleSetupState(uid: uid, phoneNumber: phoneNumber);
      } else if (!userProfile.isActive) {
        await _authRepository.signOut();
        state = const AccountInactiveState('Your account has been deactivated. Please contact support.');
      } else {
        if (userProfile.role == UserRole.stallOwner &&
            (userProfile.stallId == null || userProfile.stallId!.isEmpty)) {
          final resolvedUser =
              await _authRepository.resolveStallIdForOwner(userProfile);
          state = AuthenticatedState(resolvedUser);
        } else {
          state = AuthenticatedState(userProfile);
        }
      }
    } catch (e) {
      state = AuthErrorState('Failed to load user profile: ${e.toString()}');
    }
  }

  Future<void> sendOtp(String phoneNumber) async {
    state = const AuthLoadingState();
    final formattedPhone = phoneNumber.startsWith('+') ? phoneNumber : '+91$phoneNumber';

    try {
      await _authRepository.verifyPhoneNumber(
        phoneNumber: formattedPhone,
        onCodeSent: (verificationId, resendToken) {
          state = CodeSentState(
            verificationId: verificationId,
            phoneNumber: formattedPhone,
            resendToken: resendToken,
          );
        },
        onError: (message) {
          state = AuthErrorState(message);
        },
        onVerificationCompleted: (credential) async {
          // Auto retrieval sign in
          try {
            final userCred = await _authRepository.signInWithOtp(
              verificationId: credential.verificationId ?? '',
              smsCode: credential.smsCode ?? '',
            );
            if (userCred.user != null) {
              await _resolveUserProfile(userCred.user!.uid, userCred.user!.phoneNumber ?? formattedPhone);
            }
          } catch (_) {}
        },
        onAutoRetrievalTimeout: (verificationId) {},
      );
    } catch (e) {
      state = AuthErrorState(e.toString());
    }
  }

  Future<void> verifyOtp({
    required String verificationId,
    required String smsCode,
  }) async {
    state = const AuthLoadingState();
    try {
      final userCred = await _authRepository.signInWithOtp(
        verificationId: verificationId,
        smsCode: smsCode,
      );
      if (userCred.user != null) {
        await _resolveUserProfile(userCred.user!.uid, userCred.user!.phoneNumber ?? '');
      } else {
        state = const AuthErrorState('Sign in failed. Please try again.');
      }
    } catch (e) {
      state = const AuthErrorState('Invalid OTP code or expired session.');
    }
  }

  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    state = const AuthLoadingState();
    try {
      final userCred = await _authRepository.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (userCred.user != null) {
        await _resolveUserProfile(userCred.user!.uid, userCred.user!.email ?? email);
      } else {
        state = const AuthErrorState('Email sign-in failed. Please try again.');
      }
    } catch (e) {
      final msg = e.toString();
      if (msg.contains('operation-not-allowed')) {
        state = const AuthErrorState(
            'Email/Password provider is disabled in Firebase Console. Enable Email/Password under Firebase Console > Authentication > Sign-in method.');
      } else {
        state = AuthErrorState(msg.replaceAll(RegExp(r'\[.*?\]\s*'), ''));
      }
    }
  }

  Future<void> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    state = const AuthLoadingState();
    try {
      final userCred = await _authRepository.signUpWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (userCred.user != null) {
        await _resolveUserProfile(userCred.user!.uid, userCred.user!.email ?? email);
      } else {
        state = const AuthErrorState('Account creation failed. Please try again.');
      }
    } catch (e) {
      final msg = e.toString();
      if (msg.contains('operation-not-allowed')) {
        state = const AuthErrorState(
            'Email/Password provider is disabled in Firebase Console. Enable Email/Password under Firebase Console > Authentication > Sign-in method.');
      } else {
        state = AuthErrorState(msg.replaceAll(RegExp(r'\[.*?\]\s*'), ''));
      }
    }
  }

  Future<void> completeInitialRoleSetup(UserRole role) async {
    final currentState = state;
    if (currentState is! NeedsRoleSetupState) return;

    state = const AuthLoadingState();
    try {
      final newUser = await _authRepository.createUserProfile(
        uid: currentState.uid,
        phoneNumber: currentState.phoneNumber,
        role: role,
      );
      state = AuthenticatedState(newUser);
    } catch (e) {
      state = AuthErrorState('Failed to create profile: ${e.toString()}');
    }
  }

  Future<void> signOut() async {
    state = const AuthLoadingState();
    await _authRepository.signOut();
    state = const UnauthenticatedState();
  }

  void clearError() {
    state = const UnauthenticatedState();
  }
}

final authControllerProvider = NotifierProvider<AuthController, AuthState>(AuthController.new);
