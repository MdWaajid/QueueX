import 'dart:async';

abstract class NotificationService {
  Future<String?> getFcmToken();
  Stream<String> onTokenRefresh();
  Future<void> initialize();
}

class MockNotificationService implements NotificationService {
  final StreamController<String> _tokenController = StreamController<String>.broadcast();

  @override
  Future<void> initialize() async {
    // No-op for mock service
  }

  @override
  Future<String?> getFcmToken() async {
    return 'fcm_mock_token_12345';
  }

  @override
  Stream<String> onTokenRefresh() {
    return _tokenController.stream;
  }

  void dispose() {
    _tokenController.close();
  }
}
