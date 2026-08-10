import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';

enum AppButtonVariant { primary, secondary, outline, text }

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isDisabled;
  final AppButtonVariant variant;
  final IconData? icon;

  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.isDisabled = false,
    this.variant = AppButtonVariant.primary,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final isInteractive = !isLoading && !isDisabled && onPressed != null;

    if (isLoading) {
      return SizedBox(
        height: 48.0,
        child: Center(
          child: SizedBox(
            height: 24.0,
            width: 24.0,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation<Color>(
                variant == AppButtonVariant.primary
                    ? AppColors.primary
                    : AppColors.textPrimary,
              ),
            ),
          ),
        ),
      );
    }

    switch (variant) {
      case AppButtonVariant.primary:
        return ElevatedButton(
          onPressed: isInteractive ? onPressed : null,
          child: _buildChild(context, AppColors.textOnPrimary),
        );
      case AppButtonVariant.secondary:
        return ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryLight,
            foregroundColor: AppColors.textOnPrimary,
          ),
          onPressed: isInteractive ? onPressed : null,
          child: _buildChild(context, AppColors.textOnPrimary),
        );
      case AppButtonVariant.outline:
        return OutlinedButton(
          onPressed: isInteractive ? onPressed : null,
          child: _buildChild(context, AppColors.primary),
        );
      case AppButtonVariant.text:
        return TextButton(
          onPressed: isInteractive ? onPressed : null,
          child: _buildChild(context, AppColors.primary),
        );
    }
  }

  Widget _buildChild(BuildContext context, Color defaultTextColor) {
    if (icon != null) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20.0),
          AppSpacing.gapSm,
          Text(label),
        ],
      );
    }
    return Text(label);
  }
}
