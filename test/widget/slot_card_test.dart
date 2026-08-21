import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:queuex/features/slots/domain/models/slot_model.dart';
import 'package:queuex/features/slots/presentation/widgets/slot_card.dart';

void main() {
  final now = DateTime(2026, 8, 21, 10, 0);

  final availableSlot = SlotModel(
    slotId: 'slot_1',
    stallId: 'stall_1',
    startTime: now,
    endTime: now.add(const Duration(minutes: 15)),
    capacity: 10,
    bookedCount: 2,
    status: 'active',
    isPeak: false,
  );

  final fullSlot = SlotModel(
    slotId: 'slot_2',
    stallId: 'stall_1',
    startTime: now,
    endTime: now.add(const Duration(minutes: 15)),
    capacity: 10,
    bookedCount: 10,
    status: 'active',
    isPeak: false,
  );

  testWidgets('SlotCard renders time and Available status badge',
      (WidgetTester tester) async {
    bool tapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SlotCard(
            slot: availableSlot,
            isSelected: false,
            onTap: () => tapped = true,
          ),
        ),
      ),
    );

    expect(find.text('10:00 AM - 10:15 AM'), findsOneWidget);
    expect(find.text('Available'), findsOneWidget);

    await tester.tap(find.byType(SlotCard));
    expect(tapped, isTrue);
  });

  testWidgets('SlotCard renders Full status badge and disables tap when full',
      (WidgetTester tester) async {
    bool tapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SlotCard(
            slot: fullSlot,
            isSelected: false,
            onTap: () => tapped = true,
          ),
        ),
      ),
    );

    expect(find.text('Full'), findsOneWidget);

    await tester.tap(find.byType(SlotCard));
    expect(tapped, isFalse);
  });
}
