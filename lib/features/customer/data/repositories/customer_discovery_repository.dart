import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/models/food_category_model.dart';
import '../../domain/models/stall_model.dart';

abstract class CustomerDiscoveryRepository {
  Future<List<StallModel>> getStalls();
  Future<StallModel?> getStallById(String stallId);
  Future<List<FoodCategoryModel>> getCategories({String? stallId});
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
}
