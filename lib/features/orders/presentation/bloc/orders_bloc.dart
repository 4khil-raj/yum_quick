import 'dart:math';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/order_entity.dart';
import '../../domain/repositories/orders_repository.dart';
import 'orders_event.dart';
import 'orders_state.dart';

class OrdersBloc extends Bloc<OrdersEvent, OrdersState> {
  final OrdersRepository ordersRepository;

  OrdersBloc({required this.ordersRepository}) : super(const OrdersInitial()) {
    on<LoadOrdersReq>(_onLoadOrders);
    on<PlaceOrderReq>(_onPlaceOrder);
    on<CancelOrderReq>(_onCancelOrder);
    on<UpdateOrderStatusReq>(_onUpdateOrderStatus);
  }

  Future<void> _onLoadOrders(
    LoadOrdersReq event,
    Emitter<OrdersState> emit,
  ) async {
    emit(const OrdersLoading());
    try {
      final orders = await ordersRepository.getOrders();
      emit(OrdersLoaded(orders: List.unmodifiable(orders)));
    } catch (e) {
      emit(OrdersError(e.toString()));
    }
  }

  Future<void> _onPlaceOrder(
    PlaceOrderReq event,
    Emitter<OrdersState> emit,
  ) async {
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

    try {
      await ordersRepository.placeOrder(newOrder);
      final updatedOrders = await ordersRepository.getOrders();
      emit(
        OrdersLoaded(
          orders: List.unmodifiable(updatedOrders),
          latestPlacedOrder: newOrder,
        ),
      );
    } catch (e) {
      emit(OrdersError(e.toString()));
    }
  }

  Future<void> _onCancelOrder(
    CancelOrderReq event,
    Emitter<OrdersState> emit,
  ) async {
    try {
      await ordersRepository.cancelOrder(event.orderId, event.reason);
      final updatedOrders = await ordersRepository.getOrders();
      emit(OrdersLoaded(orders: List.unmodifiable(updatedOrders)));
    } catch (e) {
      emit(OrdersError(e.toString()));
    }
  }

  Future<void> _onUpdateOrderStatus(
    UpdateOrderStatusReq event,
    Emitter<OrdersState> emit,
  ) async {
    try {
      await ordersRepository.updateOrderStatus(event.orderId, event.status);
      final updatedOrders = await ordersRepository.getOrders();
      emit(OrdersLoaded(orders: List.unmodifiable(updatedOrders)));
    } catch (e) {
      emit(OrdersError(e.toString()));
    }
  }
}
