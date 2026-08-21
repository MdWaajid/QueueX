import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:queuex/features/qr/domain/services/qr_validation_service.dart';
import 'package:queuex/features/qr/presentation/widgets/qr_token_card.dart';

void main() {
  const qrToken = 'QX-TESTTOKEN999';
  final validResult = QrValidationResult.valid(
    expirationTime: DateTime(2026, 8, 21, 10, 30),
    remainingGraceMinutes: 15,
  );

  final expiredResult = QrValidationResult.invalid(
    reason: 'Expired token',
    expirationTime: DateTime(2026, 8, 21, 10, 30),
  );

  testWidgets('QrTokenCard renders token text, vector graphic, and valid badge',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: QrTokenCard(
            qrToken: qrToken,
            validationResult: validResult,
          ),
        ),
      ),
    );

    expect(find.text('Pickup QR Token'), findsOneWidget);
    expect(find.text(qrToken), findsOneWidget);
    expect(find.text('Valid for Pickup'), findsOneWidget);
    expect(find.byType(CustomPaint), findsWidgets);
  });

  testWidgets('QrTokenCard renders expired badge when invalid',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: QrTokenCard(
            qrToken: qrToken,
            validationResult: expiredResult,
          ),
        ),
      ),
    );

    expect(find.text('Expired token'), findsOneWidget);
    expect(find.text(qrToken), findsOneWidget);
  });
}
