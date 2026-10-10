import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:yum_quick/src/core/constants/app_assets.dart';
import 'package:yum_quick/src/core/constants/app_colors.dart';
import 'package:yum_quick/src/core/presentation/components/curved_header.dart';
import 'package:yum_quick/src/core/presentation/components/empty_state_widget.dart';
import 'package:yum_quick/src/core/presentation/components/food_card.dart';
import 'package:yum_quick/src/core/presentation/components/offline_banner.dart';
import 'package:yum_quick/src/core/presentation/components/shimmer_loading.dart';
import 'package:yum_quick/src/core/utils/category_mapper.dart';
import 'package:yum_quick/src/features/cart/domain/entities/cart_item_entity.dart';
import 'package:yum_quick/src/features/cart/state/cart_bloc.dart';
import 'package:yum_quick/src/features/cart/state/cart_event.dart';
import 'package:yum_quick/src/features/recipes/domain/entities/recipe_entity.dart';
import 'package:yum_quick/src/features/recipes/state/recipe_bloc.dart';
import 'package:yum_quick/src/features/recipes/state/recipe_event.dart';
import 'package:yum_quick/src/features/recipes/state/recipe_state.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedServiceMode = 0; // 0: Delivery, 1: Takeaway, 2: Dine-in

  final List<Map<String, String>> _serviceModes = [
    {'title': 'Delivery', 'icon': AppAssets.icDelivery},
    {'title': 'Takeaway', 'icon': AppAssets.icTakeaway},
    {'title': 'Dine In', 'icon': AppAssets.icDineIn},
  ];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RecipeBloc, RecipeState>(
      builder: (context, state) {
        final isOffline = state is RecipeSuccess && state.isOfflineFallback;

        return Scaffold(
          backgroundColor: AppColors.backgroundLight,
          body: Column(
            children: [
              OfflineBanner(isOffline: isOffline),
              Expanded(
                child: RefreshIndicator(
                  color: AppColors.primaryOrange,
                  onRefresh: () async {
                    context.read<RecipeBloc>().add(const RefreshRecipesReq());
                  },
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Curved Yellow Header
                        _buildCurvedHeader(context),

                        const SizedBox(height: 18),

                        // Service Modes
                        _buildServiceModes(),

                        const SizedBox(height: 18),

                        // Promotional Banner
                        _buildPromoBanner(context),

                        const SizedBox(height: 22),

                        // Categories Horizontal List
                        _buildCategoriesSection(context, state),

                        const SizedBox(height: 24),

                        // Main Content based on state
                        if (state is RecipeLoading) ...[
                          _buildShimmerSection(),
                        ] else if (state is RecipeError) ...[
                          ErrorRetryWidget(
                            message: state.message,
                            onRetry: () {
                              context.read<RecipeBloc>().add(
                                const FetchRecipesReq(),
                              );
                            },
                          ),
                        ] else if (state is RecipeEmpty) ...[
                          EmptyStateWidget(
                            title: 'No Recipes Found',
                            message: 'No recipes match the selected category right now.',
                            buttonText: 'View All',
                            onButtonPressed: () {
                              context.read<RecipeBloc>().add(
                                const ChangeCategoryReq(RecipeCategory.all),
                              );
                            },
                          ),
                        ] else if (state is RecipeSuccess) ...[
                          _buildBestSellerSection(context, state),
                          const SizedBox(height: 24),
                          _buildRecommendedSection(context, state),
                          const SizedBox(height: 32),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCurvedHeader(BuildContext context) {
    return CurvedHeader(
      leading: Image.asset(
        AppAssets.logoOrange,
        width: 130,
        height: 38,
        fit: BoxFit.contain,
      ),
      actions: [
        IconButton(
          icon: Image.asset(
            AppAssets.icNotification,
            width: 24,
            height: 24,
            color: AppColors.textPrimary,
          ),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('No new notifications.')),
            );
          },
        ),
      ],
      child: Column(
        children: [
          // Location Selector
          Row(
            children: [
              Image.asset(
                AppAssets.icLocation,
                width: 16,
                height: 16,
                color: AppColors.primaryOrange,
              ),
              const SizedBox(width: 6),
              const Expanded(
                child: Text(
                  'Delivering to: Sunshine Apartments, Floor 4',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Image.asset(
                AppAssets.icChevronRight,
                width: 14,
                height: 14,
                color: AppColors.textSecondary,
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Search Bar Shortcut
          GestureDetector(
            onTap: () => context.push('/menu'),
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                    color: AppColors.shadow,
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Image.asset(
                    AppAssets.icSearchPlus,
                    width: 18,
                    height: 18,
                    color: AppColors.textMuted,
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'Search dishes, ingredients or cuisines...',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ),
                  Image.asset(
                    AppAssets.icMic,
                    width: 18,
                    height: 18,
                    color: AppColors.primaryOrange,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceModes() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: List.generate(_serviceModes.length, (index) {
          final isSelected = _selectedServiceMode == index;
          final mode = _serviceModes[index];
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedServiceMode = index),
              child: Container(
                margin: EdgeInsets.only(
                  right: index < _serviceModes.length - 1 ? 10 : 0,
                ),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primaryOrange
                      : AppColors.surfaceSoft,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primaryOrange
                        : AppColors.border,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      mode['icon']!,
                      width: 16,
                      height: 16,
                      color: isSelected
                          ? Colors.white
                          : AppColors.textSecondary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      mode['title']!,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: isSelected
                            ? Colors.white
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildPromoBanner(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFE95421), Color(0xFFFF7A45)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(22),
          boxShadow: const [
            BoxShadow(
              color: Color(0x33E95421),
              blurRadius: 12,
              offset: Offset(0, 6),
            ),
          ],
        ),
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'LIMITED OFFER',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Grab 20% OFF\non your first meal!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Use promo code: YUM20',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Image.asset(
              AppAssets.icDiscount,
              width: 58,
              height: 58,
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoriesSection(BuildContext context, RecipeState state) {
    final currentCat = state is RecipeSuccess
        ? state.category
        : (state is RecipeLoading ? state.category : RecipeCategory.all);

    final categories = RecipeCategory.values;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Categories',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 90,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final cat = categories[index];
              final isSelected = currentCat == cat;

              return GestureDetector(
                onTap: () {
                  context.read<RecipeBloc>().add(ChangeCategoryReq(cat));
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 5),
                  child: Column(
                    children: [
                      Container(
                        width: 58,
                        height: 58,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primaryOrange
                              : AppColors.surfaceSoft,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primaryOrange
                                : AppColors.border,
                            width: 1.5,
                          ),
                          boxShadow: isSelected
                              ? const [
                                  BoxShadow(
                                    color: Color(0x33E95421),
                                    blurRadius: 8,
                                    offset: Offset(0, 3),
                                  ),
                                ]
                              : null,
                        ),
                        padding: const EdgeInsets.all(14),
                        child: cat == RecipeCategory.all
                            ? Icon(
                                Icons.restaurant_menu_rounded,
                                color: isSelected
                                    ? Colors.white
                                    : AppColors.textSecondary,
                                size: 24,
                              )
                            : Image.asset(
                                cat.iconPath,
                                color: isSelected
                                    ? Colors.white
                                    : AppColors.primaryOrange,
                                fit: BoxFit.contain,
                              ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        cat.label,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: isSelected
                              ? FontWeight.w700
                              : FontWeight.w500,
                          color: isSelected
                              ? AppColors.primaryOrange
                              : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBestSellerSection(BuildContext context, RecipeSuccess state) {
    final bestSellers = state.recipes.take(5).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Best Seller',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              GestureDetector(
                onTap: () => context.push('/best-seller'),
                child: const Text(
                  'View All',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryOrange,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 240,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: bestSellers.length,
            itemBuilder: (context, index) {
              final recipe = bestSellers[index];
              final isFav = state.favoriteIds.contains(recipe.id);

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: FoodCard(
                  recipe: recipe,
                  isFavorite: isFav,
                  width: 170,
                  onTap: () => context.push('/recipe-detail', extra: recipe),
                  onFavoriteTap: () {
                    context.read<RecipeBloc>().add(
                      ToggleFavoriteReq(recipe.id),
                    );
                  },
                  onAddToCart: () {
                    _quickAddToCart(context, recipe);
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRecommendedSection(BuildContext context, RecipeSuccess state) {
    final recommended = state.recipes.skip(2).toList();
    if (recommended.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recommended For You',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              GestureDetector(
                onTap: () => context.push('/recommendations'),
                child: const Text(
                  'View All',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryOrange,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: recommended.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.72,
              crossAxisSpacing: 12,
              mainAxisSpacing: 14,
            ),
            itemBuilder: (context, index) {
              final recipe = recommended[index];
              final isFav = state.favoriteIds.contains(recipe.id);

              return FoodCard(
                recipe: recipe,
                isFavorite: isFav,
                onTap: () => context.push('/recipe-detail', extra: recipe),
                onFavoriteTap: () {
                  context.read<RecipeBloc>().add(ToggleFavoriteReq(recipe.id));
                },
                onAddToCart: () {
                  _quickAddToCart(context, recipe);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildShimmerSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 4,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.72,
          crossAxisSpacing: 12,
          mainAxisSpacing: 14,
        ),
        itemBuilder: (context, index) => const RecipeCardSkeleton(),
      ),
    );
  }

  void _quickAddToCart(BuildContext context, RecipeEntity recipe) {
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
  }
}
