import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:queuex/features/owner/data/repositories/owner_slot_repository.dart';
import 'package:queuex/features/owner/presentation/providers/owner_slot_provider.dart';

class MockOwnerSlotRepository implements OwnerSlotRepository {
  bool isPeakModeEnabled = false;
  int maxCapacity = 10;

  @override
  Future<void> togglePeakMode({
    required String stallId,
    required bool isPeakModeEnabled,
  }) async {
    this.isPeakModeEnabled = isPeakModeEnabled;
  }

  @override
  Future<void> updateSlotCapacity({
    required String stallId,
    required String slotId,
    required int maxCapacity,
  }) async {
    this.maxCapacity = maxCapacity;
  }

  @override
  Future<void> pauseSlot({
    required String stallId,
    required String slotId,
    required bool isPaused,
  }) async {}
}

void main() {
  group('OwnerSlotManagementNotifier Unit Tests', () {
    late ProviderContainer container;
    late MockOwnerSlotRepository mockRepo;

    setUp(() {
      mockRepo = MockOwnerSlotRepository();
      container = ProviderContainer(
        overrides: [
          ownerSlotRepositoryProvider.overrideWithValue(mockRepo),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('Initial slot management state is idle', () {
      final state = container.read(ownerSlotManagementProvider);
      expect(state, isA<OwnerSlotManagementIdleState>());
    });

    test('togglePeakMode toggles peak mode and updates state', () async {
      final notifier = container.read(ownerSlotManagementProvider.notifier);

      await notifier.togglePeakMode(
        stallId: 'stall_1',
        isPeakModeEnabled: true,
      );

      expect(mockRepo.isPeakModeEnabled, isTrue);
      final state = container.read(ownerSlotManagementProvider);
      expect(state, isA<OwnerSlotManagementSuccessState>());
      expect((state as OwnerSlotManagementSuccessState).message,
          contains('Peak Mode ENABLED'));
    });

    test('updateSlotCapacity updates slot capacity successfully', () async {
      final notifier = container.read(ownerSlotManagementProvider.notifier);

      await notifier.updateSlotCapacity(
        stallId: 'stall_1',
        slotId: 'slot_1',
        maxCapacity: 25,
      );

      expect(mockRepo.maxCapacity, 25);
      final state = container.read(ownerSlotManagementProvider);
      expect(state, isA<OwnerSlotManagementSuccessState>());
    });
  });
}
