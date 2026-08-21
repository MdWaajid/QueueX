import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/owner_slot_repository.dart';

final ownerSlotRepositoryProvider = Provider<OwnerSlotRepository>((ref) {
  return FirebaseOwnerSlotRepository();
});

sealed class OwnerSlotManagementState {
  const OwnerSlotManagementState();
}

class OwnerSlotManagementIdleState extends OwnerSlotManagementState {
  const OwnerSlotManagementIdleState();
}

class OwnerSlotManagementLoadingState extends OwnerSlotManagementState {
  const OwnerSlotManagementLoadingState();
}

class OwnerSlotManagementSuccessState extends OwnerSlotManagementState {
  final String message;
  const OwnerSlotManagementSuccessState(this.message);
}

class OwnerSlotManagementErrorState extends OwnerSlotManagementState {
  final String message;
  const OwnerSlotManagementErrorState(this.message);
}

class OwnerSlotManagementNotifier extends Notifier<OwnerSlotManagementState> {
  @override
  OwnerSlotManagementState build() => const OwnerSlotManagementIdleState();

  Future<void> togglePeakMode({
    required String stallId,
    required bool isPeakModeEnabled,
  }) async {
    try {
      final repository = ref.read(ownerSlotRepositoryProvider);
      await repository.togglePeakMode(
        stallId: stallId,
        isPeakModeEnabled: isPeakModeEnabled,
      );
      state = OwnerSlotManagementSuccessState(
        isPeakModeEnabled
            ? 'Peak Mode ENABLED. Cash payment is now restricted.'
            : 'Peak Mode DISABLED. Standard ordering restored.',
      );
    } catch (e) {
      state = OwnerSlotManagementErrorState(e.toString());
    }
  }

  Future<void> updateSlotCapacity({
    required String stallId,
    required String slotId,
    required int maxCapacity,
  }) async {
    state = const OwnerSlotManagementLoadingState();
    try {
      final repository = ref.read(ownerSlotRepositoryProvider);
      await repository.updateSlotCapacity(
        stallId: stallId,
        slotId: slotId,
        maxCapacity: maxCapacity,
      );
      state = const OwnerSlotManagementSuccessState('Slot capacity updated successfully.');
    } catch (e) {
      state = OwnerSlotManagementErrorState(e.toString());
    }
  }

  Future<void> pauseSlot({
    required String stallId,
    required String slotId,
    required bool isPaused,
  }) async {
    try {
      final repository = ref.read(ownerSlotRepositoryProvider);
      await repository.pauseSlot(
        stallId: stallId,
        slotId: slotId,
        isPaused: isPaused,
      );
      state = OwnerSlotManagementSuccessState(
        isPaused ? 'Slot paused for new bookings.' : 'Slot resumed for bookings.',
      );
    } catch (e) {
      state = OwnerSlotManagementErrorState(e.toString());
    }
  }

  void reset() {
    state = const OwnerSlotManagementIdleState();
  }
}

final ownerSlotManagementProvider =
    NotifierProvider<OwnerSlotManagementNotifier, OwnerSlotManagementState>(
        OwnerSlotManagementNotifier.new);
