import 'package:flutter_test/flutter_test.dart';
import 'package:queuex/features/customer/domain/models/stall_model.dart';

void main() {
  group('StallModel Unit Tests', () {
    test('StallModel fromMap parses correctly', () {
      final map = {
        'ownerId': 'owner_123',
        'stallName': 'Spicy Bites',
        'description': 'Delicious fast food',
        'stallImage': 'https://example.com/image.jpg',
        'phoneNumber': '+919876543210',
        'locationName': 'Food Court A',
        'latitude': 12.9716,
        'longitude': 77.5946,
        'status': 'active',
        'openingTime': '09:00',
        'closingTime': '21:00',
        'timezone': 'Asia/Kolkata',
        'isPeakModeEnabled': false,
      };

      final stall = StallModel.fromMap(map, 'stall_1');

      expect(stall.stallId, 'stall_1');
      expect(stall.ownerId, 'owner_123');
      expect(stall.stallName, 'Spicy Bites');
      expect(stall.isOpen, isTrue);
      expect(stall.isClosed, isFalse);
      expect(stall.crowdState, CrowdState.available);
    });

    test('StallModel status closed evaluates isClosed correctly', () {
      final map = {
        'stallName': 'Closed Stall',
        'status': 'closed',
        'isPeakModeEnabled': false,
      };

      final stall = StallModel.fromMap(map, 'stall_2');

      expect(stall.isOpen, isFalse);
      expect(stall.isClosed, isTrue);
    });

    test('StallModel isPeakModeEnabled sets crowdState to peak', () {
      final map = {
        'stallName': 'Busy Stall',
        'status': 'active',
        'isPeakModeEnabled': true,
      };

      final stall = StallModel.fromMap(map, 'stall_3');

      expect(stall.crowdState, CrowdState.peak);
    });
  });
}
