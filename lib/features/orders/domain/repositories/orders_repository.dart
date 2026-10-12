import '../entities/order_entity.dart';

abstract class OrdersRepository {
  Future<List<OrderEntity>> getOrders();
  Future<OrderEntity> placeOrder(OrderEntity order);
  Future<OrderEntity?> cancelOrder(String orderId, String? reason);
  Future<OrderEntity?> updateOrderStatus(String orderId, OrderStatus status);
}
