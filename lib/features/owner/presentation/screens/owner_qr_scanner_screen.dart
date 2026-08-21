import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/widgets/app_loading_indicator.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../qr/presentation/providers/qr_provider.dart';

class OwnerQrScannerScreen extends ConsumerStatefulWidget {
  const OwnerQrScannerScreen({super.key});

  @override
  ConsumerState<OwnerQrScannerScreen> createState() =>
      _OwnerQrScannerScreenState();
}

class _OwnerQrScannerScreenState extends ConsumerState<OwnerQrScannerScreen> {
  final TextEditingController _tokenController = TextEditingController();

  @override
  void dispose() {
    _tokenController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final redemptionState = ref.watch(qrRedemptionProvider);

    final ownerId = authState is AuthenticatedState ? authState.user.userId : '';
    final stallId = authState is AuthenticatedState ? (authState.user.stallId ?? '') : '';

    final isLoading = redemptionState is QrRedemptionLoadingState;

    ref.listen<QrRedemptionState>(qrRedemptionProvider, (prev, next) {
      if (next is QrRedemptionSuccessState) {
        _showSuccessResultModal(context, next);
      } else if (next is QrRedemptionErrorState) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.message),
            backgroundColor: AppColors.error,
          ),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Pickup QR Token'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Scanner Viewfinder Graphic Box
            Container(
              width: double.infinity,
              height: 240,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.primary, width: 2),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const Icon(
                    Icons.qr_code_scanner_rounded,
                    size: 100,
                    color: AppColors.primary,
                  ),
                  Positioned(
                    bottom: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.camera_alt_outlined,
                              size: 14, color: Colors.white),
                          SizedBox(width: 6),
                          Text(
                            'Align QR code within camera frame',
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // Manual Token Input Section
            const Text(
              'Or Enter Token Manually',
              style: AppTypography.titleMedium,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _tokenController,
              decoration: InputDecoration(
                hintText: 'QX-1a2b3c4d5e6f...',
                labelText: 'QR Token String',
                prefixIcon: const Icon(Icons.qr_code_rounded),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading
                    ? null
                    : () {
                        final token = _tokenController.text.trim();
                        if (token.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please enter a QR token string.'),
                            ),
                          );
                          return;
                        }

                        ref.read(qrRedemptionProvider.notifier).redeemToken(
                              qrToken: token,
                              stallId: stallId,
                              ownerId: ownerId,
                            );
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: isLoading
                    ? const AppLoadingIndicator()
                    : const Text('Verify & Redeem Token'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSuccessResultModal(
      BuildContext context, QrRedemptionSuccessState state) {
    final order = state.order;
    final verification = state.verification;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: AppColors.success,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: Colors.white,
                  size: 48,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'QR Token Verified Successfully!',
                style: AppTypography.displayLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Text(
                'Order ID: #${order.orderId.substring(0, order.orderId.length > 8 ? 8 : order.orderId.length).toUpperCase()}',
                style: AppTypography.labelSmall,
              ),
              const Divider(height: 24),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Order Status', style: AppTypography.bodyMedium),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'COMPLETED',
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.success,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total Amount Paid', style: AppTypography.bodyMedium),
                  Text(
                    '₹${order.totalAmount.toStringAsFixed(0)}',
                    style: AppTypography.titleMedium.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Verification Ref', style: AppTypography.bodyMedium),
                  Text(
                    '#${verification.verificationId.substring(0, verification.verificationId.length > 8 ? 8 : verification.verificationId.length).toUpperCase()}',
                    style: AppTypography.labelSmall,
                  ),
                ],
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _tokenController.clear();
                    ref.read(qrRedemptionProvider.notifier).reset();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Done / Next Scan'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
