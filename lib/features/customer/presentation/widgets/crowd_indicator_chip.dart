import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../domain/models/stall_model.dart';

class CrowdIndicatorChip extends StatelessWidget {
  final CrowdState crowdState;

  const CrowdIndicatorChip({
    super.key,
    required this.crowdState,
  });

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color textColor;
    IconData iconData;

    switch (crowdState) {
      case CrowdState.available:
        backgroundColor = AppColors.success.withValues(alpha: 0.12);
        textColor = AppColors.success;
        iconData = Icons.circle;
        break;
      case CrowdState.moderate:
        backgroundColor = AppColors.warning.withValues(alpha: 0.15);
        textColor = const Color(0xFFB78103);
        iconData = Icons.warning_amber_rounded;
        break;
      case CrowdState.peak:
        backgroundColor = AppColors.error.withValues(alpha: 0.12);
        textColor = AppColors.error;
        iconData = Icons.local_fire_department_rounded;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            iconData,
            size: 10,
            color: textColor,
          ),
          const SizedBox(width: 4),
          Text(
            crowdState.label,
            style: AppTypography.labelSmall.copyWith(
              color: textColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
