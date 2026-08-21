import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/presentation/screens/user_profile_screen.dart';
import '../../../notifications/presentation/providers/notification_provider.dart';
import '../../../notifications/presentation/screens/notifications_screen.dart';
import '../../../orders/presentation/screens/customer_orders_screen.dart';
import 'customer_home_screen.dart';

class CustomerShellScreen extends ConsumerStatefulWidget {
  const CustomerShellScreen({super.key});

  @override
  ConsumerState<CustomerShellScreen> createState() =>
      _CustomerShellScreenState();
}

class _CustomerShellScreenState extends ConsumerState<CustomerShellScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final userId = authState is AuthenticatedState ? authState.user.userId : '';
    final unreadCount = ref.watch(unreadNotificationsCountProvider(userId));

    return Scaffold(
      appBar: AppBar(
        title: Text(_getAppBarTitle(_currentIndex)),
        actions: [
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
        children: const [
          CustomerHomeScreen(),
          CustomerOrdersScreen(),
          NotificationsScreen(),
          UserProfileScreen(),
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
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long_outlined),
            activeIcon: Icon(Icons.receipt_long_rounded),
            label: 'Orders',
          ),
          BottomNavigationBarItem(
            icon: Badge(
              isLabelVisible: unreadCount > 0,
              label: Text('$unreadCount'),
              child: const Icon(Icons.notifications_outlined),
            ),
            activeIcon: Badge(
              isLabelVisible: unreadCount > 0,
              label: Text('$unreadCount'),
              child: const Icon(Icons.notifications_rounded),
            ),
            label: 'Notifications',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  String _getAppBarTitle(int index) {
    switch (index) {
      case 0:
        return 'QueueX Discovery';
      case 1:
        return 'My Orders';
      case 2:
        return 'Notifications';
      case 3:
        return 'My Profile';
      default:
        return 'QueueX';
    }
  }
}
