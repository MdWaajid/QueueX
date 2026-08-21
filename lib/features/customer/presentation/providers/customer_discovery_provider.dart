import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/customer_discovery_repository.dart';
import '../../domain/models/food_category_model.dart';
import '../../domain/models/stall_model.dart';

final customerDiscoveryRepositoryProvider =
    Provider<CustomerDiscoveryRepository>((ref) {
  return FirebaseCustomerDiscoveryRepository();
});

class SearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';

  void setQuery(String query) {
    state = query;
  }
}

final searchQueryProvider =
    NotifierProvider<SearchQueryNotifier, String>(SearchQueryNotifier.new);

class SelectedCategoryNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void selectCategory(String? categoryId) {
    state = categoryId;
  }
}

final selectedCategoryProvider =
    NotifierProvider<SelectedCategoryNotifier, String?>(
        SelectedCategoryNotifier.new);

final stallsProvider = FutureProvider<List<StallModel>>((ref) async {
  final repository = ref.watch(customerDiscoveryRepositoryProvider);
  return repository.getStalls();
});

final globalCategoriesProvider =
    FutureProvider<List<FoodCategoryModel>>((ref) async {
  final repository = ref.watch(customerDiscoveryRepositoryProvider);
  return repository.getCategories();
});

final filteredStallsProvider = Provider<AsyncValue<List<StallModel>>>((ref) {
  final stallsAsync = ref.watch(stallsProvider);
  final searchQuery = ref.watch(searchQueryProvider).trim().toLowerCase();

  return stallsAsync.whenData((stalls) {
    if (searchQuery.isEmpty) {
      return stalls;
    }
    return stalls.where((stall) {
      final matchesName = stall.stallName.toLowerCase().contains(searchQuery);
      final matchesDesc = stall.description.toLowerCase().contains(searchQuery);
      final matchesLocation =
          stall.locationName.toLowerCase().contains(searchQuery);
      return matchesName || matchesDesc || matchesLocation;
    }).toList();
  });
});

final stallDetailsProvider =
    FutureProvider.family<StallModel?, String>((ref, stallId) async {
  final repository = ref.watch(customerDiscoveryRepositoryProvider);
  return repository.getStallById(stallId);
});

final stallCategoriesProvider =
    FutureProvider.family<List<FoodCategoryModel>, String>((ref, stallId) async {
  final repository = ref.watch(customerDiscoveryRepositoryProvider);
  return repository.getCategories(stallId: stallId);
});
