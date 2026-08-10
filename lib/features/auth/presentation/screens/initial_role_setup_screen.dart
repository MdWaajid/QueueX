import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/widgets/app_button.dart';
import '../../domain/models/user_role.dart';
import '../providers/auth_provider.dart';

class InitialRoleSetupScreen extends ConsumerStatefulWidget {
  const InitialRoleSetupScreen({super.key});

  @override
  ConsumerState<InitialRoleSetupScreen> createState() => _InitialRoleSetupScreenState();
}

class _InitialRoleSetupScreenState extends ConsumerState<InitialRoleSetupScreen> {
  UserRole _selectedRole = UserRole.customer;

  void _submitInitialRole() {
    ref.read(authControllerProvider.notifier).completeInitialRoleSetup(_selectedRole);
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final isLoading = authState is AuthLoadingState;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Account Setup'),
      ),
      body: SafeArea(
        child: Padding(
          padding: AppSpacing.paddingLg,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppSpacing.gapLg,
              const Text(
                'Welcome to QueueX',
                style: AppTypography.displayLarge,
              ),
              AppSpacing.gapSm,
              const Text(
                'Select your account type to set up your profile. This choice is permanent for your account.',
                style: AppTypography.bodySecondary,
              ),
              AppSpacing.gapXl,
              _RoleTile(
                title: 'Customer',
                description: 'Browse food stalls, pre-order meals, and pick up using QR codes.',
                icon: Icons.person_rounded,
                isSelected: _selectedRole == UserRole.customer,
                onTap: () => setState(() => _selectedRole = UserRole.customer),
              ),
              AppSpacing.gapMd,
              _RoleTile(
                title: 'Stall Owner',
                description: 'Manage your stall menu, operational slot capacity, and order verification.',
                icon: Icons.storefront_rounded,
                isSelected: _selectedRole == UserRole.stallOwner,
                onTap: () => setState(() => _selectedRole = UserRole.stallOwner),
              ),
              const Spacer(),
              AppButton(
                label: 'Complete Setup',
                isLoading: isLoading,
                onPressed: _submitInitialRole,
              ),
              AppSpacing.gapLg,
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleTile extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _RoleTile({
    required this.title,
    required this.description,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: AppSpacing.paddingLg,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.divider,
            width: isSelected ? 2.0 : 1.0,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 32.0,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
            ),
            AppSpacing.gapMd,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.titleMedium.copyWith(
                      color: isSelected ? AppColors.primary : AppColors.textPrimary,
                    ),
                  ),
                  AppSpacing.gapXs,
                  Text(
                    description,
                    style: AppTypography.bodySecondary,
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle_rounded,
                color: AppColors.primary,
              ),
          ],
        ),
      ),
    );
  }
}
