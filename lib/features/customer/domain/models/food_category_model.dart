import 'package:cloud_firestore/cloud_firestore.dart';

class FoodCategoryModel {
  final String categoryId;
  final String stallId;
  final String name;
  final String imageUrl;
  final int sortOrder;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const FoodCategoryModel({
    required this.categoryId,
    required this.stallId,
    required this.name,
    required this.imageUrl,
    required this.sortOrder,
    required this.isActive,
    this.createdAt,
    this.updatedAt,
  });

  factory FoodCategoryModel.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return FoodCategoryModel.fromMap(data, doc.id);
  }

  factory FoodCategoryModel.fromMap(Map<String, dynamic> map, String id) {
    return FoodCategoryModel(
      categoryId: id,
      stallId: map['stallId'] as String? ?? '',
      name: map['name'] as String? ?? '',
      imageUrl: map['imageUrl'] as String? ?? '',
      sortOrder: map['sortOrder'] as int? ?? 0,
      isActive: map['isActive'] as bool? ?? true,
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
      'categoryId': categoryId,
      'stallId': stallId,
      'name': name,
      'imageUrl': imageUrl,
      'sortOrder': sortOrder,
      'isActive': isActive,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : null,
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }
}
