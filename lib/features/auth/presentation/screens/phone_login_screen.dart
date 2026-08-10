import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../providers/auth_provider.dart';

class PhoneLoginScreen extends ConsumerStatefulWidget {
  const PhoneLoginScreen({super.key});

  @override
  ConsumerState<PhoneLoginScreen> createState() => _PhoneLoginScreenState();
}

class _PhoneLoginScreenState extends ConsumerState<PhoneLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _submitPhone() {
    if (_formKey.currentState?.validate() ?? false) {
      final phone = _phoneController.text.trim();
      ref.read(authControllerProvider.notifier).sendOtp(phone);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);

    ref.listen<AuthState>(authControllerProvider, (previous, next) {
      if (next is AuthErrorState) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.message),
            backgroundColor: AppColors.error,
          ),
        );
      } else if (next is AccountInactiveState) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.message),
            backgroundColor: AppColors.error,
          ),
        );
      }
    });

    final isLoading = authState is AuthLoadingState;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Sign In'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppSpacing.paddingLg,
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppSpacing.gapLg,
                const Text(
                  'Enter Mobile Number',
                  style: AppTypography.displayLarge,
                ),
                AppSpacing.gapSm,
                const Text(
                  'We will send a 6-digit verification code to your phone.',
                  style: AppTypography.bodySecondary,
                ),
                AppSpacing.gapXl,
                AppTextField(
                  label: 'Phone Number',
                  hint: '9876543210',
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  enabled: !isLoading,
                  prefixIcon: const Padding(
                    padding: EdgeInsets.all(AppSpacing.md),
                    child: Text('+91', style: AppTypography.bodyMedium),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter mobile number';
                    }
                    final clean = value.replaceAll(RegExp(r'\D'), '');
                    if (clean.length != 10) {
                      return 'Please enter a valid 10-digit mobile number';
                    }
                    return null;
                  },
                ),
                AppSpacing.gapXl,
                AppButton(
                  label: 'Get OTP',
                  isLoading: isLoading,
                  onPressed: _submitPhone,
                ),
                AppSpacing.gapLg,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
