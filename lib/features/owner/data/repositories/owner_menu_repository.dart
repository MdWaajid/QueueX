import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../customer/domain/models/menu_item_model.dart';

abstract class OwnerMenuRepository {
  Stream<List<MenuItemModel>> streamStallMenuItems(String stallId);
  Future<MenuItemModel> addMenuItem({
    required String stallId,
    required String name,
    required String description,
    required double price,
    required String category,
    String? imageUrl,
    int preparationTimeMinutes = 10,
    bool isAvailable = true,
  });
  Future<void> updateMenuItem(MenuItemModel item);
  Future<void> toggleAvailability({
    required String itemId,
    required bool isAvailable,
  });
  Future<void> deleteMenuItem(String itemId);
}

class FirebaseOwnerMenuRepository implements OwnerMenuRepository {
  final FirebaseFirestore _firestore;

  FirebaseOwnerMenuRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Stream<List<MenuItemModel>> streamStallMenuItems(String stallId) {
    if (stallId.isEmpty) return Stream.value([]);

    return _firestore
        .collection('menuItems')
        .where('stallId', isEqualTo: stallId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MenuItemModel.fromFirestore(doc))
            .toList()
          ..sort((a, b) => a.name.compareTo(b.name)));
  }

  @override
  Future<MenuItemModel> addMenuItem({
    required String stallId,
    required String name,
    required String description,
    required double price,
    required String category,
    String? imageUrl,
    int preparationTimeMinutes = 10,
    bool isAvailable = true,
  }) async {
    final docRef = _firestore.collection('menuItems').doc();
    final now = DateTime.now();

    final item = MenuItemModel(
      itemId: docRef.id,
      stallId: stallId,
      categoryId: category.trim(),
      itemName: name.trim(),
      description: description.trim(),
      price: price,
      imageUrl: imageUrl?.trim() ?? '',
      preparationTimeMinutes: preparationTimeMinutes,
      isAvailable: isAvailable,
      createdAt: now,
      updatedAt: now,
    );

    await docRef.set(item.toMap());
    return item;
  }

  @override
  Future<void> updateMenuItem(MenuItemModel item) async {
    final docRef = _firestore.collection('menuItems').doc(item.itemId);
    final map = item.toMap();
    map['updatedAt'] = FieldValue.serverTimestamp();
    await docRef.update(map);
  }

  @override
  Future<void> toggleAvailability({
    required String itemId,
    required bool isAvailable,
  }) async {
    if (itemId.isEmpty) return;
    await _firestore.collection('menuItems').doc(itemId).update({
      'isAvailable': isAvailable,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> deleteMenuItem(String itemId) async {
    if (itemId.isEmpty) return;
    await _firestore.collection('menuItems').doc(itemId).delete();
  }
}
