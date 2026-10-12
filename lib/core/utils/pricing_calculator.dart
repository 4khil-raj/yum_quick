class PricingCalculator {
  PricingCalculator._();

  static double priceForRecipe(int id) {
    return 99.0 + ((id * 37) % 401);
  }

  static String formatINR(double amount) {
    if (amount % 1 == 0) {
      return '₹${amount.toInt()}';
    }
    return '₹${amount.toStringAsFixed(2)}';
  }

  static const double taxRate = 0.05;

  static const double standardDeliveryFee = 40.0;
  static const double freeDeliveryThreshold = 500.0;

  static const double standardServiceFee = 15.0;

  static double calculateTax(double subtotal) {
    if (subtotal <= 0) return 0.0;
    return double.parse((subtotal * taxRate).toStringAsFixed(2));
  }

  static double calculateDeliveryFee(double subtotal) {
    if (subtotal <= 0) return 0.0;
    if (subtotal >= freeDeliveryThreshold) return 0.0;
    return standardDeliveryFee;
  }

  static double calculateServiceFee(double subtotal) {
    if (subtotal <= 0) return 0.0;
    return standardServiceFee;
  }

  static double calculateDiscount(double subtotal, {String? promoCode}) {
    if (subtotal <= 0 || promoCode == null) return 0.0;
    final code = promoCode.trim().toUpperCase();
    if (code == 'YUM10' || code == 'BICTREE10') {
      return double.parse((subtotal * 0.10).toStringAsFixed(2));
    }
    if (code == 'YUM20' || code == 'WELCOME20') {
      return double.parse((subtotal * 0.20).toStringAsFixed(2));
    }
    return 0.0;
  }

  static double calculateTotal({
    required double subtotal,
    double discount = 0.0,
  }) {
    if (subtotal <= 0) return 0.0;
    final tax = calculateTax(subtotal);
    final delivery = calculateDeliveryFee(subtotal);
    final service = calculateServiceFee(subtotal);
    final total = subtotal + tax + delivery + service - discount;
    return total < 0 ? 0.0 : double.parse(total.toStringAsFixed(2));
  }
}
