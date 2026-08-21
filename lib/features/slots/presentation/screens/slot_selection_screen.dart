import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_error_widget.dart';
import '../../../../core/widgets/app_loading_indicator.dart';
import '../../../customer/presentation/providers/cart_provider.dart';
import 'package:go_router/go_router.dart';
import '../../../customer/presentation/providers/customer_discovery_provider.dart';
import '../providers/slot_provider.dart';
import '../widgets/slot_card.dart';

class SlotSelectionScreen extends ConsumerWidget {
  final String stallId;

  const SlotSelectionScreen({
    super.key,
    required this.stallId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stallAsync = ref.watch(stallDetailsProvider(stallId));
    final slotsAsync = ref.watch(availableSlotsProvider(stallId));
    final selectedSlot = ref.watch(selectedSlotProvider);
    final selectedSlotNotifier = ref.read(selectedSlotProvider.notifier);
    final cart = ref.watch(cartProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Pickup Slot'),
      ),
      body: stallAsync.when(
        data: (stall) {
          final stallName = stall?.stallName ?? cart.stallName ?? 'Food Stall';

          return Column(
            children: [
              // Header Summary Info
              Container(
                width: double.infinity,
                color: AppColors.background,
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.storefront_rounded,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            stallName,
                            style: AppTypography.titleLarge,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Order Total: ${cart.totalItemCount} items | ₹${cart.totalAmount.toStringAsFixed(0)}',
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.info_outline_rounded,
                            size: 16,
                            color: AppColors.primary,
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Select a 15-minute pickup slot within the next 2 hours.',
                              style: AppTypography.labelSmall,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // 15-Minute Slots List
              Expanded(
                child: slotsAsync.when(
                  data: (slots) {
                    if (slots.isEmpty) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(24),
                          child: AppEmptyState(
                            title: 'No Available Slots',
                            message:
                                'All slots for the next 2 hours are currently full or unavailable.',
                            icon: Icons.access_time_filled_rounded,
                          ),
                        ),
                      );
                    }

                    return ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: slots.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final slot = slots[index];
                        final isSelected =
                            selectedSlot?.slotId == slot.slotId;

                        return SlotCard(
                          slot: slot,
                          isSelected: isSelected,
                          onTap: () {
                            selectedSlotNotifier.selectSlot(slot);
                          },
                        );
                      },
                    );
                  },
                  loading: () => const Center(
                    child: AppLoadingIndicator(
                      message: 'Fetching available pickup slots...',
                    ),
                  ),
                  error: (error, _) => Center(
                    child: AppErrorWidget(
                      title: 'Failed to load slots',
                      message: error.toString(),
                      onRetry: () {
                        ref.invalidate(availableSlotsProvider(stallId));
                      },
                    ),
                  ),
                ),
              ),

              // Bottom Selection Action Bar
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 10,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (selectedSlot != null) ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Selected Pickup Time:',
                              style: AppTypography.labelSmall,
                            ),
                            Text(
                              '${_formatTime(selectedSlot.startTime)} - ${_formatTime(selectedSlot.endTime)}',
                              style: AppTypography.titleMedium.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                      ],
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: selectedSlot != null
                              ? () {
                                  context.push('/customer/checkout');
                                }
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('Proceed to Checkout'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(
          child: AppLoadingIndicator(
            message: 'Loading stall info...',
          ),
        ),
        error: (error, _) => Center(
          child: AppErrorWidget(
            title: 'Failed to load stall info',
            message: error.toString(),
            onRetry: () {
              ref.invalidate(stallDetailsProvider(stallId));
            },
          ),
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
