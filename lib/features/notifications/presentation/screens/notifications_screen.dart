import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/widgets/app_error_widget.dart';
import '../../../../core/widgets/app_loading_indicator.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/models/notification_model.dart';
import '../providers/notification_provider.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final userId = authState is AuthenticatedState ? authState.user.userId : '';

    if (userId.isEmpty) {
      return const Scaffold(
        body: Center(
          child: Text('Please log in to view notifications.'),
        ),
      );
    }

    final notificationsAsync = ref.watch(userNotificationsStreamProvider(userId));
    final unreadCount = ref.watch(unreadNotificationsCountProvider(userId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          if (unreadCount > 0)
            TextButton.icon(
              onPressed: () {
                ref
                    .read(notificationRepositoryProvider)
                    .markAllAsRead(userId);
              },
              icon: const Icon(Icons.done_all_rounded, size: 18),
              label: const Text('Mark all read'),
            ),
        ],
      ),
      body: notificationsAsync.when(
        data: (notifications) {
          if (notifications.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_off_outlined,
                    size: 64,
                    color: AppColors.textSecondary.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'No notifications yet',
                    style: AppTypography.titleMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: notifications.length,
            separatorBuilder: (context, index) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final notification = notifications[index];
              return _buildNotificationCard(context, ref, notification);
            },
          );
        },
        loading: () => const Center(
          child: AppLoadingIndicator(message: 'Loading notifications...'),
        ),
        error: (error, _) => Center(
          child: AppErrorWidget(
            title: 'Failed to load notifications',
            message: error.toString(),
            onRetry: () {
              ref.invalidate(userNotificationsStreamProvider(userId));
            },
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationCard(
    BuildContext context,
    WidgetRef ref,
    NotificationModel notification,
  ) {
    IconData iconData = Icons.notifications_outlined;
    Color iconColor = AppColors.primary;

    switch (notification.type) {
      case NotificationType.orderStatus:
        iconData = Icons.shopping_bag_outlined;
        iconColor = AppColors.primary;
        break;
      case NotificationType.paymentUpdate:
        iconData = Icons.account_balance_wallet_outlined;
        iconColor = AppColors.success;
        break;
      case NotificationType.system:
        iconData = Icons.info_outline_rounded;
        iconColor = AppColors.warning;
        break;
    }

    return Card(
      elevation: notification.isRead ? 0.5 : 2,
      color: notification.isRead
          ? AppColors.surface
          : AppColors.primary.withValues(alpha: 0.04),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: notification.isRead
              ? AppColors.divider
              : AppColors.primary.withValues(alpha: 0.3),
        ),
      ),
      child: InkWell(
        onTap: () {
          if (!notification.isRead) {
            ref
                .read(notificationRepositoryProvider)
                .markAsRead(notification.notificationId);
          }

          if (notification.orderId != null && notification.orderId!.isNotEmpty) {
            context.push('/customer/order/${notification.orderId}');
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  iconData,
                  color: iconColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: AppTypography.titleMedium.copyWith(
                              fontWeight: notification.isRead
                                  ? FontWeight.w500
                                  : FontWeight.bold,
                            ),
                          ),
                        ),
                        if (!notification.isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification.body,
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _formatDate(notification.createdAt),
                      style: AppTypography.labelSmall.copyWith(
                        fontSize: 10,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${date.day}/${date.month}/${date.year}';
  }
}
