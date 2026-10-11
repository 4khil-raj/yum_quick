import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yum_quick/src/core/utils/pricing_calculator.dart';

import '../../domain/entities/cart_item_entity.dart';
import '../../domain/repositories/cart_repository.dart';
import 'cart_event.dart';
import 'cart_state.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  final CartRepository cartRepository;
  CartItemEntity? _recentlyRemovedItem;
  String? _appliedPromoCode;

  CartBloc({required this.cartRepository}) : super(const CartInitial()) {
    on<LoadCartReq>(_onLoadCart);
    on<AddToCartReq>(_onAddToCart);
    on<RemoveFromCartReq>(_onRemoveCartItem);
    on<UpdateCartQuantityReq>(_onUpdateCartQuantity);
    on<RestoreRemovedCartItemReq>(_onRestoreRemovedItem);
    on<ApplyPromoCodeReq>(_onApplyPromoCode);
    on<RemovePromoCodeReq>(_onRemovePromoCode);
    on<ClearCartReq>(_onClearCart);
  }

  Future<void> _onLoadCart(LoadCartReq event, Emitter<CartState> emit) async {
    emit(const CartLoading());
    try {
      final items = await cartRepository.getCartItems();
      if (items.isEmpty) {
        emit(CartEmpty(recentlyRemovedItem: _recentlyRemovedItem));
      } else {
        emit(_buildLoadedState(items));
      }
    } catch (e) {
      emit(CartError(e.toString()));
    }
  }

  Future<void> _onAddToCart(AddToCartReq event, Emitter<CartState> emit) async {
    final currentItems = _getCurrentItems();
    final index = currentItems.indexWhere(
      (i) => i.recipeId == event.item.recipeId,
    );

    List<CartItemEntity> updatedItems;
    if (index >= 0) {
      final existing = currentItems[index];
      final newQuantity = existing.quantity + event.item.quantity;
      final updated = existing.copyWith(quantity: newQuantity);
      updatedItems = List.from(currentItems)..[index] = updated;
    } else {
      updatedItems = [...currentItems, event.item];
    }

    await cartRepository.saveCartItems(updatedItems);
    emit(_buildLoadedState(updatedItems));
  }

  Future<void> _onRemoveCartItem(
    RemoveFromCartReq event,
    Emitter<CartState> emit,
  ) async {
    final currentItems = _getCurrentItems();
    final targetIndex = currentItems.indexWhere(
      (i) => i.recipeId == event.recipeId,
    );
    if (targetIndex < 0) return;

    _recentlyRemovedItem = currentItems[targetIndex];
    final updated = List<CartItemEntity>.from(currentItems)
      ..removeAt(targetIndex);

    await cartRepository.saveCartItems(updated);
    if (updated.isEmpty) {
      emit(CartEmpty(recentlyRemovedItem: _recentlyRemovedItem));
    } else {
      emit(_buildLoadedState(updated));
    }
  }

  Future<void> _onUpdateCartQuantity(
    UpdateCartQuantityReq event,
    Emitter<CartState> emit,
  ) async {
    final currentItems = _getCurrentItems();
    final index = currentItems.indexWhere((i) => i.recipeId == event.recipeId);
    if (index < 0) return;

    List<CartItemEntity> updated;
    if (event.quantity <= 0) {
      _recentlyRemovedItem = currentItems[index];
      updated = List.from(currentItems)..removeAt(index);
    } else {
      final item = currentItems[index].copyWith(quantity: event.quantity);
      updated = List.from(currentItems)..[index] = item;
    }

    await cartRepository.saveCartItems(updated);
    if (updated.isEmpty) {
      emit(CartEmpty(recentlyRemovedItem: _recentlyRemovedItem));
    } else {
      emit(_buildLoadedState(updated));
    }
  }

  Future<void> _onRestoreRemovedItem(
    RestoreRemovedCartItemReq event,
    Emitter<CartState> emit,
  ) async {
    if (_recentlyRemovedItem == null) return;
    final toRestore = _recentlyRemovedItem!;
    _recentlyRemovedItem = null;

    add(AddToCartReq(toRestore));
  }

  Future<void> _onApplyPromoCode(
    ApplyPromoCodeReq event,
    Emitter<CartState> emit,
  ) async {
    _appliedPromoCode = event.promoCode;
    final currentItems = _getCurrentItems();
    if (currentItems.isNotEmpty) {
      emit(_buildLoadedState(currentItems));
    }
  }

  Future<void> _onRemovePromoCode(
    RemovePromoCodeReq event,
    Emitter<CartState> emit,
  ) async {
    _appliedPromoCode = null;
    final currentItems = _getCurrentItems();
    if (currentItems.isNotEmpty) {
      emit(_buildLoadedState(currentItems));
    }
  }

  Future<void> _onClearCart(ClearCartReq event, Emitter<CartState> emit) async {
    await cartRepository.clearCart();
    _recentlyRemovedItem = null;
    emit(const CartEmpty());
  }

  List<CartItemEntity> _getCurrentItems() {
    if (state is CartLoaded) {
      return (state as CartLoaded).items;
    }
    return [];
  }

  CartLoaded _buildLoadedState(List<CartItemEntity> items) {
    final subtotal = items.fold(0.0, (sum, item) => sum + item.totalPrice);
    final tax = PricingCalculator.calculateTax(subtotal);
    final delivery = PricingCalculator.calculateDeliveryFee(subtotal);
    final service = PricingCalculator.calculateServiceFee(subtotal);
    final discount = PricingCalculator.calculateDiscount(
      subtotal,
      promoCode: _appliedPromoCode,
    );
    final total = PricingCalculator.calculateTotal(
      subtotal: subtotal,
      discount: discount,
    );

    return CartLoaded(
      items: items,
      subtotal: subtotal,
      tax: tax,
      deliveryFee: delivery,
      serviceFee: service,
      discount: discount,
      total: total,
      promoCode: _appliedPromoCode,
      recentlyRemovedItem: _recentlyRemovedItem,
    );
  }
}
