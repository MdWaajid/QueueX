import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_otp_field.dart';
import '../providers/auth_provider.dart';

class OtpVerificationScreen extends ConsumerStatefulWidget {
  final String verificationId;
  final String phoneNumber;

  const OtpVerificationScreen({
    super.key,
    required this.verificationId,
    required this.phoneNumber,
  });

  @override
  ConsumerState<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends ConsumerState<OtpVerificationScreen> {
  String _smsCode = '';
  int _secondsRemaining = 60;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _secondsRemaining = 60;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() {
          _secondsRemaining--;
        });
      } else {
        timer.cancel();
      }
    });
  }

  void _verifyOtp() {
    if (_smsCode.length == 6) {
      ref.read(authControllerProvider.notifier).verifyOtp(
            verificationId: widget.verificationId,
            smsCode: _smsCode,
          );
    }
  }

  void _resendOtp() {
    ref.read(authControllerProvider.notifier).sendOtp(widget.phoneNumber);
    _startTimer();
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
        title: const Text('Verify OTP'),
      ),
      body: SafeArea(
        child: Padding(
          padding: AppSpacing.paddingLg,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppSpacing.gapLg,
              const Text(
                'Enter Verification Code',
                style: AppTypography.displayLarge,
              ),
              AppSpacing.gapSm,
              Text(
                'Sent to ${widget.phoneNumber}',
                style: AppTypography.bodySecondary,
              ),
              AppSpacing.gapXl,
              AppOtpField(
                onCompleted: (code) {
                  setState(() {
                    _smsCode = code;
                  });
                  _verifyOtp();
                },
                onChanged: (code) {
                  setState(() {
                    _smsCode = code;
                  });
                },
              ),
              AppSpacing.gapLg,
              Center(
                child: _secondsRemaining > 0
                    ? Text(
                        'Resend code in ${_secondsRemaining}s',
                        style: AppTypography.bodySecondary,
                      )
                    : TextButton(
                        onPressed: isLoading ? null : _resendOtp,
                        child: const Text(
                          'Resend OTP',
                          style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                        ),
                      ),
              ),
              const Spacer(),
              AppButton(
                label: 'Verify & Continue',
                isLoading: isLoading,
                isDisabled: _smsCode.length != 6,
                onPressed: _verifyOtp,
              ),
              AppSpacing.gapLg,
            ],
          ),
        ),
      ),
    );
  }
}
