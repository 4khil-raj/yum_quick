import 'package:equatable/equatable.dart';

import '../domain/entities/order_entity.dart';

sealed class OrdersState extends Equatable {
  const OrdersState();

  @override
  List<Object?> get props => [];
}

class OrdersInitial extends OrdersState {
  const OrdersInitial();
}

class OrdersLoading extends OrdersState {
  const OrdersLoading();
}

class OrdersLoaded extends OrdersState {
  final List<OrderEntity> orders;
  final OrderEntity? latestPlacedOrder;

  const OrdersLoaded({required this.orders, this.latestPlacedOrder});

  List<OrderEntity> get activeOrders =>
      orders.where((o) => o.isActive).toList();

  List<OrderEntity> get pastOrders => orders.where((o) => !o.isActive).toList();

  OrdersLoaded copyWith({
    List<OrderEntity>? orders,
    OrderEntity? latestPlacedOrder,
  }) {
    return OrdersLoaded(
      orders: orders ?? this.orders,
      latestPlacedOrder: latestPlacedOrder ?? this.latestPlacedOrder,
    );
  }

  @override
  List<Object?> get props => [orders, latestPlacedOrder];
}
