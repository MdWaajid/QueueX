import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../domain/services/qr_validation_service.dart';

class QrTokenCard extends StatelessWidget {
  final String qrToken;
  final QrValidationResult validationResult;

  const QrTokenCard({
    super.key,
    required this.qrToken,
    required this.validationResult,
  });

  @override
  Widget build(BuildContext context) {
    final isValid = validationResult.isValid;
    final formattedExpiration = _formatTime(validationResult.expirationTime);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isValid ? AppColors.primary : AppColors.error,
          width: 1.5,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Pickup QR Token',
                  style: AppTypography.titleMedium,
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: (isValid ? AppColors.success : AppColors.error)
                        .withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    validationResult.reason,
                    style: AppTypography.labelSmall.copyWith(
                      color: isValid ? AppColors.success : AppColors.error,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Vector Matrix Graphic Render Box
            Container(
              width: 160,
              height: 160,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.divider),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 6,
                  ),
                ],
              ),
              child: CustomPaint(
                painter: _QrMatrixPainter(qrToken: qrToken),
              ),
            ),
            const SizedBox(height: 12),

            // Token ID & Copy Action
            InkWell(
              onTap: () {
                Clipboard.setData(ClipboardData(text: qrToken));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('QR Token copied to clipboard')),
                );
              },
              borderRadius: BorderRadius.circular(6),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      qrToken,
                      style: AppTypography.titleMedium.copyWith(
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Icon(
                      Icons.copy_rounded,
                      size: 16,
                      color: AppColors.primary,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Expiration Grace Time Indicator
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.timer_outlined,
                    size: 14,
                    color: isValid ? AppColors.primary : AppColors.error,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    isValid
                        ? 'Valid until $formattedExpiration (slot end + 15 min grace)'
                        : 'Expired at $formattedExpiration',
                    style: AppTypography.labelSmall.copyWith(
                      color: isValid ? AppColors.textPrimary : AppColors.error,
                    ),
                  ),
                ],
              ),
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

class _QrMatrixPainter extends CustomPainter {
  final String qrToken;

  _QrMatrixPainter({required this.qrToken});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;

    const int gridSize = 15;
    final double cellSize = size.width / gridSize;

    // Deterministic module generation from token string
    final bytes = qrToken.codeUnits;

    for (int r = 0; r < gridSize; r++) {
      for (int c = 0; c < gridSize; c++) {
        // Draw position finder patterns in corners
        if (_isPositionPattern(r, c, gridSize)) {
          canvas.drawRect(
            Rect.fromLTWH(
                c * cellSize, r * cellSize, cellSize + 0.5, cellSize + 0.5),
            paint,
          );
        } else {
          final index = (r * gridSize + c) % bytes.length;
          final bit = (bytes[index] + r + c) % 2 == 0;
          if (bit) {
            canvas.drawRect(
              Rect.fromLTWH(
                  c * cellSize, r * cellSize, cellSize + 0.5, cellSize + 0.5),
              paint,
            );
          }
        }
      }
    }
  }

  bool _isPositionPattern(int r, int c, int gridSize) {
    // Top-left 3x3 finder pattern
    if (r < 3 && c < 3) return true;
    // Top-right 3x3 finder pattern
    if (r < 3 && c >= gridSize - 3) return true;
    // Bottom-left 3x3 finder pattern
    if (r >= gridSize - 3 && c < 3) return true;
    return false;
  }

  @override
  bool shouldRepaint(covariant _QrMatrixPainter oldDelegate) {
    return oldDelegate.qrToken != qrToken;
  }
}
