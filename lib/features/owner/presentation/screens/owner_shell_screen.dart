import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/presentation/screens/user_profile_screen.dart';
import 'owner_dashboard_screen.dart';
import 'owner_menu_screen.dart';
import 'owner_orders_screen.dart';
import 'owner_slot_screen.dart';

class OwnerShellScreen extends ConsumerStatefulWidget {
  const OwnerShellScreen({super.key});

  @override
  ConsumerState<OwnerShellScreen> createState() => _OwnerShellScreenState();
}

class _OwnerShellScreenState extends ConsumerState<OwnerShellScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final stallId = authState is AuthenticatedState ? (authState.user.stallId ?? '') : '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('QueueX Stall Owner'),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner_rounded),
            tooltip: 'Scan Pickup QR Token',
            onPressed: () {
              context.push('/owner/scan-qr');
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Logout',
            onPressed: () {
              ref.read(authControllerProvider.notifier).signOut();
            },
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          OwnerDashboardScreen(stallId: stallId),
          OwnerOrdersScreen(stallId: stallId),
          OwnerMenuScreen(stallId: stallId),
          OwnerSlotScreen(stallId: stallId),
          const UserProfileScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard_rounded),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt_outlined),
            activeIcon: Icon(Icons.list_alt_rounded),
            label: 'Orders',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant_menu_outlined),
            activeIcon: Icon(Icons.restaurant_menu_rounded),
            label: 'Menu',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.access_time_outlined),
            activeIcon: Icon(Icons.access_time_rounded),
            label: 'Slots',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
