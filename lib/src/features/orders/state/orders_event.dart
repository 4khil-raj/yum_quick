import 'package:equatable/equatable.dart';

import '../../cart/domain/entities/cart_item_entity.dart';
import '../domain/entities/order_entity.dart';

sealed class OrdersEvent extends Equatable {
  const OrdersEvent();

  @override
  List<Object?> get props => [];
}

class LoadOrdersReq extends OrdersEvent {
  const LoadOrdersReq();
}

class PlaceOrderReq extends OrdersEvent {
  final List<CartItemEntity> items;
  final double subtotal;
  final double tax;
  final double deliveryFee;
  final double total;
  final String deliveryAddress;
  final String deliveryNotes;

  const PlaceOrderReq({
    required this.items,
    required this.subtotal,
    required this.tax,
    required this.deliveryFee,
    required this.total,
    required this.deliveryAddress,
    this.deliveryNotes = '',
  });

  @override
  List<Object?> get props => [
    items,
    subtotal,
    tax,
    deliveryFee,
    total,
    deliveryAddress,
    deliveryNotes,
  ];
}

class CancelOrderReq extends OrdersEvent {
  final String orderId;
  final String reason;

  const CancelOrderReq({required this.orderId, required this.reason});

  @override
  List<Object?> get props => [orderId, reason];
}

class UpdateOrderStatusReq extends OrdersEvent {
  final String orderId;
  final OrderStatus status;

  const UpdateOrderStatusReq({required this.orderId, required this.status});

  @override
  List<Object?> get props => [orderId, status];
}
