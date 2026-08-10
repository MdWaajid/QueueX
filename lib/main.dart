import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/config/app_config.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

import 'core/services/firebase_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Environment Configuration
  final config = AppConfig.instance;

  // Initialize Firebase Core & Services
  await FirebaseService.initialize();

  runApp(
    ProviderScope(
      child: QueueXApp(config: config),
    ),
  );
}

class QueueXApp extends ConsumerWidget {
  final AppConfig config;

  const QueueXApp({
    super.key,
    required this.config,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'QueueX',
      debugShowCheckedModeBanner: config.isDev,
      theme: AppTheme.lightTheme,
      routerConfig: router,
    );
  }
}
