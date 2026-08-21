import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/owner_reports_repository.dart';
import '../../domain/models/owner_reports_model.dart';

final ownerReportsRepositoryProvider = Provider<OwnerReportsRepository>((ref) {
  return FirebaseOwnerReportsRepository();
});

final ownerDailyAnalyticsStreamProvider =
    StreamProvider.family<StallAnalyticsSummary, String>((ref, stallId) {
  final repository = ref.watch(ownerReportsRepositoryProvider);
  return repository.streamDailyAnalytics(stallId);
});
