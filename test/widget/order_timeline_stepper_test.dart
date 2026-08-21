import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:queuex/features/orders/domain/models/order_model.dart';
import 'package:queuex/features/orders/presentation/widgets/order_timeline_stepper.dart';

void main() {
  testWidgets('OrderTimelineStepper renders timeline steps for Pending status',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: OrderTimelineStepper(currentStatus: OrderStatus.pending),
        ),
      ),
    );

    expect(find.text('Order Status Timeline'), findsOneWidget);
    expect(find.text('Order Placed'), findsOneWidget);
    expect(find.text('Accepted'), findsOneWidget);
    expect(find.text('Preparing'), findsOneWidget);
    expect(find.text('Ready for Pickup'), findsOneWidget);
  });

  testWidgets('OrderTimelineStepper renders error banner when Cancelled',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: OrderTimelineStepper(currentStatus: OrderStatus.cancelled),
        ),
      ),
    );

    expect(find.text('Order Cancelled'), findsOneWidget);
    expect(find.text('This order has been cancelled.'), findsOneWidget);
  });
}
