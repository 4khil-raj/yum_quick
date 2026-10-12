import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yum_quick/features/cart/domain/entities/cart_item_entity.dart';
import 'package:yum_quick/features/orders/domain/entities/order_entity.dart';
import 'package:yum_quick/features/orders/presentation/widgets/order_card.dart';

void main() {
  testWidgets('OrderCard renders all ordered items accurately with quantities', (
    WidgetTester tester,
  ) async {
    final testOrder = OrderEntity(
      orderId: 'YUM-9999',
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
      subtotal: 707.0,
      tax: 35.35,
      deliveryFee: 0.0,
      total: 742.35,
      status: OrderStatus.onTheWay,
      orderDate: DateTime(2026, 10, 12, 14, 30),
      deliveryAddress: 'Flat 402, Sunshine Apartments',
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: OrderCard(order: testOrder),
          ),
        ),
      ),
    );

    await tester.pump();

    expect(find.text('#YUM-9999'), findsOneWidget);
    expect(find.text('On the Way'), findsOneWidget);
    expect(find.text('Classic Margherita Pizza'), findsOneWidget);
    expect(find.text('Chocolate Lava Cake'), findsOneWidget);
    expect(find.text('2x'), findsOneWidget);
    expect(find.text('1x'), findsOneWidget);
    expect(find.text('+ Extra Cheese'), findsOneWidget);
    expect(find.text('3 items'), findsOneWidget);
    expect(find.textContaining('742.35'), findsOneWidget);
  });
}
