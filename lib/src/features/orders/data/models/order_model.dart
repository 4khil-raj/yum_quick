import 'package:yum_quick/src/features/cart/domain/entities/cart_item_entity.dart';
import '../../domain/entities/order_entity.dart';

class OrderModel extends OrderEntity {
  const OrderModel({
    required super.orderId,
    required super.items,
    required super.subtotal,
    required super.tax,
    required super.deliveryFee,
    required super.total,
    required super.status,
    required super.orderDate,
    required super.deliveryAddress,
    super.deliveryNotes,
    super.cancellationReason,
  });

  factory OrderModel.fromEntity(OrderEntity entity) {
    return OrderModel(
      orderId: entity.orderId,
      items: entity.items,
      subtotal: entity.subtotal,
      tax: entity.tax,
      deliveryFee: entity.deliveryFee,
      total: entity.total,
      status: entity.status,
      orderDate: entity.orderDate,
      deliveryAddress: entity.deliveryAddress,
      deliveryNotes: entity.deliveryNotes,
      cancellationReason: entity.cancellationReason,
    );
  }

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      orderId: json['orderId'] as String? ?? '',
      items: (json['items'] as List<dynamic>? ?? [])
          .map((item) => CartItemEntity.fromJson(item as Map<String, dynamic>))
          .toList(),
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0.0,
      tax: (json['tax'] as num?)?.toDouble() ?? 0.0,
      deliveryFee: (json['deliveryFee'] as num?)?.toDouble() ?? 0.0,
      total: (json['total'] as num?)?.toDouble() ?? 0.0,
      status: OrderStatus.values.firstWhere(
        (s) => s.name == json['status'],
        orElse: () => OrderStatus.placed,
      ),
      orderDate: json['orderDate'] != null
          ? DateTime.parse(json['orderDate'] as String)
          : DateTime.now(),
      deliveryAddress: json['deliveryAddress'] as String? ?? '',
      deliveryNotes: json['deliveryNotes'] as String? ?? '',
      cancellationReason: json['cancellationReason'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'orderId': orderId,
      'items': items.map((item) => item.toJson()).toList(),
      'subtotal': subtotal,
      'tax': tax,
      'deliveryFee': deliveryFee,
      'total': total,
      'status': status.name,
      'orderDate': orderDate.toIso8601String(),
      'deliveryAddress': deliveryAddress,
      'deliveryNotes': deliveryNotes,
      'cancellationReason': cancellationReason,
    };
  }
}
