enum AppEnvironment {
  dev,
  staging,
  prod,
}

class AppConfig {
  final AppEnvironment environment;
  final String apiBaseUrl;
  final bool enableAnalytics;
  final bool enableAppCheck;

  const AppConfig._({
    required this.environment,
    required this.apiBaseUrl,
    required this.enableAnalytics,
    required this.enableAppCheck,
  });

  static AppConfig? _instance;

  static AppConfig get instance {
    _instance ??= _fromEnvironment();
    return _instance!;
  }

  static void initialize(AppConfig config) {
    _instance = config;
  }

  static AppConfig _fromEnvironment() {
    const envString = String.fromEnvironment('ENV', defaultValue: 'dev');
    switch (envString.toLowerCase()) {
      case 'prod':
      case 'production':
        return const AppConfig._(
          environment: AppEnvironment.prod,
          apiBaseUrl: 'https://api.queuex.com',
          enableAnalytics: true,
          enableAppCheck: true,
        );
      case 'staging':
        return const AppConfig._(
          environment: AppEnvironment.staging,
          apiBaseUrl: 'https://staging-api.queuex.com',
          enableAnalytics: false,
          enableAppCheck: true,
        );
      case 'dev':
      default:
        return const AppConfig._(
          environment: AppEnvironment.dev,
          apiBaseUrl: 'https://dev-api.queuex.com',
          enableAnalytics: false,
          enableAppCheck: false,
        );
    }
  }

  bool get isDev => environment == AppEnvironment.dev;
  bool get isStaging => environment == AppEnvironment.staging;
  bool get isProd => environment == AppEnvironment.prod;
}
