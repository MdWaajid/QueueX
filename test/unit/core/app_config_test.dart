import 'package:flutter_test/flutter_test.dart';
import 'package:queuex/core/config/app_config.dart';

void main() {
  group('AppConfig Tests', () {
    test('AppConfig default environment should be dev', () {
      final config = AppConfig.instance;
      expect(config.environment, equals(AppEnvironment.dev));
      expect(config.isDev, isTrue);
      expect(config.isStaging, isFalse);
      expect(config.isProd, isFalse);
    });

    test('AppConfig explicit initialization sets configuration', () {
      final customConfig = AppConfig.instance;
      expect(customConfig.apiBaseUrl, isNotEmpty);
    });
  });
}
