import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/widgets/app_button.dart';
import '../../domain/models/user_role.dart';
import '../providers/auth_provider.dart';

class UserProfileScreen extends ConsumerWidget {
  const UserProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);

    if (authState is! AuthenticatedState) {
      return const Scaffold(
        body: Center(
          child: Text('Not authenticated.'),
        ),
      );
    }

    final user = authState.user;
    final isOwner = user.role == UserRole.stallOwner;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // User Avatar Header
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                    child: Icon(
                      isOwner ? Icons.storefront_rounded : Icons.person_rounded,
                      size: 44,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    user.name != null && user.name!.isNotEmpty
                        ? user.name!
                        : (isOwner ? 'Stall Owner' : 'QueueX Customer'),
                    style: AppTypography.displayLarge,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user.phoneNumber,
                    style: AppTypography.bodySecondary,
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      isOwner ? 'STALL OWNER' : 'CUSTOMER',
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // Profile Details Card
            Card(
              elevation: 1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: const BorderSide(color: AppColors.divider),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildProfileRow(
                      icon: Icons.phone_android_rounded,
                      label: 'Phone Number',
                      value: user.phoneNumber,
                    ),
                    const Divider(height: 24),
                    _buildProfileRow(
                      icon: Icons.verified_user_outlined,
                      label: 'Account Status',
                      value: user.isActive ? 'Active' : 'Inactive',
                      valueColor: user.isActive ? AppColors.success : AppColors.error,
                    ),
                    if (isOwner && user.stallId != null && user.stallId!.isNotEmpty) ...[
                      const Divider(height: 24),
                      _buildProfileRow(
                        icon: Icons.storefront_outlined,
                        label: 'Assigned Stall ID',
                        value: '#${user.stallId}',
                      ),
                    ],
                    if (user.createdAt != null) ...[
                      const Divider(height: 24),
                      _buildProfileRow(
                        icon: Icons.calendar_today_rounded,
                        label: 'Member Since',
                        value: '${user.createdAt!.day}/${user.createdAt!.month}/${user.createdAt!.year}',
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Logout Button
            AppButton(
              label: 'Sign Out / Logout',
              variant: AppButtonVariant.outline,
              onPressed: () {
                ref.read(authControllerProvider.notifier).signOut();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileRow({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.textSecondary),
        const SizedBox(width: 12),
        Text(label, style: AppTypography.bodyMedium),
        const Spacer(),
        Text(
          value,
          style: AppTypography.titleMedium.copyWith(
            color: valueColor ?? AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
