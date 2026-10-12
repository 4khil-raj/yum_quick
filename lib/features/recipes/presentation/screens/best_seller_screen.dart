import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:yum_quick/core/constants/app_assets.dart';
import 'package:yum_quick/core/constants/app_colors.dart';
import 'package:yum_quick/core/presentation/components/food_card.dart';
import 'package:yum_quick/core/presentation/components/offline_banner.dart';
import 'package:yum_quick/core/utils/app_snackbar.dart';
import 'package:yum_quick/features/cart/domain/entities/cart_item_entity.dart';
import 'package:yum_quick/features/cart/presentation/bloc/cart_bloc.dart';
import 'package:yum_quick/features/cart/presentation/bloc/cart_event.dart';
import 'package:yum_quick/features/cart/presentation/bloc/cart_state.dart';
import 'package:yum_quick/features/recipes/domain/entities/recipe_entity.dart';
import 'package:yum_quick/features/recipes/presentation/bloc/recipe_bloc.dart';
import 'package:yum_quick/features/recipes/presentation/bloc/recipe_event.dart';
import 'package:yum_quick/features/recipes/presentation/bloc/recipe_state.dart';

class BestSellerScreen extends StatefulWidget {
  const BestSellerScreen({super.key});

  @override
  State<BestSellerScreen> createState() => _BestSellerScreenState();
}

class _BestSellerScreenState extends State<BestSellerScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.hasClients &&
        _scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 250) {
      final recipeState = context.read<RecipeBloc>().state;
      if (recipeState is RecipeSuccess &&
          recipeState.hasMore &&
          !recipeState.isLoadingMore) {
        context.read<RecipeBloc>().add(const LoadMoreRecipesReq());
      }
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryYellow,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const OfflineBanner(),
            Container(
              padding: const EdgeInsets.only(
                top: 8,
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
                      final bestSellers = List<RecipeEntity>.from(
                        state.recipes,
                      )..sort((a, b) => b.reviewCount.compareTo(a.reviewCount));

                      return CustomScrollView(
                        controller: _scrollController,
                        physics: const BouncingScrollPhysics(
                          parent: AlwaysScrollableScrollPhysics(),
                        ),
                        slivers: [
                          SliverPadding(
                            padding: const EdgeInsets.all(16),
                            sliver: SliverGrid(
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 0.72,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 14,
                              ),
                              delegate: SliverChildBuilderDelegate(
                                (context, index) {
                                  final recipe = bestSellers[index];
                                  final isFav =
                                      state.favoriteIds.contains(recipe.id);

                                  return FoodCard(
                                    recipe: recipe,
                                    isFavorite: isFav,
                                    onTap: () => context.push(
                                      '/recipe-detail',
                                      extra: recipe,
                                    ),
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
                                      AppSnackBar.showSuccess(
                                        context,
                                        message: 'Added to cart!',
                                      );
                                    },
                                  );
                                },
                                childCount: bestSellers.length,
                              ),
                            ),
                          ),
                          if (state.isLoadingMore)
                            const SliverToBoxAdapter(
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 20),
                                child: Center(
                                  child: SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      color: AppColors.primaryOrange,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          if (!state.hasMore && bestSellers.isNotEmpty)
                            const SliverToBoxAdapter(
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 20),
                                child: Center(
                                  child: Text(
                                    "You've viewed all best sellers",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textMuted,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
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
    ),
  );
}
}
