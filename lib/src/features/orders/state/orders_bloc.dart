import 'package:flutter_bloc/flutter_bloc.dart';

import 'dart:math';

import '../../cart/domain/entities/cart_item_entity.dart';
import '../domain/entities/order_entity.dart';
import 'orders_event.dart';
import 'orders_state.dart';

class OrdersBloc extends Bloc<OrdersEvent, OrdersState> {
  final List<OrderEntity> _orders = [];

  OrdersBloc() : super(const OrdersInitial()) {
    on<LoadOrdersReq>(_onLoadOrders);
    on<PlaceOrderReq>(_onPlaceOrder);
    on<CancelOrderReq>(_onCancelOrder);
    on<UpdateOrderStatusReq>(_onUpdateOrderStatus);
    _initSampleOrders();
  }

  void _initSampleOrders() {
    _orders.addAll([
      OrderEntity(
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
        subtotal: 677.0,
        tax: 33.85,
        deliveryFee: 0.0,
        total: 710.85,
        status: OrderStatus.onTheWay,
        orderDate: DateTime.now().subtract(const Duration(minutes: 25)),
        deliveryAddress: 'Flat 402, Sunshine Apartments, 12th Cross Road',
        deliveryNotes: 'Please ring doorbell twice',
      ),
      OrderEntity(
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
    ]);
  }

  void _onLoadOrders(LoadOrdersReq event, Emitter<OrdersState> emit) {
    emit(OrdersLoaded(orders: List.unmodifiable(_orders)));
  }

  void _onPlaceOrder(PlaceOrderReq event, Emitter<OrdersState> emit) {
    final randomId = 'YUM-${1000 + Random().nextInt(9000)}';
    final newOrder = OrderEntity(
      orderId: randomId,
      items: List.from(event.items),
      subtotal: event.subtotal,
      tax: event.tax,
      deliveryFee: event.deliveryFee,
      total: event.total,
      status: OrderStatus.placed,
      orderDate: DateTime.now(),
      deliveryAddress: event.deliveryAddress,
      deliveryNotes: event.deliveryNotes,
    );

    _orders.insert(0, newOrder);
    emit(
      OrdersLoaded(
        orders: List.unmodifiable(_orders),
        latestPlacedOrder: newOrder,
      ),
    );
  }

  void _onCancelOrder(CancelOrderReq event, Emitter<OrdersState> emit) {
    final index = _orders.indexWhere((o) => o.orderId == event.orderId);
    if (index >= 0) {
      final updated = _orders[index].copyWith(
        status: OrderStatus.cancelled,
        cancellationReason: event.reason,
      );
      _orders[index] = updated;
      emit(OrdersLoaded(orders: List.unmodifiable(_orders)));
    }
  }

  void _onUpdateOrderStatus(
    UpdateOrderStatusReq event,
    Emitter<OrdersState> emit,
  ) {
    final index = _orders.indexWhere((o) => o.orderId == event.orderId);
    if (index >= 0) {
      final updated = _orders[index].copyWith(status: event.status);
      _orders[index] = updated;
      emit(OrdersLoaded(orders: List.unmodifiable(_orders)));
    }
  }
}
