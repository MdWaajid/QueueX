import 'package:cloud_firestore/cloud_firestore.dart';

enum SlotAvailabilityState {
  available,
  moderate,
  peak,
  full,
}

extension SlotAvailabilityStateX on SlotAvailabilityState {
  String get label {
    switch (this) {
      case SlotAvailabilityState.available:
        return 'Available';
      case SlotAvailabilityState.moderate:
        return 'Moderate';
      case SlotAvailabilityState.peak:
        return 'Peak';
      case SlotAvailabilityState.full:
        return 'Full';
    }
  }
}

class SlotModel {
  final String slotId;
  final String stallId;
  final DateTime startTime;
  final DateTime endTime;
  final int capacity;
  final int bookedCount;
  final String status;
  final bool isPeak;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const SlotModel({
    required this.slotId,
    required this.stallId,
    required this.startTime,
    required this.endTime,
    required this.capacity,
    required this.bookedCount,
    required this.status,
    required this.isPeak,
    this.createdAt,
    this.updatedAt,
  });

  int get maxCapacity => capacity;

  SlotAvailabilityState get availabilityState {
    if (bookedCount >= capacity || status.toLowerCase() == 'disabled') {
      return SlotAvailabilityState.full;
    }
    if (isPeak) {
      return SlotAvailabilityState.peak;
    }
    if (capacity > 0 && (bookedCount / capacity) >= 0.75) {
      return SlotAvailabilityState.moderate;
    }
    return SlotAvailabilityState.available;
  }

  bool get isSelectable => availabilityState != SlotAvailabilityState.full;

  factory SlotModel.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return SlotModel.fromMap(data, doc.id);
  }

  factory SlotModel.fromMap(Map<String, dynamic> map, String id) {
    return SlotModel(
      slotId: id,
      stallId: map['stallId'] as String? ?? '',
      startTime: map['startTime'] != null
          ? (map['startTime'] as Timestamp).toDate()
          : DateTime.now(),
      endTime: map['endTime'] != null
          ? (map['endTime'] as Timestamp).toDate()
          : DateTime.now().add(const Duration(minutes: 15)),
      capacity: map['capacity'] as int? ?? map['maxCapacity'] as int? ?? 10,
      bookedCount: map['bookedCount'] as int? ?? 0,
      status: map['status'] as String? ?? 'active',
      isPeak: map['isPeak'] as bool? ?? false,
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] as Timestamp).toDate()
          : null,
      updatedAt: map['updatedAt'] != null
          ? (map['updatedAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'slotId': slotId,
      'stallId': stallId,
      'startTime': Timestamp.fromDate(startTime),
      'endTime': Timestamp.fromDate(endTime),
      'capacity': capacity,
      'bookedCount': bookedCount,
      'status': status,
      'isPeak': isPeak,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : null,
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  SlotModel copyWith({
    String? slotId,
    String? stallId,
    DateTime? startTime,
    DateTime? endTime,
    int? capacity,
    int? maxCapacity,
    int? bookedCount,
    String? status,
    bool? isPeak,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SlotModel(
      slotId: slotId ?? this.slotId,
      stallId: stallId ?? this.stallId,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      capacity: capacity ?? maxCapacity ?? this.capacity,
      bookedCount: bookedCount ?? this.bookedCount,
      status: status ?? this.status,
      isPeak: isPeak ?? this.isPeak,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
