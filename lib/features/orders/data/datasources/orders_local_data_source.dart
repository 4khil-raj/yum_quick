import 'package:yum_quick/core/storage/hive_storage_service.dart';
import 'package:yum_quick/features/cart/domain/entities/cart_item_entity.dart';
import '../../domain/entities/order_entity.dart';
import '../models/order_model.dart';

abstract class OrdersLocalDataSource {
  Future<List<OrderModel>> getOrders();
  Future<OrderModel> saveOrder(OrderModel order);
  Future<OrderModel?> updateOrder(OrderModel order);
  Future<void> clearOrders();
}

class OrdersLocalDataSourceImpl implements OrdersLocalDataSource {
  final HiveStorageService hiveStorage;

  OrdersLocalDataSourceImpl({required this.hiveStorage});

  @override
  Future<List<OrderModel>> getOrders() async {
    final rawOrders = hiveStorage.getOrders();
    if (rawOrders.isEmpty) {
      final sampleOrders = _getSampleOrders();
      await hiveStorage.saveOrders(sampleOrders.map((o) => o.toJson()).toList());
      return sampleOrders;
    }
    return rawOrders.map((map) => OrderModel.fromJson(map)).toList();
  }

  @override
  Future<OrderModel> saveOrder(OrderModel order) async {
    final current = await getOrders();
    final updated = [order, ...current];
    await hiveStorage.saveOrders(updated.map((o) => o.toJson()).toList());
    return order;
  }

  @override
  Future<OrderModel?> updateOrder(OrderModel order) async {
    final current = await getOrders();
    final index = current.indexWhere((o) => o.orderId == order.orderId);
    if (index >= 0) {
      current[index] = order;
      await hiveStorage.saveOrders(current.map((o) => o.toJson()).toList());
      return order;
    }
    return null;
  }

  @override
  Future<void> clearOrders() async {
    await hiveStorage.clearOrders();
  }

  List<OrderModel> _getSampleOrders() {
    return [
      OrderModel(
        orderId: 'YUM-8492',
        items: const [
          CartItemEntity(
            recipeId: 1,
            recipeName: 'Classic Margherita Pizza',
            recipeImage: 'https://cdn.dummyjson.com/recipe-images/1.webp',
            unitPrice: 249.0,
            quantity: 2,
            selectedAddOns: ['Extra Cheese'],
            addOnsPrice: 30.0,
          ),
          CartItemEntity(
            recipeId: 3,
            recipeName: 'Chocolate Lava Cake',
            recipeImage: 'https://cdn.dummyjson.com/recipe-images/3.webp',
            unitPrice: 149.0,
            quantity: 1,
          ),
        ],
        subtotal: 707.0,
        tax: 35.35,
        deliveryFee: 0.0,
        total: 742.35,
        status: OrderStatus.onTheWay,
        orderDate: DateTime.now().subtract(const Duration(minutes: 25)),
        deliveryAddress: 'Flat 402, Sunshine Apartments, 12th Cross Road',
        deliveryNotes: 'Please ring doorbell twice',
      ),
      OrderModel(
        orderId: 'YUM-7104',
        items: const [
          CartItemEntity(
            recipeId: 2,
            recipeName: 'Vegetarian Burrito Bowl',
            recipeImage: 'https://cdn.dummyjson.com/recipe-images/2.webp',
            unitPrice: 199.0,
            quantity: 1,
          ),
        ],
        subtotal: 199.0,
        tax: 9.95,
        deliveryFee: 40.0,
        total: 248.95,
        status: OrderStatus.delivered,
        orderDate: DateTime.now().subtract(const Duration(days: 2)),
        deliveryAddress: 'Flat 402, Sunshine Apartments, 12th Cross Road',
      ),
      OrderModel(
        orderId: 'YUM-5318',
        items: const [
          CartItemEntity(
            recipeId: 4,
            recipeName: 'Chicken Alfredo Pasta',
            recipeImage: 'https://cdn.dummyjson.com/recipe-images/4.webp',
            unitPrice: 289.0,
            quantity: 1,
          ),
        ],
        subtotal: 289.0,
        tax: 14.45,
        deliveryFee: 40.0,
        total: 343.45,
        status: OrderStatus.cancelled,
        orderDate: DateTime.now().subtract(const Duration(days: 5)),
        deliveryAddress: 'Flat 402, Sunshine Apartments, 12th Cross Road',
        cancellationReason: 'Ordered by mistake',
      ),
    ];
  }
}
