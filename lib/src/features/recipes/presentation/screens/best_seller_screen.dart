import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:yum_quick/src/core/constants/app_assets.dart';
import 'package:yum_quick/src/core/constants/app_colors.dart';
import 'package:yum_quick/src/core/presentation/components/food_card.dart';
import 'package:yum_quick/src/features/cart/domain/entities/cart_item_entity.dart';
import 'package:yum_quick/src/features/cart/state/cart_bloc.dart';
import 'package:yum_quick/src/features/cart/state/cart_event.dart';
import 'package:yum_quick/src/features/cart/state/cart_state.dart';
import 'package:yum_quick/src/features/recipes/domain/entities/recipe_entity.dart';
import 'package:yum_quick/src/features/recipes/state/recipe_bloc.dart';
import 'package:yum_quick/src/features/recipes/state/recipe_event.dart';
import 'package:yum_quick/src/features/recipes/state/recipe_state.dart';

class BestSellerScreen extends StatelessWidget {
  const BestSellerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: AppColors.primaryYellow,
      body: Column(
        children: [
          // Yellow Header matching Figma
          Container(
            padding: EdgeInsets.only(
              top: topPadding + 8,
              bottom: 16,
              left: 16,
              right: 16,
            ),
            child: Row(
              children: [
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => context.pop(),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    child: const Icon(
                      Icons.chevron_left_rounded,
                      size: 28,
                      color: AppColors.primaryOrange,
                    ),
                  ),
                ),
                const Expanded(
                  child: Center(
                    child: Text(
                      'Best Seller',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ),
                // Cart Action
                BlocBuilder<CartBloc, CartState>(
                  builder: (context, cartState) {
                    final count = cartState is CartLoaded
                        ? cartState.totalItemCount
                        : 0;
                    return GestureDetector(
                      onTap: () => context.push('/cart'),
                      child: Container(
                        width: 38,
                        height: 38,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Image.asset(
                              AppAssets.icCart,
                              width: 18,
                              height: 18,
                              color: AppColors.primaryOrange,
                            ),
                            if (count > 0)
                              Positioned(
                                top: 4,
                                right: 4,
                                child: Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: AppColors.primaryOrange,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(width: 8),
                // Profile Action
                GestureDetector(
                  onTap: () => context.push('/profile'),
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(9),
                    child: Image.asset(
                      AppAssets.icProfile,
                      width: 18,
                      height: 18,
                      color: AppColors.primaryOrange,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // White Content Area
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(36)),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(36),
                ),
                child: BlocBuilder<RecipeBloc, RecipeState>(
                  builder: (context, state) {
                    if (state is RecipeSuccess) {
                      // Sort by reviewCount or rating to get best sellers
                      final bestSellers = List<RecipeEntity>.from(
                        state.recipes,
                      )..sort((a, b) => b.reviewCount.compareTo(a.reviewCount));

                      return GridView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: bestSellers.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 0.72,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 14,
                            ),
                        itemBuilder: (context, index) {
                          final recipe = bestSellers[index];
                          final isFav = state.favoriteIds.contains(recipe.id);

                          return FoodCard(
                            recipe: recipe,
                            isFavorite: isFav,
                            onTap: () =>
                                context.push('/recipe-detail', extra: recipe),
                            onFavoriteTap: () {
                              context.read<RecipeBloc>().add(
                                ToggleFavoriteReq(recipe.id),
                              );
                            },
                            onAddToCart: () {
                              context.read<CartBloc>().add(
                                AddToCartReq(
                                  CartItemEntity(
                                    recipeId: recipe.id,
                                    recipeName: recipe.name,
                                    recipeImage: recipe.image,
                                    unitPrice: recipe.price,
                                    quantity: 1,
                                  ),
                                ),
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Added ${recipe.name} to cart!',
                                  ),
                                  backgroundColor: AppColors.primaryOrange,
                                  duration: const Duration(seconds: 1),
                                ),
                              );
                            },
                          );
                        },
                      );
                    }
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primaryOrange,
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
