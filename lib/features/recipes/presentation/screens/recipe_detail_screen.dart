import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:yum_quick/core/constants/app_assets.dart';
import 'package:yum_quick/core/constants/app_colors.dart';
import 'package:yum_quick/core/presentation/components/offline_banner.dart';
import 'package:yum_quick/core/presentation/components/quantity_control.dart';
import 'package:yum_quick/core/utils/app_snackbar.dart';
import 'package:yum_quick/core/utils/pricing_calculator.dart';
import 'package:yum_quick/features/cart/domain/entities/cart_item_entity.dart';
import 'package:yum_quick/features/cart/presentation/bloc/cart_bloc.dart';
import 'package:yum_quick/features/cart/presentation/bloc/cart_event.dart';
import 'package:yum_quick/features/recipes/domain/entities/recipe_entity.dart';
import 'package:yum_quick/features/recipes/presentation/bloc/recipe_bloc.dart';
import 'package:yum_quick/features/recipes/presentation/bloc/recipe_event.dart';
import 'package:yum_quick/features/recipes/presentation/bloc/recipe_state.dart';

import '../widgets/recipe_addon_list.dart';
import '../widgets/recipe_bottom_bar.dart';
import '../widgets/recipe_info_chips.dart';

class RecipeDetailScreen extends StatefulWidget {
  final RecipeEntity recipe;

  const RecipeDetailScreen({super.key, required this.recipe});

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  int _quantity = 1;
  final Set<String> _selectedAddOns = {};

  final Map<String, double> _availableAddOns = {
    'Extra Gourmet Cheese': 35.0,
    'Crispy Herb Croutons': 25.0,
    'Creamy Garlic Dip': 20.0,
    'Spicy Peri-Peri Glaze': 30.0,
  };

  double get _addOnsTotal {
    double total = 0.0;
    for (final addOn in _selectedAddOns) {
      total += _availableAddOns[addOn] ?? 0.0;
    }
    return total;
  }

  double get _currentTotalPrice {
    return (widget.recipe.price + _addOnsTotal) * _quantity;
  }

  void _onAddToCart() {
    final cartItem = CartItemEntity(
      recipeId: widget.recipe.id,
      recipeName: widget.recipe.name,
      recipeImage: widget.recipe.image,
      unitPrice: widget.recipe.price,
      quantity: _quantity,
      selectedAddOns: _selectedAddOns.toList(),
      addOnsPrice: _addOnsTotal,
    );

    context.read<CartBloc>().add(AddToCartReq(cartItem));
    AppSnackBar.showSuccess(context, message: 'Added to cart!');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: BlocBuilder<RecipeBloc, RecipeState>(
        builder: (context, state) {
          final isFavorite =
              state is RecipeSuccess &&
              state.favoriteIds.contains(widget.recipe.id);

          return Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 110),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      children: [
                        Hero(
                          tag: 'recipe_image_${widget.recipe.id}',
                          child: CachedNetworkImage(
                            imageUrl: widget.recipe.image,
                            height: 320,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              height: 320,
                              color: AppColors.surfaceSoft,
                            ),
                            errorWidget: (context, url, error) => Container(
                              height: 320,
                              color: AppColors.surfaceSoft,
                              child: const Icon(
                                Icons.restaurant,
                                size: 64,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ),
                        ),
                        Container(
                          height: 100,
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Colors.black54, Colors.transparent],
                            ),
                          ),
                        ),
                        SafeArea(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _buildCircularNavButton(
                                  iconPath: AppAssets.icArrowBack,
                                  onTap: () => context.pop(),
                                ),
                                _buildCircularNavButton(
                                  iconPath: AppAssets.icFavorite,
                                  iconColor: isFavorite
                                      ? AppColors.error
                                      : AppColors.textPrimary,
                                  onTap: () {
                                    context.read<RecipeBloc>().add(
                                      ToggleFavoriteReq(widget.recipe.id),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    Transform.translate(
                      offset: const Offset(0, -24),
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(32),
                          ),
                        ),
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(
                                    widget.recipe.name,
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  PricingCalculator.formatINR(
                                    widget.recipe.price,
                                  ),
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.primaryOrange,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            RecipeDetailInfoRow(
                              rating: widget.recipe.rating,
                              reviewCount: widget.recipe.reviewCount,
                              totalTimeMinutes: widget.recipe.totalTimeMinutes,
                              caloriesPerServing:
                                  widget.recipe.caloriesPerServing,
                            ),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Quantity',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                QuantityControl(
                                  quantity: _quantity,
                                  onQuantityChanged: (q) =>
                                      setState(() => _quantity = q),
                                ),
                              ],
                            ),
                            const Divider(height: 36),
                            const Text(
                              'Ingredients',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: widget.recipe.ingredients.map((
                                ingredient,
                              ) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.surfaceSoft,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: AppColors.border),
                                  ),
                                  child: Text(
                                    ingredient,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                            const Divider(height: 36),
                            RecipeAddOnList(
                              availableAddOns: _availableAddOns,
                              selectedAddOns: _selectedAddOns,
                              onAddOnToggled: (addOn, isSelected) {
                                setState(() {
                                  if (isSelected) {
                                    _selectedAddOns.add(addOn);
                                  } else {
                                    _selectedAddOns.remove(addOn);
                                  }
                                });
                              },
                            ),
                            const Divider(height: 36),
                            const Text(
                              'Preparation Instructions',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 12),
                            ...widget.recipe.instructions.asMap().entries.map((
                              step,
                            ) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: 24,
                                      height: 24,
                                      decoration: const BoxDecoration(
                                        color: AppColors.chipOrangeTint,
                                        shape: BoxShape.circle,
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        '${step.key + 1}',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w800,
                                          color: AppColors.primaryOrange,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        step.value,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: AppColors.textSecondary,
                                          height: 1.4,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: RecipeBottomBar(
                  totalPrice: _currentTotalPrice,
                  onAddToCart: _onAddToCart,
                ),
              ),
              const Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: OfflineBanner(),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCircularNavButton({
    required String iconPath,
    required VoidCallback onTap,
    Color? iconColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.9),
          shape: BoxShape.circle,
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(10),
        child: Image.asset(
          iconPath,
          color: iconColor ?? AppColors.textPrimary,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
