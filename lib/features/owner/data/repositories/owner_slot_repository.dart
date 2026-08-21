import 'package:cloud_firestore/cloud_firestore.dart';

abstract class OwnerSlotRepository {
  Future<void> togglePeakMode({
    required String stallId,
    required bool isPeakModeEnabled,
  });
  Future<void> updateSlotCapacity({
    required String stallId,
    required String slotId,
    required int maxCapacity,
  });
  Future<void> pauseSlot({
    required String stallId,
    required String slotId,
    required bool isPaused,
  });
}

class FirebaseOwnerSlotRepository implements OwnerSlotRepository {
  final FirebaseFirestore _firestore;

  FirebaseOwnerSlotRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<void> togglePeakMode({
    required String stallId,
    required bool isPeakModeEnabled,
  }) async {
    if (stallId.isEmpty) return;

    final stallRef = _firestore.collection('stalls').doc(stallId);
    await stallRef.update({
      'isPeakModeEnabled': isPeakModeEnabled,
      'crowdState': isPeakModeEnabled ? 'peak' : 'moderate',
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> updateSlotCapacity({
    required String stallId,
    required String slotId,
    required int maxCapacity,
  }) async {
    if (stallId.isEmpty || slotId.isEmpty) return;

    final slotRef = _firestore.collection('slots').doc(slotId);

    await slotRef.set({
      'maxCapacity': maxCapacity,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  @override
  Future<void> pauseSlot({
    required String stallId,
    required String slotId,
    required bool isPaused,
  }) async {
    if (stallId.isEmpty || slotId.isEmpty) return;

    final slotRef = _firestore.collection('slots').doc(slotId);

    await slotRef.set({
      'isPaused': isPaused,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
