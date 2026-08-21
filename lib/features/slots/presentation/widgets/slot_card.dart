import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../domain/models/slot_model.dart';

class SlotCard extends StatelessWidget {
  final SlotModel slot;
  final bool isSelected;
  final VoidCallback? onTap;

  const SlotCard({
    super.key,
    required this.slot,
    required this.isSelected,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isFull = slot.availabilityState == SlotAvailabilityState.full;
    final state = slot.availabilityState;

    Color badgeColor;
    switch (state) {
      case SlotAvailabilityState.available:
        badgeColor = AppColors.success;
        break;
      case SlotAvailabilityState.moderate:
        badgeColor = AppColors.warning;
        break;
      case SlotAvailabilityState.peak:
        badgeColor = Colors.orange;
        break;
      case SlotAvailabilityState.full:
        badgeColor = AppColors.error;
        break;
    }

    final formattedStart = _formatTime(slot.startTime);
    final formattedEnd = _formatTime(slot.endTime);

    return InkWell(
      onTap: isFull ? null : onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isFull
              ? AppColors.textDisabled.withValues(alpha: 0.1)
              : isSelected
                  ? AppColors.primary.withValues(alpha: 0.08)
                  : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : isFull
                    ? AppColors.divider.withValues(alpha: 0.5)
                    : AppColors.divider,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.access_time_filled_rounded,
                      size: 16,
                      color: isFull ? AppColors.textDisabled : AppColors.primary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '$formattedStart - $formattedEnd',
                      style: AppTypography.titleMedium.copyWith(
                        color: isFull
                            ? AppColors.textDisabled
                            : AppColors.textPrimary,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.w600,
                      ),
                    ),
                  ],
                ),

                // Availability Badge Chip (ADR-010: Queue counts hidden)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: badgeColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    state.label,
                    style: AppTypography.labelSmall.copyWith(
                      color: badgeColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final hour = time.hour > 12
        ? time.hour - 12
        : (time.hour == 0 ? 12 : time.hour);
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }
}
