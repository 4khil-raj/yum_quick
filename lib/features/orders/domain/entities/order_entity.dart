import 'package:equatable/equatable.dart';
import 'package:yum_quick/features/cart/domain/entities/cart_item_entity.dart';

enum OrderStatus {
  placed('Order Placed'),
  preparing('Preparing Food'),
  onTheWay('On the Way'),
  delivered('Delivered'),
  cancelled('Cancelled');

  final String label;
  const OrderStatus(this.label);
}

class OrderEntity extends Equatable {
  final String orderId;
  final List<CartItemEntity> items;
  final double subtotal;
  final double tax;
  final double deliveryFee;
  final double total;
  final OrderStatus status;
  final DateTime orderDate;
  final String deliveryAddress;
  final String deliveryNotes;
  final String? cancellationReason;

  const OrderEntity({
    required this.orderId,
    required this.items,
    required this.subtotal,
    required this.tax,
    required this.deliveryFee,
    required this.total,
    required this.status,
    required this.orderDate,
    required this.deliveryAddress,
    this.deliveryNotes = '',
    this.cancellationReason,
  });

  bool get isActive =>
      status == OrderStatus.placed ||
      status == OrderStatus.preparing ||
      status == OrderStatus.onTheWay;

  OrderEntity copyWith({
    String? orderId,
    List<CartItemEntity>? items,
    double? subtotal,
    double? tax,
    double? deliveryFee,
    double? total,
    OrderStatus? status,
    DateTime? orderDate,
    String? deliveryAddress,
    String? deliveryNotes,
    String? cancellationReason,
  }) {
    return OrderEntity(
      orderId: orderId ?? this.orderId,
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      tax: tax ?? this.tax,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      total: total ?? this.total,
      status: status ?? this.status,
      orderDate: orderDate ?? this.orderDate,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      deliveryNotes: deliveryNotes ?? this.deliveryNotes,
      cancellationReason: cancellationReason ?? this.cancellationReason,
    );
  }

  @override
  List<Object?> get props => [
    orderId,
    items,
    subtotal,
    tax,
    deliveryFee,
    total,
    status,
    orderDate,
    deliveryAddress,
    deliveryNotes,
    cancellationReason,
  ];
}
