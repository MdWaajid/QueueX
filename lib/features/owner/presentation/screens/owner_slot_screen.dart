import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/widgets/app_error_widget.dart';
import '../../../../core/widgets/app_loading_indicator.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../customer/presentation/providers/customer_discovery_provider.dart';
import '../../../slots/domain/models/slot_model.dart';
import '../../../slots/presentation/providers/slot_provider.dart';
import '../providers/owner_slot_provider.dart';

class OwnerSlotScreen extends ConsumerWidget {
  final String stallId;

  const OwnerSlotScreen({
    super.key,
    required this.stallId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<OwnerSlotManagementState>(ownerSlotManagementProvider, (prev, next) {
      if (next is OwnerSlotManagementSuccessState) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.message),
            backgroundColor: AppColors.success,
          ),
        );
      } else if (next is OwnerSlotManagementErrorState) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.message),
            backgroundColor: AppColors.error,
          ),
        );
      }
    });

    final targetStallId = stallId.isNotEmpty ? stallId : _getOwnerStallId(ref);

    if (targetStallId.isEmpty) {
      return const Scaffold(
        body: Center(
          child: Text(
            'No stall configured for this owner account.',
            style: AppTypography.titleMedium,
          ),
        ),
      );
    }

    final stallAsync = ref.watch(stallDetailsProvider(targetStallId));
    final slotsAsync = ref.watch(stallSlotsStreamProvider(targetStallId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Slot & Peak Management'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Peak Mode Toggle Card Banner
            stallAsync.when(
              data: (stall) {
                if (stall == null) return const SizedBox.shrink();
                final isPeak = stall.isPeakModeEnabled;

                return Card(
                  elevation: 2,
                  color: isPeak
                      ? AppColors.warning.withValues(alpha: 0.1)
                      : AppColors.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                      color: isPeak ? AppColors.warning : AppColors.divider,
                      width: isPeak ? 1.5 : 1,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.bolt_rounded,
                                  color: isPeak
                                      ? AppColors.warning
                                      : AppColors.textSecondary,
                                  size: 28,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Peak Mode',
                                  style: AppTypography.titleMedium.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            Switch(
                              value: isPeak,
                              activeThumbColor: AppColors.warning,
                              onChanged: (val) {
                                ref
                                    .read(ownerSlotManagementProvider.notifier)
                                    .togglePeakMode(
                                      stallId: targetStallId,
                                      isPeakModeEnabled: val,
                                    );
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          isPeak
                              ? '⚡ Peak Mode ACTIVE: Cash payment at stall is disabled at checkout to reduce queue congestion.'
                              : 'Standard Mode: Cash and Online payments are both enabled.',
                          style: AppTypography.bodyMedium.copyWith(
                            color: isPeak
                                ? AppColors.warning
                                : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
              loading: () => const AppLoadingIndicator(),
              error: (err, stack) => const SizedBox.shrink(),
            ),
            const SizedBox(height: 24),

            const Text(
              '15-Minute Slot Configuration',
              style: AppTypography.titleMedium,
            ),
            const SizedBox(height: 12),

            // Operational Slots List
            slotsAsync.when(
              data: (slots) {
                if (slots.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Text(
                        'No operational slots configured for today.',
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  );
                }

                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: slots.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final slot = slots[index];
                    return _buildOwnerSlotCard(context, ref, slot, targetStallId);
                  },
                );
              },
              loading: () => const Center(
                child: AppLoadingIndicator(message: 'Loading slot schedule...'),
              ),
              error: (error, stack) => AppErrorWidget(
                title: 'Failed to load slots',
                message: error.toString(),
                onRetry: () {
                  ref.invalidate(stallSlotsStreamProvider(targetStallId));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOwnerSlotCard(
    BuildContext context,
    WidgetRef ref,
    SlotModel slot,
    String stallId,
  ) {
    final timeRangeStr =
        '${_formatTime(slot.startTime)} - ${_formatTime(slot.endTime)}';
    final state = slot.availabilityState;

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.divider),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    timeRangeStr,
                    style: AppTypography.titleMedium.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        'Booked: ${slot.bookedCount}/${slot.maxCapacity}',
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: _getStatusColor(state).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          state.label.toUpperCase(),
                          style: AppTypography.labelSmall.copyWith(
                            color: _getStatusColor(state),
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Capacity Edit Button
            IconButton(
              icon: const Icon(Icons.edit_calendar_rounded, size: 20),
              color: AppColors.primary,
              tooltip: 'Edit Capacity',
              onPressed: () {
                _showEditCapacityDialog(context, ref, slot, stallId);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showEditCapacityDialog(
    BuildContext context,
    WidgetRef ref,
    SlotModel slot,
    String stallId,
  ) {
    final controller =
        TextEditingController(text: slot.maxCapacity.toString());

    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Capacity (${_formatTime(slot.startTime)})'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Max Capacity (Orders)',
            hintText: 'e.g. 15',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final newCap = int.tryParse(controller.text.trim());
              if (newCap != null && newCap > 0) {
                Navigator.of(context).pop();
                ref
                    .read(ownerSlotManagementProvider.notifier)
                    .updateSlotCapacity(
                      stallId: stallId,
                      slotId: slot.slotId,
                      maxCapacity: newCap,
                    );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Save Capacity'),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(SlotAvailabilityState state) {
    switch (state) {
      case SlotAvailabilityState.available:
        return AppColors.success;
      case SlotAvailabilityState.moderate:
        return AppColors.primary;
      case SlotAvailabilityState.peak:
        return AppColors.warning;
      case SlotAvailabilityState.full:
        return AppColors.error;
    }
  }

  String _formatTime(DateTime date) {
    final hour = date.hour == 0
        ? 12
        : (date.hour > 12 ? date.hour - 12 : date.hour);
    final period = date.hour >= 12 ? 'PM' : 'AM';
    final minute = date.minute.toString().padLeft(2, '0');
    return '$hour:$minute $period';
  }

  String _getOwnerStallId(WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    if (authState is AuthenticatedState) {
      final stallId = authState.user.stallId;
      if (stallId != null && stallId.isNotEmpty) return stallId;
    }
    return 'stall_1';
  }
}
