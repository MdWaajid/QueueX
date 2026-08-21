import 'package:cloud_firestore/cloud_firestore.dart';

class OrderItemModel {
  final String orderItemId;
  final String orderId;
  final String itemId;
  final String itemName;
  final double unitPrice;
  final int quantity;
  final double subtotal;

  const OrderItemModel({
    required this.orderItemId,
    required this.orderId,
    required this.itemId,
    required this.itemName,
    required this.unitPrice,
    required this.quantity,
    required this.subtotal,
  });

  factory OrderItemModel.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return OrderItemModel.fromMap(data, doc.id);
  }

  factory OrderItemModel.fromMap(Map<String, dynamic> map, String id) {
    return OrderItemModel(
      orderItemId: id,
      orderId: map['orderId'] as String? ?? '',
      itemId: map['itemId'] as String? ?? '',
      itemName: map['itemName'] as String? ?? '',
      unitPrice: (map['unitPrice'] as num?)?.toDouble() ?? 0.0,
      quantity: map['quantity'] as int? ?? 1,
      subtotal: (map['subtotal'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'orderItemId': orderItemId,
      'orderId': orderId,
      'itemId': itemId,
      'itemName': itemName,
      'unitPrice': unitPrice,
      'quantity': quantity,
      'subtotal': subtotal,
    };
  }
}
