import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/notification_repository.dart';
import '../../data/services/notification_service.dart';
import '../../domain/models/notification_model.dart';

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return MockNotificationService();
});

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return FirebaseNotificationRepository();
});

final userNotificationsStreamProvider =
    StreamProvider.family<List<NotificationModel>, String>((ref, userId) {
  final repository = ref.watch(notificationRepositoryProvider);
  return repository.streamUserNotifications(userId);
});

final unreadNotificationsCountProvider =
    Provider.family<int, String>((ref, userId) {
  final asyncNotifications = ref.watch(userNotificationsStreamProvider(userId));
  return asyncNotifications.when(
    data: (notifications) => notifications.where((n) => !n.isRead).length,
    loading: () => 0,
    error: (err, stack) => 0,
  );
});
