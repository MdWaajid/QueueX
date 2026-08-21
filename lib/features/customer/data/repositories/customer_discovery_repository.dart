import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/models/food_category_model.dart';
import '../../domain/models/menu_item_model.dart';
import '../../domain/models/stall_model.dart';

abstract class CustomerDiscoveryRepository {
  Future<List<StallModel>> getStalls();
  Future<StallModel?> getStallById(String stallId);
  Stream<StallModel?> getStallStream(String stallId);
  Future<List<FoodCategoryModel>> getCategories({String? stallId});
  Future<List<MenuItemModel>> getMenuItems({required String stallId, String? categoryId});
  Future<MenuItemModel?> getMenuItemById(String itemId);
}

class FirebaseCustomerDiscoveryRepository implements CustomerDiscoveryRepository {
  final FirebaseFirestore _firestore;

  FirebaseCustomerDiscoveryRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<List<StallModel>> getStalls() async {
    final snapshot = await _firestore
        .collection('stalls')
        .where('status', whereIn: ['active', 'closed'])
        .get();

    return snapshot.docs
        .map((doc) => StallModel.fromFirestore(doc))
        .toList();
  }

  @override
  Future<StallModel?> getStallById(String stallId) async {
    final doc = await _firestore.collection('stalls').doc(stallId).get();
    if (!doc.exists) return null;
    return StallModel.fromFirestore(doc);
  }

  @override
  Stream<StallModel?> getStallStream(String stallId) {
    return _firestore
        .collection('stalls')
        .doc(stallId)
        .snapshots()
        .map((doc) => doc.exists ? StallModel.fromFirestore(doc) : null);
  }

  @override
  Future<List<FoodCategoryModel>> getCategories({String? stallId}) async {
    Query<Map<String, dynamic>> query = _firestore
        .collection('foodCategories')
        .where('isActive', isEqualTo: true);

    if (stallId != null && stallId.isNotEmpty) {
      query = query.where('stallId', isEqualTo: stallId);
    }

    final snapshot = await query.get();
    final categories = snapshot.docs
        .map((doc) => FoodCategoryModel.fromFirestore(doc))
        .toList();

    categories.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    return categories;
  }

  @override
  Future<List<MenuItemModel>> getMenuItems({
    required String stallId,
    String? categoryId,
  }) async {
    Query<Map<String, dynamic>> query = _firestore
        .collection('menuItems')
        .where('stallId', isEqualTo: stallId);

    if (categoryId != null && categoryId.isNotEmpty) {
      query = query.where('categoryId', isEqualTo: categoryId);
    }

    final snapshot = await query.get();
    return snapshot.docs
        .map((doc) => MenuItemModel.fromFirestore(doc))
        .toList();
  }

  @override
  Future<MenuItemModel?> getMenuItemById(String itemId) async {
    final doc = await _firestore.collection('menuItems').doc(itemId).get();
    if (!doc.exists) return null;
    return MenuItemModel.fromFirestore(doc);
  }
}
