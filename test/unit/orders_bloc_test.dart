import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:yum_quick/src/features/cart/domain/entities/cart_item_entity.dart';
import 'package:yum_quick/src/features/orders/domain/entities/order_entity.dart';
import 'package:yum_quick/src/features/orders/domain/repositories/orders_repository.dart';
import 'package:yum_quick/src/features/orders/presentation/bloc/orders_bloc.dart';
import 'package:yum_quick/src/features/orders/presentation/bloc/orders_event.dart';
import 'package:yum_quick/src/features/orders/presentation/bloc/orders_state.dart';

class MockOrdersRepository extends Mock implements OrdersRepository {}

void main() {
  late MockOrdersRepository mockOrdersRepository;
  late OrdersBloc ordersBloc;

  final testOrder = OrderEntity(
    orderId: 'YUM-1001',
    items: const [
      CartItemEntity(
        recipeId: 1,
        recipeName: 'Margherita Pizza',
        recipeImage: 'https://example.com/pizza.jpg',
        unitPrice: 200.0,
        quantity: 1,
      ),
    ],
    subtotal: 200.0,
    tax: 10.0,
    deliveryFee: 40.0,
    total: 250.0,
    status: OrderStatus.placed,
    orderDate: DateTime.now(),
    deliveryAddress: '123 Baker Street',
  );

  setUpAll(() {
    registerFallbackValue(testOrder);
  });

  setUp(() {
    mockOrdersRepository = MockOrdersRepository();
    ordersBloc = OrdersBloc(ordersRepository: mockOrdersRepository);
  });

  tearDown(() {
    ordersBloc.close();
  });

  test('Initial state is OrdersInitial', () {
    expect(ordersBloc.state, isA<OrdersInitial>());
  });

  test('LoadOrdersReq loads orders from repository and emits OrdersLoaded', () async {
    when(() => mockOrdersRepository.getOrders())
        .thenAnswer((_) async => [testOrder]);

    ordersBloc.add(const LoadOrdersReq());

    await expectLater(
      ordersBloc.stream,
      emitsInOrder([
        isA<OrdersLoading>(),
        predicate<OrdersLoaded>((state) => state.orders.length == 1 && state.orders.first.orderId == 'YUM-1001'),
      ]),
    );
  });

  test('PlaceOrderReq saves new order and emits OrdersLoaded with latestPlacedOrder', () async {
    when(() => mockOrdersRepository.placeOrder(any()))
        .thenAnswer((_) async => testOrder);
    when(() => mockOrdersRepository.getOrders())
        .thenAnswer((_) async => [testOrder]);

    ordersBloc.add(
      PlaceOrderReq(
        items: testOrder.items,
        subtotal: testOrder.subtotal,
        tax: testOrder.tax,
        deliveryFee: testOrder.deliveryFee,
        total: testOrder.total,
        deliveryAddress: testOrder.deliveryAddress,
      ),
    );

    await expectLater(
      ordersBloc.stream,
      emits(
        predicate<OrdersLoaded>(
          (state) => state.orders.isNotEmpty && state.latestPlacedOrder != null,
        ),
      ),
    );
    verify(() => mockOrdersRepository.placeOrder(any())).called(1);
  });

  test('CancelOrderReq calls repository and updates order status', () async {
    final cancelledOrder = testOrder.copyWith(
      status: OrderStatus.cancelled,
      cancellationReason: 'Changed mind',
    );
    when(() => mockOrdersRepository.cancelOrder('YUM-1001', 'Changed mind'))
        .thenAnswer((_) async => cancelledOrder);
    when(() => mockOrdersRepository.getOrders())
        .thenAnswer((_) async => [cancelledOrder]);

    ordersBloc.add(
      const CancelOrderReq(orderId: 'YUM-1001', reason: 'Changed mind'),
    );

    await expectLater(
      ordersBloc.stream,
      emits(
        predicate<OrdersLoaded>(
          (state) => state.orders.first.status == OrderStatus.cancelled,
        ),
      ),
    );
    verify(() => mockOrdersRepository.cancelOrder('YUM-1001', 'Changed mind')).called(1);
  });
}
