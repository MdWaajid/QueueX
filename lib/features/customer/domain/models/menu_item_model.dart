import 'package:cloud_firestore/cloud_firestore.dart';

class MenuItemModel {
  final String itemId;
  final String stallId;
  final String categoryId;
  final String itemName;
  final String description;
  final double price;
  final String imageUrl;
  final int preparationTimeMinutes;
  final bool isAvailable;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const MenuItemModel({
    required this.itemId,
    required this.stallId,
    required this.categoryId,
    required this.itemName,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.preparationTimeMinutes,
    required this.isAvailable,
    this.createdAt,
    this.updatedAt,
  });

  String get name => itemName;
  String get category => categoryId;

  factory MenuItemModel.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return MenuItemModel.fromMap(data, doc.id);
  }

  factory MenuItemModel.fromMap(Map<String, dynamic> map, String id) {
    return MenuItemModel(
      itemId: id,
      stallId: map['stallId'] as String? ?? '',
      categoryId: map['categoryId'] as String? ?? map['category'] as String? ?? '',
      itemName: map['itemName'] as String? ?? map['name'] as String? ?? '',
      description: map['description'] as String? ?? '',
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
      imageUrl: map['imageUrl'] as String? ?? '',
      preparationTimeMinutes: map['preparationTimeMinutes'] as int? ?? 10,
      isAvailable: map['isAvailable'] as bool? ?? true,
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] as Timestamp).toDate()
          : null,
      updatedAt: map['updatedAt'] != null
          ? (map['updatedAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'itemId': itemId,
      'stallId': stallId,
      'categoryId': categoryId,
      'itemName': itemName,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
      'preparationTimeMinutes': preparationTimeMinutes,
      'isAvailable': isAvailable,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : null,
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  MenuItemModel copyWith({
    String? itemId,
    String? stallId,
    String? categoryId,
    String? itemName,
    String? name,
    String? category,
    String? description,
    double? price,
    String? imageUrl,
    int? preparationTimeMinutes,
    bool? isAvailable,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MenuItemModel(
      itemId: itemId ?? this.itemId,
      stallId: stallId ?? this.stallId,
      categoryId: categoryId ?? category ?? this.categoryId,
      itemName: itemName ?? name ?? this.itemName,
      description: description ?? this.description,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      preparationTimeMinutes: preparationTimeMinutes ?? this.preparationTimeMinutes,
      isAvailable: isAvailable ?? this.isAvailable,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
