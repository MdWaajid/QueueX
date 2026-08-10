import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/domain/models/user_role.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/auth/presentation/screens/initial_role_setup_screen.dart';
import '../../features/auth/presentation/screens/otp_verification_screen.dart';
import '../../features/auth/presentation/screens/phone_login_screen.dart';
import '../../features/customer/presentation/screens/customer_shell_screen.dart';
import '../../features/owner/presentation/screens/owner_shell_screen.dart';
import '../../features/splash/presentation/screens/splash_screen.dart';

abstract class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String verifyOtp = '/verify-otp';
  static const String roleSetup = '/role-setup';
  static const String customerHome = '/customer';
  static const String ownerDashboard = '/owner';
}

final routerProvider = Provider<GoRouter>((ref) {
  final authNotifier = _AuthListenable(ref);

  return GoRouter(
    initialLocation: AppRoutes.splash,
    refreshListenable: authNotifier,
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const PhoneLoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.verifyOtp,
        builder: (context, state) {
          final authState = ref.read(authControllerProvider);
          if (authState is CodeSentState) {
            return OtpVerificationScreen(
              verificationId: authState.verificationId,
              phoneNumber: authState.phoneNumber,
            );
          }
          return const PhoneLoginScreen();
        },
      ),
      GoRoute(
        path: AppRoutes.roleSetup,
        builder: (context, state) => const InitialRoleSetupScreen(),
      ),
      GoRoute(
        path: AppRoutes.customerHome,
        builder: (context, state) => const CustomerShellScreen(),
      ),
      GoRoute(
        path: AppRoutes.ownerDashboard,
        builder: (context, state) => const OwnerShellScreen(),
      ),
    ],
    redirect: (BuildContext context, GoRouterState state) {
      final authState = ref.read(authControllerProvider);
      final location = state.matchedLocation;

      if (authState is UnauthenticatedState || authState is AccountInactiveState) {
        if (location != AppRoutes.login && location != AppRoutes.verifyOtp) {
          return AppRoutes.login;
        }
      } else if (authState is CodeSentState) {
        if (location != AppRoutes.verifyOtp) {
          return AppRoutes.verifyOtp;
        }
      } else if (authState is NeedsRoleSetupState) {
        if (location != AppRoutes.roleSetup) {
          return AppRoutes.roleSetup;
        }
      } else if (authState is AuthenticatedState) {
        final role = authState.user.role;
        if (role == UserRole.customer && location != AppRoutes.customerHome) {
          return AppRoutes.customerHome;
        } else if (role == UserRole.stallOwner && location != AppRoutes.ownerDashboard) {
          return AppRoutes.ownerDashboard;
        }
      }
      return null;
    },
  );
});

class _AuthListenable extends ChangeNotifier {
  _AuthListenable(Ref ref) {
    ref.listen<AuthState>(authControllerProvider, (_, next) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    });
  }
}
