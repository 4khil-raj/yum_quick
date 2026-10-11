import 'package:equatable/equatable.dart';

import '../../domain/entities/cart_item_entity.dart';

sealed class CartState extends Equatable {
  const CartState();

  @override
  List<Object?> get props => [];
}

class CartInitial extends CartState {
  const CartInitial();
}

class CartLoading extends CartState {
  const CartLoading();
}

class CartLoaded extends CartState {
  final List<CartItemEntity> items;
  final double subtotal;
  final double tax;
  final double deliveryFee;
  final double serviceFee;
  final double discount;
  final double total;
  final String? promoCode;
  final CartItemEntity? recentlyRemovedItem;

  const CartLoaded({
    required this.items,
    required this.subtotal,
    required this.tax,
    required this.deliveryFee,
    required this.serviceFee,
    required this.discount,
    required this.total,
    this.promoCode,
    this.recentlyRemovedItem,
  });

  int get totalItemCount => items.length;
  int get totalQuantity => items.fold(0, (sum, item) => sum + item.quantity);

  CartLoaded copyWith({
    List<CartItemEntity>? items,
    double? subtotal,
    double? tax,
    double? deliveryFee,
    double? serviceFee,
    double? discount,
    double? total,
    String? promoCode,
    CartItemEntity? recentlyRemovedItem,
  }) {
    return CartLoaded(
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      tax: tax ?? this.tax,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      serviceFee: serviceFee ?? this.serviceFee,
      discount: discount ?? this.discount,
      total: total ?? this.total,
      promoCode: promoCode ?? this.promoCode,
      recentlyRemovedItem: recentlyRemovedItem ?? this.recentlyRemovedItem,
    );
  }

  @override
  List<Object?> get props => [
    items,
    subtotal,
    tax,
    deliveryFee,
    serviceFee,
    discount,
    total,
    promoCode,
    recentlyRemovedItem,
  ];
}

class CartEmpty extends CartState {
  final CartItemEntity? recentlyRemovedItem;

  const CartEmpty({this.recentlyRemovedItem});

  @override
  List<Object?> get props => [recentlyRemovedItem];
}

class CartError extends CartState {
  final String message;

  const CartError(this.message);

  @override
  List<Object?> get props => [message];
}
