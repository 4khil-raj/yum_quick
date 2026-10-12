import 'package:yum_quick/core/storage/hive_storage_service.dart';

import '../../domain/entities/cart_item_entity.dart';

abstract class CartLocalDataSource {
  Future<List<CartItemEntity>> getCartItems();
  Future<void> saveCartItems(List<CartItemEntity> items);
  Future<void> clearCart();
}

class CartLocalDataSourceImpl implements CartLocalDataSource {
  final HiveStorageService hiveStorage;

  CartLocalDataSourceImpl({required this.hiveStorage});

  @override
  Future<List<CartItemEntity>> getCartItems() async {
    final rawList = hiveStorage.getCartItems();
    return rawList.map(CartItemEntity.fromJson).toList();
  }

  @override
  Future<void> saveCartItems(List<CartItemEntity> items) async {
    final list = items.map((e) => e.toJson()).toList();
    await hiveStorage.saveCartItems(list);
  }

  @override
  Future<void> clearCart() async {
    await hiveStorage.clearCart();
  }
}
