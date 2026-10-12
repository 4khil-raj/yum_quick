import '../../domain/entities/cart_item_entity.dart';
import '../../domain/repositories/cart_repository.dart';
import '../datasources/cart_local_data_source.dart';

class CartRepositoryImpl implements CartRepository {
  final CartLocalDataSource localDataSource;

  CartRepositoryImpl({required this.localDataSource});

  @override
  Future<List<CartItemEntity>> getCartItems() async {
    return localDataSource.getCartItems();
  }

  @override
  Future<void> saveCartItems(List<CartItemEntity> items) async {
    await localDataSource.saveCartItems(items);
  }

  @override
  Future<void> clearCart() async {
    await localDataSource.clearCart();
  }
}
