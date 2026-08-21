import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/models/slot_model.dart';

abstract class SlotRepository {
  Future<List<SlotModel>> getAvailableSlots(String stallId);
  Stream<List<SlotModel>> streamStallSlots(String stallId);
  Future<SlotModel?> getSlotById(String slotId);
}

class FirebaseSlotRepository implements SlotRepository {
  final FirebaseFirestore _firestore;

  FirebaseSlotRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Stream<List<SlotModel>> streamStallSlots(String stallId) {
    if (stallId.isEmpty) return Stream.value([]);

    return _firestore
        .collection('slots')
        .where('stallId', isEqualTo: stallId)
        .snapshots()
        .asyncMap((snapshot) async {
      if (snapshot.docs.isNotEmpty) {
        return snapshot.docs
            .map((doc) => SlotModel.fromFirestore(doc))
            .toList()
          ..sort((a, b) => a.startTime.compareTo(b.startTime));
      }
      return await getAvailableSlots(stallId);
    }).handleError((_) async {
      return await getAvailableSlots(stallId);
    });
  }

  @override
  Future<List<SlotModel>> getAvailableSlots(String stallId) async {
    final now = DateTime.now();
    final twoHoursLater = now.add(const Duration(hours: 2));

    List<DocumentSnapshot<Map<String, dynamic>>> docs = [];
    try {
      final snapshot = await _firestore
          .collection('slots')
          .where('stallId', isEqualTo: stallId)
          .get();
      
      docs = snapshot.docs.where((doc) {
        final data = doc.data();
        if (data['startTime'] == null) return false;
        final Timestamp ts = data['startTime'] as Timestamp;
        final dt = ts.toDate();
        return dt.isAfter(now.subtract(const Duration(minutes: 15))) &&
            dt.isBefore(twoHoursLater.add(const Duration(minutes: 15)));
      }).toList();
    } catch (_) {}

    final existingSlotsMap = <String, SlotModel>{};
    for (final doc in docs) {
      final slot = SlotModel.fromFirestore(doc);
      final key = '${slot.startTime.hour}:${slot.startTime.minute}';
      existingSlotsMap[key] = slot;
    }

    bool isStallPeak = false;
    try {
      final stallDoc = await _firestore.collection('stalls').doc(stallId).get();
      if (stallDoc.exists) {
        final stallData = stallDoc.data() ?? {};
        isStallPeak = stallData['isPeakModeEnabled'] as bool? ?? false;
      }
    } catch (_) {}

    final generatedSlots = <SlotModel>[];
    DateTime nextSlotStart = _roundUpToNext15Mins(now);

    for (int i = 0; i < 8; i++) {
      final slotEnd = nextSlotStart.add(const Duration(minutes: 15));
      if (slotEnd.isAfter(twoHoursLater.add(const Duration(minutes: 5)))) break;

      final key = '${nextSlotStart.hour}:${nextSlotStart.minute}';
      if (existingSlotsMap.containsKey(key)) {
        generatedSlots.add(existingSlotsMap[key]!);
      } else {
        final generatedId =
            '${stallId}_${nextSlotStart.millisecondsSinceEpoch}';
        generatedSlots.add(
          SlotModel(
            slotId: generatedId,
            stallId: stallId,
            startTime: nextSlotStart,
            endTime: slotEnd,
            capacity: 10,
            bookedCount: 0,
            status: 'active',
            isPeak: isStallPeak,
          ),
        );
      }

      nextSlotStart = slotEnd;
    }

    return generatedSlots;
  }

  @override
  Future<SlotModel?> getSlotById(String slotId) async {
    try {
      final doc = await _firestore.collection('slots').doc(slotId).get();
      if (doc.exists) return SlotModel.fromFirestore(doc);
    } catch (_) {}
    return null;
  }

  DateTime _roundUpToNext15Mins(DateTime dt) {
    final remainder = dt.minute % 15;
    if (remainder == 0 && dt.second == 0 && dt.millisecond == 0) {
      return dt;
    }
    final minsToAdd = 15 - remainder;
    final rounded = dt.add(Duration(minutes: minsToAdd));
    return DateTime(
      rounded.year,
      rounded.month,
      rounded.day,
      rounded.hour,
      rounded.minute,
    );
  }
}
