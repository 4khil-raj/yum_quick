import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:yum_quick/src/features/cart/domain/entities/cart_item_entity.dart';
import 'package:yum_quick/src/features/orders/data/datasources/orders_local_data_source.dart';
import 'package:yum_quick/src/features/orders/data/models/order_model.dart';
import 'package:yum_quick/src/features/orders/data/repositories/orders_repository_impl.dart';
import 'package:yum_quick/src/features/orders/domain/entities/order_entity.dart';

class MockOrdersLocalDataSource extends Mock implements OrdersLocalDataSource {}

void main() {
  late MockOrdersLocalDataSource mockLocalDataSource;
  late OrdersRepositoryImpl ordersRepository;

  final testOrderModel = OrderModel(
    orderId: 'YUM-5555',
    items: const [
      CartItemEntity(
        recipeId: 10,
        recipeName: 'Biryani',
        recipeImage: 'https://example.com/biryani.jpg',
        unitPrice: 280.0,
        quantity: 1,
      ),
    ],
    subtotal: 280.0,
    tax: 14.0,
    deliveryFee: 40.0,
    total: 334.0,
    status: OrderStatus.placed,
    orderDate: DateTime.now(),
    deliveryAddress: 'Street 4, Sector 7',
  );

  setUpAll(() {
    registerFallbackValue(testOrderModel);
  });

  setUp(() {
    mockLocalDataSource = MockOrdersLocalDataSource();
    ordersRepository = OrdersRepositoryImpl(localDataSource: mockLocalDataSource);
  });

  test('getOrders delegates to localDataSource.getOrders', () async {
    when(() => mockLocalDataSource.getOrders())
        .thenAnswer((_) async => [testOrderModel]);

    final result = await ordersRepository.getOrders();

    expect(result.length, 1);
    expect(result.first.orderId, 'YUM-5555');
    verify(() => mockLocalDataSource.getOrders()).called(1);
  });

  test('placeOrder converts entity to model and saves in localDataSource', () async {
    when(() => mockLocalDataSource.saveOrder(any()))
        .thenAnswer((_) async => testOrderModel);

    final result = await ordersRepository.placeOrder(testOrderModel);

    expect(result.orderId, 'YUM-5555');
    verify(() => mockLocalDataSource.saveOrder(any())).called(1);
  });

  test('cancelOrder updates order with cancelled status', () async {
    when(() => mockLocalDataSource.getOrders())
        .thenAnswer((_) async => [testOrderModel]);
    when(() => mockLocalDataSource.updateOrder(any()))
        .thenAnswer((invocation) async => invocation.positionalArguments.first as OrderModel);

    final result = await ordersRepository.cancelOrder('YUM-5555', 'Delayed delivery');

    expect(result, isNotNull);
    expect(result!.status, OrderStatus.cancelled);
    expect(result.cancellationReason, 'Delayed delivery');
    verify(() => mockLocalDataSource.updateOrder(any())).called(1);
  });
}
