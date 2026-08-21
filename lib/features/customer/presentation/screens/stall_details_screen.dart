import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/widgets/app_error_widget.dart';
import '../../../../core/widgets/app_loading_indicator.dart';
import '../providers/customer_discovery_provider.dart';
import '../widgets/crowd_indicator_chip.dart';

class StallDetailsScreen extends ConsumerWidget {
  final String stallId;

  const StallDetailsScreen({
    super.key,
    required this.stallId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stallAsync = ref.watch(stallDetailsProvider(stallId));
    final categoriesAsync = ref.watch(stallCategoriesProvider(stallId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Stall Details'),
      ),
      body: stallAsync.when(
        data: (stall) {
          if (stall == null) {
            return const Center(
              child: Text(
                'Stall not found',
                style: AppTypography.titleMedium,
              ),
            );
          }

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Stall Banner Image
                Container(
                  height: 200,
                  width: double.infinity,
                  color: AppColors.background,
                  child: stall.stallImage.isNotEmpty
                      ? Image.network(
                          stall.stallImage,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              _buildPlaceholderImage(),
                        )
                      : _buildPlaceholderImage(),
                ),

                // Closed Stall Warning Banner
                if (stall.isClosed)
                  Container(
                    width: double.infinity,
                    color: AppColors.error.withValues(alpha: 0.12),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.info_outline_rounded,
                          color: AppColors.error,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'This stall is currently closed and not accepting new orders.',
                            style: AppTypography.labelSmall.copyWith(
                              color: AppColors.error,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Stall Header Info
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  stall.stallName,
                                  style: AppTypography.titleLarge,
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.location_on_outlined,
                                      size: 16,
                                      color: AppColors.textSecondary,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      stall.locationName.isNotEmpty
                                          ? stall.locationName
                                          : 'Main Food Court',
                                      style: AppTypography.bodyMedium,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: stall.isOpen
                                      ? AppColors.success
                                      : AppColors.textDisabled,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  stall.isOpen ? 'OPEN' : 'CLOSED',
                                  style: AppTypography.labelSmall.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              if (stall.isOpen) ...[
                                const SizedBox(height: 6),
                                CrowdIndicatorChip(
                                  crowdState: stall.crowdState,
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      if (stall.description.isNotEmpty) ...[
                        Text(
                          stall.description,
                          style: AppTypography.bodyMedium,
                        ),
                        const SizedBox(height: 12),
                      ],

                      // Opening Hours & Contact Info Card
                      Card(
                        color: AppColors.background,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: const BorderSide(color: AppColors.divider),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.access_time_rounded,
                                    size: 18,
                                    color: AppColors.primary,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Hours: ${stall.openingTime} - ${stall.closingTime}',
                                    style: AppTypography.labelSmall,
                                  ),
                                ],
                              ),
                              if (stall.phoneNumber.isNotEmpty) ...[
                                const Divider(height: 16),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.phone_outlined,
                                      size: 18,
                                      color: AppColors.primary,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      stall.phoneNumber,
                                      style: AppTypography.labelSmall,
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Peak Highlights (if active)
                      if (stall.isPeakModeEnabled)
                        Container(
                          width: double.infinity,
                          margin: const EdgeInsets.only(bottom: 20),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.error.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                color: AppColors.error.withValues(alpha: 0.3)),
                          ),
                          child: const Row(
                            children: [
                              Icon(
                                Icons.local_fire_department_rounded,
                                color: AppColors.error,
                              ),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'High Demand Peak Mode Active! Online payment required for slot pickup.',
                                  style: AppTypography.labelSmall,
                                ),
                              ),
                            ],
                          ),
                        ),

                      // Food Categories Section
                      const Text(
                        'Categories & Menu Preview',
                        style: AppTypography.titleLarge,
                      ),
                      const SizedBox(height: 12),

                      categoriesAsync.when(
                        data: (categories) {
                          if (categories.isEmpty) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              child: Text(
                                'No menu categories listed for this stall.',
                                style: AppTypography.bodyMedium,
                              ),
                            );
                          }

                          return ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: categories.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(height: 8),
                            itemBuilder: (context, index) {
                              final cat = categories[index];
                              return ListTile(
                                leading: CircleAvatar(
                                  backgroundColor:
                                      AppColors.primary.withValues(alpha: 0.1),
                                  child: const Icon(
                                    Icons.restaurant_menu_rounded,
                                    color: AppColors.primary,
                                  ),
                                ),
                                title: Text(
                                  cat.name,
                                  style: AppTypography.titleMedium,
                                ),
                                subtitle: Text(
                                  cat.isActive ? 'Available' : 'Inactive',
                                  style: AppTypography.labelSmall,
                                ),
                              );
                            },
                          );
                        },
                        loading: () => const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: CircularProgressIndicator(),
                          ),
                        ),
                        error: (error, _) => Text(
                          'Failed to load categories: $error',
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.error,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(
          child: AppLoadingIndicator(
            message: 'Loading stall details...',
          ),
        ),
        error: (error, stackTrace) => Center(
          child: AppErrorWidget(
            title: 'Failed to load stall details',
            message: error.toString(),
            onRetry: () {
              ref.invalidate(stallDetailsProvider(stallId));
            },
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      color: AppColors.primary.withValues(alpha: 0.08),
      child: const Center(
        child: Icon(
          Icons.storefront_rounded,
          size: 64,
          color: AppColors.primary,
        ),
      ),
    );
  }
}
