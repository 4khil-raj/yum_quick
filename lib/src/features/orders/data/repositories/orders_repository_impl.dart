import '../../domain/entities/order_entity.dart';
import '../../domain/repositories/orders_repository.dart';
import '../datasources/orders_local_data_source.dart';
import '../models/order_model.dart';

class OrdersRepositoryImpl implements OrdersRepository {
  final OrdersLocalDataSource localDataSource;

  OrdersRepositoryImpl({required this.localDataSource});

  @override
  Future<List<OrderEntity>> getOrders() async {
    return await localDataSource.getOrders();
  }

  @override
  Future<OrderEntity> placeOrder(OrderEntity order) async {
    final model = OrderModel.fromEntity(order);
    return await localDataSource.saveOrder(model);
  }

  @override
  Future<OrderEntity?> cancelOrder(String orderId, String? reason) async {
    final orders = await localDataSource.getOrders();
    final index = orders.indexWhere((o) => o.orderId == orderId);
    if (index >= 0) {
      final updated = orders[index].copyWith(
        status: OrderStatus.cancelled,
        cancellationReason: reason,
      );
      return await localDataSource.updateOrder(OrderModel.fromEntity(updated));
    }
    return null;
  }

  @override
  Future<OrderEntity?> updateOrderStatus(
    String orderId,
    OrderStatus status,
  ) async {
    final orders = await localDataSource.getOrders();
    final index = orders.indexWhere((o) => o.orderId == orderId);
    if (index >= 0) {
      final updated = orders[index].copyWith(status: status);
      return await localDataSource.updateOrder(OrderModel.fromEntity(updated));
    }
    return null;
  }
}
