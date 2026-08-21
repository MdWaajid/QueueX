import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:queuex/features/orders/domain/models/order_model.dart';
import 'package:queuex/features/owner/presentation/widgets/owner_order_card.dart';

void main() {
  final pendingOrder = OrderModel(
    orderId: 'order_1',
    customerId: 'user_1',
    stallId: 'stall_1',
    slotId: 'slot_1',
    totalAmount: 300.0,
    status: OrderStatus.pending,
    paymentStatus: PaymentStatus.pending,
    paymentMethod: PaymentMethod.online,
    qrToken: 'QX-TOK123',
    slotStartTime: DateTime(2026, 8, 21, 10, 0),
    slotEndTime: DateTime(2026, 8, 21, 10, 15),
  );

  final preparingOrder = pendingOrder.copyWith(status: OrderStatus.preparing);

  testWidgets('OwnerOrderCard renders Accept and Reject buttons for Pending status',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: OwnerOrderCard(order: pendingOrder),
          ),
        ),
      ),
    );

    expect(find.text('Accept Order'), findsOneWidget);
    expect(find.text('Reject'), findsOneWidget);
  });

  testWidgets('OwnerOrderCard renders Mark Ready button for Preparing status',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: OwnerOrderCard(order: preparingOrder),
          ),
        ),
      ),
    );

    expect(find.text('Mark Ready for Pickup'), findsOneWidget);
  });
}
