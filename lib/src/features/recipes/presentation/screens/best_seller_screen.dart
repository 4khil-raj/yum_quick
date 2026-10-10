import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:yum_quick/src/core/constants/app_assets.dart';
import 'package:yum_quick/src/core/constants/app_colors.dart';
import 'package:yum_quick/src/core/presentation/components/curved_header.dart';
import 'package:yum_quick/src/core/presentation/components/food_card.dart';
import 'package:yum_quick/src/features/cart/domain/entities/cart_item_entity.dart';
import 'package:yum_quick/src/features/cart/state/cart_bloc.dart';
import 'package:yum_quick/src/features/cart/state/cart_event.dart';
import 'package:yum_quick/src/features/recipes/domain/entities/recipe_entity.dart';
import 'package:yum_quick/src/features/recipes/state/recipe_bloc.dart';
import 'package:yum_quick/src/features/recipes/state/recipe_event.dart';
import 'package:yum_quick/src/features/recipes/state/recipe_state.dart';

class BestSellerScreen extends StatelessWidget {
  const BestSellerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: Column(
        children: [
          CurvedHeader(
            leading: IconButton(
              icon: Image.asset(AppAssets.icArrowBack, width: 20, height: 20),
              onPressed: () => context.pop(),
            ),
            title: const Text(
              'Best Sellers',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Expanded(
            child: BlocBuilder<RecipeBloc, RecipeState>(
              builder: (context, state) {
                if (state is RecipeSuccess) {
                  // Sort by reviewCount or rating to get best sellers
                  final bestSellers = List<RecipeEntity>.from(state.recipes)
                    ..sort((a, b) => b.reviewCount.compareTo(a.reviewCount));

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
                              content: Text('Added ${recipe.name} to cart!'),
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
        ],
      ),
    );
  }
}
