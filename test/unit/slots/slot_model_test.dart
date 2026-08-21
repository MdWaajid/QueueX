import 'package:flutter_test/flutter_test.dart';
import 'package:queuex/features/slots/domain/models/slot_model.dart';

void main() {
  group('SlotModel Unit Tests', () {
    test('SlotModel availabilityState returns Available when booked < 75%', () {
      final slot = SlotModel(
        slotId: 'slot_1',
        stallId: 'stall_1',
        startTime: DateTime.now(),
        endTime: DateTime.now().add(const Duration(minutes: 15)),
        capacity: 10,
        bookedCount: 5, // 50%
        status: 'active',
        isPeak: false,
      );

      expect(slot.availabilityState, SlotAvailabilityState.available);
      expect(slot.isSelectable, isTrue);
    });

    test('SlotModel availabilityState returns Moderate when booked >= 75%', () {
      final slot = SlotModel(
        slotId: 'slot_2',
        stallId: 'stall_1',
        startTime: DateTime.now(),
        endTime: DateTime.now().add(const Duration(minutes: 15)),
        capacity: 10,
        bookedCount: 8, // 80%
        status: 'active',
        isPeak: false,
      );

      expect(slot.availabilityState, SlotAvailabilityState.moderate);
      expect(slot.isSelectable, isTrue);
    });

    test('SlotModel availabilityState returns Peak when isPeak is true', () {
      final slot = SlotModel(
        slotId: 'slot_3',
        stallId: 'stall_1',
        startTime: DateTime.now(),
        endTime: DateTime.now().add(const Duration(minutes: 15)),
        capacity: 10,
        bookedCount: 2,
        status: 'active',
        isPeak: true,
      );

      expect(slot.availabilityState, SlotAvailabilityState.peak);
      expect(slot.isSelectable, isTrue);
    });

    test('SlotModel availabilityState returns Full when booked >= capacity', () {
      final slot = SlotModel(
        slotId: 'slot_4',
        stallId: 'stall_1',
        startTime: DateTime.now(),
        endTime: DateTime.now().add(const Duration(minutes: 15)),
        capacity: 10,
        bookedCount: 10, // 100%
        status: 'active',
        isPeak: false,
      );

      expect(slot.availabilityState, SlotAvailabilityState.full);
      expect(slot.isSelectable, isFalse);
    });

    test('SlotModel availabilityState returns Full when status is disabled', () {
      final slot = SlotModel(
        slotId: 'slot_5',
        stallId: 'stall_1',
        startTime: DateTime.now(),
        endTime: DateTime.now().add(const Duration(minutes: 15)),
        capacity: 10,
        bookedCount: 0,
        status: 'disabled',
        isPeak: false,
      );

      expect(slot.availabilityState, SlotAvailabilityState.full);
      expect(slot.isSelectable, isFalse);
    });
  });
}
