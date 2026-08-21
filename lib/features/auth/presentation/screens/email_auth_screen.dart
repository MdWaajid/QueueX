import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../providers/auth_provider.dart';

class EmailAuthScreen extends ConsumerStatefulWidget {
  const EmailAuthScreen({super.key});

  @override
  ConsumerState<EmailAuthScreen> createState() => _EmailAuthScreenState();
}

class _EmailAuthScreenState extends ConsumerState<EmailAuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isSignUpMode = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (_isSignUpMode) {
      ref.read(authControllerProvider.notifier).signUpWithEmail(
            email: email,
            password: password,
          );
    } else {
      ref.read(authControllerProvider.notifier).signInWithEmail(
            email: email,
            password: password,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final isLoading = authState is AuthLoadingState;

    ref.listen<AuthState>(authControllerProvider, (previous, next) {
      if (next is AuthErrorState) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.message),
            backgroundColor: AppColors.error,
          ),
        );
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(_isSignUpMode ? 'Create Email Account' : 'Email Sign In'),
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
                Text(
                  _isSignUpMode ? 'Sign Up with Email' : 'Welcome Back',
                  style: AppTypography.displayLarge,
                ),
                AppSpacing.gapSm,
                Text(
                  _isSignUpMode
                      ? 'Create a free QueueX account using your email address.'
                      : 'Enter your email and password to sign into QueueX.',
                  style: AppTypography.bodySecondary,
                ),
                AppSpacing.gapXl,

                // Email Address Input
                AppTextField(
                  label: 'Email Address',
                  hint: 'name@example.com',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: const Icon(Icons.email_outlined),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your email address';
                    }
                    final emailRegex =
                        RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                    if (!emailRegex.hasMatch(value.trim())) {
                      return 'Please enter a valid email address';
                    }
                    return null;
                  },
                ),
                AppSpacing.gapLg,

                // Password Input
                AppTextField(
                  label: 'Password',
                  hint: 'Enter password',
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: AppColors.textSecondary,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters long';
                    }
                    return null;
                  },
                ),
                AppSpacing.gapLg,

                // Confirm Password Input (Sign Up Mode Only)
                if (_isSignUpMode) ...[
                  AppTextField(
                    label: 'Confirm Password',
                    hint: 'Re-enter password',
                    controller: _confirmPasswordController,
                    obscureText: _obscureConfirmPassword,
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: AppColors.textSecondary,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        });
                      },
                    ),
                    validator: (value) {
                      if (_isSignUpMode) {
                        if (value == null || value.isEmpty) {
                          return 'Please confirm your password';
                        }
                        if (value != _passwordController.text) {
                          return 'Passwords do not match';
                        }
                      }
                      return null;
                    },
                  ),
                  AppSpacing.gapLg,
                ],

                // Submit Button
                AppButton(
                  label: _isSignUpMode ? 'Register Account' : 'Sign In',
                  isLoading: isLoading,
                  onPressed: _submit,
                ),
                AppSpacing.gapLg,

                // Mode Toggle Button
                Center(
                  child: TextButton(
                    onPressed: () {
                      setState(() {
                        _isSignUpMode = !_isSignUpMode;
                        _formKey.currentState?.reset();
                      });
                    },
                    child: Text(
                      _isSignUpMode
                          ? 'Already have an account? Sign In'
                          : 'Don\'t have an account? Register with Email',
                      style: AppTypography.titleMedium.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
