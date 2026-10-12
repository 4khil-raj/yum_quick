import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:yum_quick/features/cart/domain/entities/cart_item_entity.dart';
import 'package:yum_quick/features/cart/domain/repositories/cart_repository.dart';
import 'package:yum_quick/features/cart/presentation/bloc/cart_bloc.dart';
import 'package:yum_quick/features/cart/presentation/bloc/cart_event.dart';
import 'package:yum_quick/features/cart/presentation/bloc/cart_state.dart';

class MockCartRepository extends Mock implements CartRepository {}

void main() {
  late MockCartRepository mockCartRepository;
  late CartBloc cartBloc;

  const testItem1 = CartItemEntity(
    recipeId: 1,
    recipeName: 'Margherita Pizza',
    recipeImage: 'https://example.com/pizza.jpg',
    unitPrice: 200.0,
    quantity: 1,
  );

  const testItem2 = CartItemEntity(
    recipeId: 2,
    recipeName: 'Brownie',
    recipeImage: 'https://example.com/brownie.jpg',
    unitPrice: 150.0,
    quantity: 2,
  );

  setUp(() {
    mockCartRepository = MockCartRepository();
    when(() => mockCartRepository.saveCartItems(any())).thenAnswer((_) async {});
    when(() => mockCartRepository.clearCart()).thenAnswer((_) async {});
    cartBloc = CartBloc(cartRepository: mockCartRepository);
  });

  tearDown(() {
    cartBloc.close();
  });

  test('Initial state is CartInitial', () {
    expect(cartBloc.state, isA<CartInitial>());
  });

  test('LoadCartReq emits CartEmpty when repository returns empty list', () async {
    when(() => mockCartRepository.getCartItems()).thenAnswer((_) async => []);

    cartBloc.add(const LoadCartReq());

    await expectLater(
      cartBloc.stream,
      emitsInOrder([
        isA<CartLoading>(),
        isA<CartEmpty>(),
      ]),
    );
  });

  test('LoadCartReq emits CartLoaded when repository returns items', () async {
    when(() => mockCartRepository.getCartItems())
        .thenAnswer((_) async => [testItem1, testItem2]);

    cartBloc.add(const LoadCartReq());

    await expectLater(
      cartBloc.stream,
      emitsInOrder([
        isA<CartLoading>(),
        predicate<CartLoaded>((state) {
          return state.items.length == 2 &&
              state.subtotal == 500.0 &&
              state.totalItemCount == 2 &&
              state.totalQuantity == 3;
        }),
      ]),
    );
  });

  test('AddToCartReq saves item and updates total calculations', () async {
    when(() => mockCartRepository.getCartItems()).thenAnswer((_) async => []);

    cartBloc.add(const AddToCartReq(testItem1));

    await expectLater(
      cartBloc.stream,
      emits(
        predicate<CartLoaded>((state) {
          return state.items.length == 1 &&
              state.items.first.recipeId == 1 &&
              state.subtotal == 200.0;
        }),
      ),
    );
    verify(() => mockCartRepository.saveCartItems(any())).called(1);
  });

  test('UpdateCartQuantityReq updates quantity and saves to repository', () async {
    when(() => mockCartRepository.getCartItems()).thenAnswer((_) async => []);

    cartBloc.add(const AddToCartReq(testItem1));
    await expectLater(cartBloc.stream, emitsThrough(isA<CartLoaded>()));

    cartBloc.add(const UpdateCartQuantityReq(recipeId: 1, quantity: 3));

    await expectLater(
      cartBloc.stream,
      emits(
        predicate<CartLoaded>((state) {
          return state.items.first.quantity == 3 &&
              state.subtotal == 600.0 &&
              state.deliveryFee == 0.0;
        }),
      ),
    );
  });

  test('RemoveFromCartReq removes item and sets recentlyRemovedItem for undo', () async {
    when(() => mockCartRepository.getCartItems()).thenAnswer((_) async => []);

    cartBloc.add(const AddToCartReq(testItem1));
    await expectLater(cartBloc.stream, emitsThrough(isA<CartLoaded>()));

    cartBloc.add(const RemoveFromCartReq(1));

    await expectLater(
      cartBloc.stream,
      emits(
        predicate<CartEmpty>((state) {
          return state.recentlyRemovedItem?.recipeId == 1;
        }),
      ),
    );
  });

  test('ApplyPromoCodeReq applies discount correctly', () async {
    when(() => mockCartRepository.getCartItems()).thenAnswer((_) async => []);

    cartBloc.add(const AddToCartReq(testItem1));
    await expectLater(cartBloc.stream, emitsThrough(isA<CartLoaded>()));

    cartBloc.add(const ApplyPromoCodeReq('YUM10'));

    await expectLater(
      cartBloc.stream,
      emits(
        predicate<CartLoaded>((state) {
          return state.promoCode == 'YUM10' &&
              state.discount == 20.0;
        }),
      ),
    );
  });

  test('ClearCartReq clears repository and emits CartEmpty', () async {
    when(() => mockCartRepository.getCartItems()).thenAnswer((_) async => []);

    cartBloc.add(const AddToCartReq(testItem1));
    await expectLater(cartBloc.stream, emitsThrough(isA<CartLoaded>()));

    cartBloc.add(const ClearCartReq());

    await expectLater(
      cartBloc.stream,
      emits(isA<CartEmpty>()),
    );
    verify(() => mockCartRepository.clearCart()).called(1);
  });
}
