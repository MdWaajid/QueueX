import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:queuex/core/config/app_config.dart';
import 'package:queuex/features/auth/presentation/providers/auth_provider.dart';
import 'package:queuex/main.dart';
import 'widget/phone_login_screen_test.dart';

void main() {
  testWidgets('QueueXApp renders splash or initial route safely', (WidgetTester tester) async {
    final config = AppConfig.instance;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(FakeAuthRepository()),
        ],
        child: QueueXApp(config: config),
      ),
    );
    await tester.pump();

    expect(find.text('QueueX'), findsOneWidget);
  });
}
