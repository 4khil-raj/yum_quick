import 'package:equatable/equatable.dart';

class CartItemEntity extends Equatable {
  final int recipeId;
  final String recipeName;
  final String recipeImage;
  final double unitPrice;
  final int quantity;
  final List<String> selectedAddOns;
  final double addOnsPrice;

  const CartItemEntity({
    required this.recipeId,
    required this.recipeName,
    required this.recipeImage,
    required this.unitPrice,
    required this.quantity,
    this.selectedAddOns = const [],
    this.addOnsPrice = 0.0,
  });

  double get itemUnitPrice => unitPrice + addOnsPrice;
  double get totalPrice => itemUnitPrice * quantity;

  CartItemEntity copyWith({
    int? recipeId,
    String? recipeName,
    String? recipeImage,
    double? unitPrice,
    int? quantity,
    List<String>? selectedAddOns,
    double? addOnsPrice,
  }) {
    return CartItemEntity(
      recipeId: recipeId ?? this.recipeId,
      recipeName: recipeName ?? this.recipeName,
      recipeImage: recipeImage ?? this.recipeImage,
      unitPrice: unitPrice ?? this.unitPrice,
      quantity: quantity ?? this.quantity,
      selectedAddOns: selectedAddOns ?? this.selectedAddOns,
      addOnsPrice: addOnsPrice ?? this.addOnsPrice,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'recipeId': recipeId,
      'recipeName': recipeName,
      'recipeImage': recipeImage,
      'unitPrice': unitPrice,
      'quantity': quantity,
      'selectedAddOns': selectedAddOns,
      'addOnsPrice': addOnsPrice,
    };
  }

  factory CartItemEntity.fromJson(Map<String, dynamic> json) {
    return CartItemEntity(
      recipeId: json['recipeId'] as int? ?? 0,
      recipeName: json['recipeName'] as String? ?? '',
      recipeImage: json['recipeImage'] as String? ?? '',
      unitPrice: (json['unitPrice'] as num?)?.toDouble() ?? 99.0,
      quantity: json['quantity'] as int? ?? 1,
      selectedAddOns:
          (json['selectedAddOns'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      addOnsPrice: (json['addOnsPrice'] as num?)?.toDouble() ?? 0.0,
    );
  }

  @override
  List<Object?> get props => [
    recipeId,
    recipeName,
    recipeImage,
    unitPrice,
    quantity,
    selectedAddOns,
    addOnsPrice,
  ];
}
