import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_error_widget.dart';
import '../../../../core/widgets/app_loading_indicator.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/customer_discovery_provider.dart';
import '../widgets/category_chip.dart';
import '../widgets/stall_card.dart';

class CustomerHomeScreen extends ConsumerStatefulWidget {
  const CustomerHomeScreen({super.key});

  @override
  ConsumerState<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends ConsumerState<CustomerHomeScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final filteredStallsAsync = ref.watch(filteredStallsProvider);
    final globalCategoriesAsync = ref.watch(globalCategoriesProvider);
    final selectedCategory = ref.watch(selectedCategoryProvider);

    String userName = 'Customer';
    if (authState is AuthenticatedState &&
        authState.user.name != null &&
        authState.user.name!.isNotEmpty) {
      userName = authState.user.name!;
    }

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(stallsProvider);
        ref.invalidate(globalCategoriesProvider);
      },
      child: CustomScrollView(
        slivers: [
          // Header & Greeting Section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hello, $userName 👋',
                            style: AppTypography.displayLarge,
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'Find your favorite food stall',
                            style: AppTypography.bodyMedium,
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Search Bar
                  AppTextField(
                    controller: _searchController,
                    hint: 'Search stalls, food, or location...',
                    prefixIcon: const Icon(Icons.search_rounded),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded),
                            onPressed: () {
                              _searchController.clear();
                              ref.read(searchQueryProvider.notifier).setQuery('');
                              setState(() {});
                            },
                          )
                        : null,
                    onChanged: (value) {
                      ref.read(searchQueryProvider.notifier).setQuery(value);
                      setState(() {});
                    },
                  ),
                  const SizedBox(height: 16),

                  // Categories Section Header
                  const Text(
                    'Categories',
                    style: AppTypography.titleMedium,
                  ),
                  const SizedBox(height: 8),

                  // Global Categories Bar
                  globalCategoriesAsync.when(
                    data: (categories) {
                      if (categories.isEmpty) {
                        return const SizedBox.shrink();
                      }
                      return SizedBox(
                        height: 40,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: categories.length + 1,
                          separatorBuilder: (_, _) => const SizedBox(width: 8),
                          itemBuilder: (context, index) {
                            if (index == 0) {
                              return CategoryChip(
                                label: 'All',
                                isSelected: selectedCategory == null,
                                onTap: () {
                                  ref
                                      .read(selectedCategoryProvider.notifier)
                                      .selectCategory(null);
                                },
                              );
                            }
                            final cat = categories[index - 1];
                            final isSelected = selectedCategory == cat.categoryId;
                            return CategoryChip(
                              label: cat.name,
                              isSelected: isSelected,
                              onTap: () {
                                ref
                                    .read(selectedCategoryProvider.notifier)
                                    .selectCategory(isSelected ? null : cat.categoryId);
                              },
                            );
                          },
                        ),
                      );
                    },
                    loading: () => const SizedBox(
                      height: 40,
                      child: Center(
                        child: SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                    ),
                    error: (_, _) => const SizedBox.shrink(),
                  ),
                  const SizedBox(height: 20),

                  // Stalls Section Title
                  const Text(
                    'Available Stalls',
                    style: AppTypography.titleLarge,
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),

          // Stalls List / State Handling
          filteredStallsAsync.when(
            data: (stalls) {
              if (stalls.isEmpty) {
                return const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: AppEmptyState(
                      title: 'No Stalls Found',
                      message:
                          'We couldn\'t find any stalls matching your search query or criteria.',
                      icon: Icons.storefront_outlined,
                    ),
                  ),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final stall = stalls[index];
                      return StallCard(
                        stall: stall,
                        onTap: () {
                          context.push('/customer/stall/${stall.stallId}');
                        },
                      );
                    },
                    childCount: stalls.length,
                  ),
                ),
              );
            },
            loading: () => const SliverFillRemaining(
              child: Center(
                child: AppLoadingIndicator(
                  message: 'Discovering stalls...',
                ),
              ),
            ),
            error: (error, stackTrace) => SliverFillRemaining(
              hasScrollBody: false,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: AppErrorWidget(
                  title: 'Failed to load stalls',
                  message: error.toString(),
                  onRetry: () {
                    ref.invalidate(stallsProvider);
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
