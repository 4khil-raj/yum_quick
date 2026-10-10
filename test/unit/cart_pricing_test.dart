import 'package:flutter_test/flutter_test.dart';
import 'package:yum_quick/src/core/utils/pricing_calculator.dart';
import 'package:yum_quick/src/features/cart/domain/entities/cart_item_entity.dart';

void main() {
  group('PricingCalculator Tests', () {
    test(
      'priceForRecipe generates deterministic prices between ₹99 and ₹499',
      () {
        final p1 = PricingCalculator.priceForRecipe(1);
        final p2 = PricingCalculator.priceForRecipe(1);
        final p10 = PricingCalculator.priceForRecipe(10);

        expect(p1, equals(p2)); // Deterministic
        expect(p1, greaterThanOrEqualTo(99.0));
        expect(p1, lessThanOrEqualTo(499.0));
        expect(p10, greaterThanOrEqualTo(99.0));
        expect(p10, lessThanOrEqualTo(499.0));
      },
    );

    test('formatINR formats currency properly', () {
      expect(PricingCalculator.formatINR(249.0), equals('₹249'));
      expect(PricingCalculator.formatINR(249.50), equals('₹249.50'));
    });

    test('calculateTax computes 5% GST', () {
      expect(PricingCalculator.calculateTax(100.0), equals(5.0));
      expect(PricingCalculator.calculateTax(200.0), equals(10.0));
      expect(PricingCalculator.calculateTax(0.0), equals(0.0));
    });

    test('calculateDeliveryFee is free for orders >= ₹500 and ₹40 below', () {
      expect(PricingCalculator.calculateDeliveryFee(250.0), equals(40.0));
      expect(PricingCalculator.calculateDeliveryFee(500.0), equals(0.0));
      expect(PricingCalculator.calculateDeliveryFee(750.0), equals(0.0));
      expect(PricingCalculator.calculateDeliveryFee(0.0), equals(0.0));
    });

    test('calculateServiceFee is ₹15 when subtotal > 0', () {
      expect(PricingCalculator.calculateServiceFee(100.0), equals(15.0));
      expect(PricingCalculator.calculateServiceFee(0.0), equals(0.0));
    });

    test('calculateDiscount applies promo codes correctly', () {
      expect(
        PricingCalculator.calculateDiscount(200.0, promoCode: 'YUM10'),
        equals(20.0),
      );
      expect(
        PricingCalculator.calculateDiscount(200.0, promoCode: 'YUM20'),
        equals(40.0),
      );
      expect(
        PricingCalculator.calculateDiscount(200.0, promoCode: 'INVALID'),
        equals(0.0),
      );
      expect(
        PricingCalculator.calculateDiscount(0.0, promoCode: 'YUM20'),
        equals(0.0),
      );
    });

    test('calculateTotal sums subtotal, tax, fees, and subtracts discount', () {
      // Subtotal = 200, Tax = 10, Delivery = 40, Service = 15, Discount = 0 -> 265
      final totalNoDiscount = PricingCalculator.calculateTotal(subtotal: 200.0);
      expect(totalNoDiscount, equals(265.0));

      // With 20 discount -> 245
      final totalWithDiscount = PricingCalculator.calculateTotal(
        subtotal: 200.0,
        discount: 20.0,
      );
      expect(totalWithDiscount, equals(245.0));

      // Subtotal = 600 (Free delivery), Tax = 30, Delivery = 0, Service = 15 -> 645
      final totalFreeDelivery = PricingCalculator.calculateTotal(
        subtotal: 600.0,
      );
      expect(totalFreeDelivery, equals(645.0));
    });
  });

  group('CartItemEntity Calculations', () {
    test('calculates item total price including add-ons and quantity', () {
      const item = CartItemEntity(
        recipeId: 1,
        recipeName: 'Margherita Pizza',
        recipeImage: 'https://example.com/pizza.jpg',
        unitPrice: 200.0,
        quantity: 2,
        selectedAddOns: ['Extra Cheese'],
        addOnsPrice: 30.0,
      );

      expect(item.itemUnitPrice, equals(230.0));
      expect(item.totalPrice, equals(460.0));
    });

    test('adding quantity updates item correctly', () {
      const item = CartItemEntity(
        recipeId: 1,
        recipeName: 'Margherita Pizza',
        recipeImage: 'https://example.com/pizza.jpg',
        unitPrice: 200.0,
        quantity: 1,
      );

      final updated = item.copyWith(quantity: 3);
      expect(updated.quantity, equals(3));
      expect(updated.totalPrice, equals(600.0));
    });
  });
}
