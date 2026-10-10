import 'package:equatable/equatable.dart';

import '../domain/entities/cart_item_entity.dart';

sealed class CartEvent extends Equatable {
  const CartEvent();

  @override
  List<Object?> get props => [];
}

class LoadCartReq extends CartEvent {
  const LoadCartReq();
}

class AddToCartReq extends CartEvent {
  final CartItemEntity item;

  const AddToCartReq(this.item);

  @override
  List<Object?> get props => [item];
}

class RemoveFromCartReq extends CartEvent {
  final int recipeId;

  const RemoveFromCartReq(this.recipeId);

  @override
  List<Object?> get props => [recipeId];
}

class UpdateCartQuantityReq extends CartEvent {
  final int recipeId;
  final int quantity;

  const UpdateCartQuantityReq({required this.recipeId, required this.quantity});

  @override
  List<Object?> get props => [recipeId, quantity];
}

class RestoreRemovedCartItemReq extends CartEvent {
  const RestoreRemovedCartItemReq();
}

class ApplyPromoCodeReq extends CartEvent {
  final String promoCode;

  const ApplyPromoCodeReq(this.promoCode);

  @override
  List<Object?> get props => [promoCode];
}

class RemovePromoCodeReq extends CartEvent {
  const RemovePromoCodeReq();
}

class ClearCartReq extends CartEvent {
  const ClearCartReq();
}
