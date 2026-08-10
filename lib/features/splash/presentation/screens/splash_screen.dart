import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.queue_play_next_rounded,
              size: 72.0,
              color: AppColors.primary,
            ),
            AppSpacing.gapLg,
            Text(
              'QueueX',
              style: AppTypography.displayLarge,
            ),
            AppSpacing.gapSm,
            Text(
              'Skip the queue, collect your food',
              style: AppTypography.bodySecondary,
            ),
          ],
        ),
      ),
    );
  }
}
