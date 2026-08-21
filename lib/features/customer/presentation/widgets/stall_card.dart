import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../domain/models/stall_model.dart';
import 'crowd_indicator_chip.dart';

class StallCard extends StatelessWidget {
  final StallModel stall;
  final VoidCallback onTap;

  const StallCard({
    super.key,
    required this.stall,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image / Banner Header
            Stack(
              children: [
                Container(
                  height: 140,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
                  ),
                  child: stall.stallImage.isNotEmpty
                      ? Image.network(
                          stall.stallImage,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              _buildPlaceholderImage(),
                        )
                      : _buildPlaceholderImage(),
                ),
                // Open / Closed Badge
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                ),
                // Crowd Indicator Chip (Only if Open)
                if (stall.isOpen)
                  Positioned(
                    top: 10,
                    right: 10,
                    child: CrowdIndicatorChip(crowdState: stall.crowdState),
                  ),
              ],
            ),
            // Details Section
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          stall.stallName,
                          style: AppTypography.titleMedium,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  if (stall.description.isNotEmpty) ...[
                    Text(
                      stall.description,
                      style: AppTypography.labelSmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                  ],
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 14,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          stall.locationName.isNotEmpty
                              ? stall.locationName
                              : 'Main Food Court',
                          style: AppTypography.labelSmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        '${stall.openingTime} - ${stall.closingTime}',
                        style: AppTypography.labelSmall,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
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
          size: 48,
          color: AppColors.primary,
        ),
      ),
    );
  }
}
