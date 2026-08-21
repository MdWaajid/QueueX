import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/owner_menu_repository.dart';
import '../../../customer/domain/models/menu_item_model.dart';

final ownerMenuRepositoryProvider = Provider<OwnerMenuRepository>((ref) {
  return FirebaseOwnerMenuRepository();
});

final ownerMenuItemsStreamProvider =
    StreamProvider.family<List<MenuItemModel>, String>((ref, stallId) {
  final repository = ref.watch(ownerMenuRepositoryProvider);
  return repository.streamStallMenuItems(stallId);
});

sealed class OwnerMenuFormState {
  const OwnerMenuFormState();
}

class OwnerMenuFormIdleState extends OwnerMenuFormState {
  const OwnerMenuFormIdleState();
}

class OwnerMenuFormLoadingState extends OwnerMenuFormState {
  const OwnerMenuFormLoadingState();
}

class OwnerMenuFormSuccessState extends OwnerMenuFormState {
  final String message;
  const OwnerMenuFormSuccessState(this.message);
}

class OwnerMenuFormErrorState extends OwnerMenuFormState {
  final String message;
  const OwnerMenuFormErrorState(this.message);
}

class OwnerMenuFormNotifier extends Notifier<OwnerMenuFormState> {
  @override
  OwnerMenuFormState build() => const OwnerMenuFormIdleState();

  Future<bool> addMenuItem({
    required String stallId,
    required String name,
    required String description,
    required double price,
    required String category,
    String? imageUrl,
    bool isAvailable = true,
  }) async {
    state = const OwnerMenuFormLoadingState();
    try {
      final repository = ref.read(ownerMenuRepositoryProvider);
      await repository.addMenuItem(
        stallId: stallId,
        name: name,
        description: description,
        price: price,
        category: category,
        imageUrl: imageUrl,
        isAvailable: isAvailable,
      );
      state = const OwnerMenuFormSuccessState('Menu item added successfully.');
      return true;
    } catch (e) {
      state = OwnerMenuFormErrorState(e.toString());
      return false;
    }
  }

  Future<bool> updateMenuItem(MenuItemModel item) async {
    state = const OwnerMenuFormLoadingState();
    try {
      final repository = ref.read(ownerMenuRepositoryProvider);
      await repository.updateMenuItem(item);
      state = const OwnerMenuFormSuccessState('Menu item updated successfully.');
      return true;
    } catch (e) {
      state = OwnerMenuFormErrorState(e.toString());
      return false;
    }
  }

  Future<void> toggleAvailability({
    required String itemId,
    required bool isAvailable,
  }) async {
    try {
      final repository = ref.read(ownerMenuRepositoryProvider);
      await repository.toggleAvailability(
        itemId: itemId,
        isAvailable: isAvailable,
      );
    } catch (e) {
      state = OwnerMenuFormErrorState(e.toString());
    }
  }

  Future<bool> deleteMenuItem(String itemId) async {
    state = const OwnerMenuFormLoadingState();
    try {
      final repository = ref.read(ownerMenuRepositoryProvider);
      await repository.deleteMenuItem(itemId);
      state = const OwnerMenuFormSuccessState('Menu item deleted.');
      return true;
    } catch (e) {
      state = OwnerMenuFormErrorState(e.toString());
      return false;
    }
  }

  void reset() {
    state = const OwnerMenuFormIdleState();
  }
}

final ownerMenuFormProvider =
    NotifierProvider<OwnerMenuFormNotifier, OwnerMenuFormState>(
        OwnerMenuFormNotifier.new);
