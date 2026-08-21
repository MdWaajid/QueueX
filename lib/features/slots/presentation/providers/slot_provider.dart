import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/slot_repository.dart';
import '../../domain/models/slot_model.dart';

final slotRepositoryProvider = Provider<SlotRepository>((ref) {
  return FirebaseSlotRepository();
});

final availableSlotsProvider =
    FutureProvider.family<List<SlotModel>, String>((ref, stallId) async {
  final repository = ref.watch(slotRepositoryProvider);
  return repository.getAvailableSlots(stallId);
});

final stallSlotsStreamProvider =
    StreamProvider.family<List<SlotModel>, String>((ref, stallId) {
  final repository = ref.watch(slotRepositoryProvider);
  return repository.streamStallSlots(stallId);
});

class SelectedSlotNotifier extends Notifier<SlotModel?> {
  @override
  SlotModel? build() => null;

  void selectSlot(SlotModel? slot) {
    state = slot;
  }

  void clearSelection() {
    state = null;
  }
}

final selectedSlotProvider =
    NotifierProvider<SelectedSlotNotifier, SlotModel?>(
        SelectedSlotNotifier.new);
