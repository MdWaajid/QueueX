import 'package:cloud_firestore/cloud_firestore.dart';

enum CrowdState {
  available,
  moderate,
  peak,
}

extension CrowdStateX on CrowdState {
  String get label {
    switch (this) {
      case CrowdState.available:
        return 'Available';
      case CrowdState.moderate:
        return 'Moderate';
      case CrowdState.peak:
        return 'Peak';
    }
  }
}

class StallModel {
  final String stallId;
  final String ownerId;
  final String stallName;
  final String description;
  final String stallImage;
  final String phoneNumber;
  final String locationName;
  final double? latitude;
  final double? longitude;
  final String status;
  final String openingTime;
  final String closingTime;
  final String timezone;
  final bool isPeakModeEnabled;
  final DateTime? peakModeEndTime;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const StallModel({
    required this.stallId,
    required this.ownerId,
    required this.stallName,
    required this.description,
    required this.stallImage,
    required this.phoneNumber,
    required this.locationName,
    this.latitude,
    this.longitude,
    required this.status,
    required this.openingTime,
    required this.closingTime,
    required this.timezone,
    required this.isPeakModeEnabled,
    this.peakModeEndTime,
    this.createdAt,
    this.updatedAt,
  });

  String get name => stallName;
  bool get isOpen => status.toLowerCase() == 'active';
  bool get isClosed => !isOpen;

  CrowdState get crowdState {
    if (isPeakModeEnabled) {
      if (peakModeEndTime != null && DateTime.now().isAfter(peakModeEndTime!)) {
        return CrowdState.available;
      }
      return CrowdState.peak;
    }
    return CrowdState.available;
  }

  factory StallModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return StallModel.fromMap(data, doc.id);
  }

  factory StallModel.fromMap(Map<String, dynamic> map, String id) {
    return StallModel(
      stallId: id,
      ownerId: map['ownerId'] as String? ?? '',
      stallName: map['stallName'] as String? ?? map['name'] as String? ?? '',
      description: map['description'] as String? ?? '',
      stallImage: map['stallImage'] as String? ?? '',
      phoneNumber: map['phoneNumber'] as String? ?? '',
      locationName: map['locationName'] as String? ?? '',
      latitude: (map['latitude'] as num?)?.toDouble(),
      longitude: (map['longitude'] as num?)?.toDouble(),
      status: map['status'] as String? ?? 'closed',
      openingTime: map['openingTime'] as String? ?? '09:00',
      closingTime: map['closingTime'] as String? ?? '21:00',
      timezone: map['timezone'] as String? ?? 'Asia/Kolkata',
      isPeakModeEnabled: map['isPeakModeEnabled'] as bool? ?? false,
      peakModeEndTime: map['peakModeEndTime'] != null
          ? (map['peakModeEndTime'] as Timestamp).toDate()
          : null,
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
      'stallId': stallId,
      'ownerId': ownerId,
      'stallName': stallName,
      'description': description,
      'stallImage': stallImage,
      'phoneNumber': phoneNumber,
      'locationName': locationName,
      'latitude': latitude,
      'longitude': longitude,
      'status': status,
      'openingTime': openingTime,
      'closingTime': closingTime,
      'timezone': timezone,
      'isPeakModeEnabled': isPeakModeEnabled,
      'peakModeEndTime': peakModeEndTime != null
          ? Timestamp.fromDate(peakModeEndTime!)
          : null,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : null,
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  StallModel copyWith({
    String? stallId,
    String? ownerId,
    String? stallName,
    String? name,
    String? description,
    String? stallImage,
    String? phoneNumber,
    String? locationName,
    double? latitude,
    double? longitude,
    String? status,
    String? openingTime,
    String? closingTime,
    String? timezone,
    bool? isPeakModeEnabled,
    DateTime? peakModeEndTime,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return StallModel(
      stallId: stallId ?? this.stallId,
      ownerId: ownerId ?? this.ownerId,
      stallName: stallName ?? name ?? this.stallName,
      description: description ?? this.description,
      stallImage: stallImage ?? this.stallImage,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      locationName: locationName ?? this.locationName,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      status: status ?? this.status,
      openingTime: openingTime ?? this.openingTime,
      closingTime: closingTime ?? this.closingTime,
      timezone: timezone ?? this.timezone,
      isPeakModeEnabled: isPeakModeEnabled ?? this.isPeakModeEnabled,
      peakModeEndTime: peakModeEndTime ?? this.peakModeEndTime,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
