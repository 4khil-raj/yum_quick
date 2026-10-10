import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:yum_quick/src/core/constants/app_assets.dart';
import 'package:yum_quick/src/core/constants/app_colors.dart';
import 'package:yum_quick/src/core/presentation/components/empty_state_widget.dart';
import 'package:yum_quick/src/core/presentation/components/offline_banner.dart';
import 'package:yum_quick/src/core/presentation/components/shimmer_loading.dart';
import 'package:yum_quick/src/core/utils/category_mapper.dart';
import 'package:yum_quick/src/features/cart/state/cart_bloc.dart';
import 'package:yum_quick/src/features/cart/state/cart_state.dart';
import 'package:yum_quick/src/features/recipes/state/recipe_bloc.dart';
import 'package:yum_quick/src/features/recipes/state/recipe_event.dart';
import 'package:yum_quick/src/features/recipes/state/recipe_state.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, dynamic>> _categories = [
    {
      'label': 'Snacks',
      'icon': AppAssets.icSnacks,
      'cat': RecipeCategory.snacks,
    },
    {
      'label': 'Meal',
      'icon': AppAssets.icKnifeFork,
      'cat': RecipeCategory.meal,
    },
    {
      'label': 'Vegan',
      'icon': AppAssets.icVegetables,
      'cat': RecipeCategory.vegan,
    },
    {
      'label': 'Dessert',
      'icon': AppAssets.icDesserts,
      'cat': RecipeCategory.dessert,
    },
    {
      'label': 'Drinks',
      'icon': AppAssets.icBeverages,
      'cat': RecipeCategory.drinks,
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onCategorySelected(RecipeCategory cat) {
    final state = context.read<RecipeBloc>().state;
    final currentCat = state is RecipeSuccess
        ? state.category
        : RecipeCategory.all;
    if (currentCat == cat) {
      context.read<RecipeBloc>().add(
        const ChangeCategoryReq(RecipeCategory.all),
      );
    } else {
      context.read<RecipeBloc>().add(ChangeCategoryReq(cat));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RecipeBloc, RecipeState>(
      builder: (context, state) {
        final isOffline = state is RecipeSuccess && state.isOfflineFallback;

        return Scaffold(
          backgroundColor: AppColors.primaryYellow,
          body: Column(
            children: [
              OfflineBanner(isOffline: isOffline),

              // 1. Top Yellow Area (Status bar + Search Row + Greetings)
              SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.only(
                    left: 20,
                    right: 20,
                    top: 8,
                    bottom: 16,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Search Row + 3 Action Icons
                      Row(
                        children: [
                          // Search Pill Field
                          Expanded(
                            child: GestureDetector(
                              onTap: () => context.push('/menu'),
                              child: Container(
                                height: 44,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(22),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Colors.black12,
                                      blurRadius: 4,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                ),
                                child: Row(
                                  children: [
                                    const Expanded(
                                      child: Text(
                                        'Search',
                                        style: TextStyle(
                                          color: AppColors.textMuted,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      width: 28,
                                      height: 28,
                                      decoration: const BoxDecoration(
                                        color: AppColors.primaryOrange,
                                        shape: BoxShape.circle,
                                      ),
                                      padding: const EdgeInsets.all(6),
                                      child: const Icon(
                                        Icons.tune_rounded,
                                        size: 16,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),

                          // Cart Button with Badge
                          BlocBuilder<CartBloc, CartState>(
                            builder: (context, cartState) {
                              final count = cartState is CartLoaded
                                  ? cartState.totalItemCount
                                  : 0;

                              return _buildCircleHeaderAction(
                                icon: Image.asset(
                                  AppAssets.icCart,
                                  width: 18,
                                  height: 18,
                                  color: AppColors.primaryOrange,
                                ),
                                badgeCount: count,
                                onTap: () => context.push('/cart'),
                              );
                            },
                          ),
                          const SizedBox(width: 8),

                          // Notification Button
                          _buildCircleHeaderAction(
                            icon: Image.asset(
                              AppAssets.icNotification,
                              width: 18,
                              height: 18,
                              color: AppColors.primaryOrange,
                            ),
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('No new notifications.'),
                                ),
                              );
                            },
                          ),
                          const SizedBox(width: 8),

                          // Profile Button
                          _buildCircleHeaderAction(
                            icon: Image.asset(
                              AppAssets.icProfile,
                              width: 18,
                              height: 18,
                              color: AppColors.primaryOrange,
                            ),
                            onTap: () => context.push('/profile'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),

                      // Greetings Text
                      const Text(
                        'Good Morning',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 0.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        "Rise And Shine! It's Breakfast Time",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryOrange,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 2. White Sheet Body with Curved Top
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(36),
                    ),
                  ),
                  child: RefreshIndicator(
                    color: AppColors.primaryOrange,
                    onRefresh: () async {
                      context.read<RecipeBloc>().add(const RefreshRecipesReq());
                    },
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.only(top: 24, bottom: 80),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 5 Categories Row
                          _buildCategoriesRow(state),
                          const SizedBox(height: 24),

                          // Content based on state
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
                              message: 'No recipes match this category.',
                              buttonText: 'View All',
                              onButtonPressed: () {
                                context.read<RecipeBloc>().add(
                                  const ChangeCategoryReq(RecipeCategory.all),
                                );
                              },
                            ),
                          ] else if (state is RecipeSuccess) ...[
                            // Best Seller Section
                            _buildBestSellerSection(context, state),
                            const SizedBox(height: 24),

                            // 30% OFF Promo Banner
                            _buildPromoBanner(context),
                            const SizedBox(height: 24),

                            // Recommend Section
                            _buildRecommendSection(context, state),
                          ],
                        ],
                      ),
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

  Widget _buildCircleHeaderAction({
    required Widget icon,
    int badgeCount = 0,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
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
        child: Center(
          child: badgeCount > 0
              ? Badge(
                  label: Text('$badgeCount'),
                  backgroundColor: AppColors.primaryOrange,
                  textColor: Colors.white,
                  child: icon,
                )
              : icon,
        ),
      ),
    );
  }

  Widget _buildCategoriesRow(RecipeState state) {
    final currentCat = state is RecipeSuccess
        ? state.category
        : (state is RecipeLoading ? state.category : RecipeCategory.all);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: _categories.map((item) {
          final cat = item['cat'] as RecipeCategory;
          final isSelected = currentCat == cat;

          return GestureDetector(
            onTap: () => _onCategorySelected(cat),
            child: Column(
              children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primaryOrange
                        : AppColors.creamCard,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(13),
                  child: Image.asset(
                    item['icon'] as String,
                    color: isSelected ? Colors.white : AppColors.primaryOrange,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  item['label'] as String,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                    color: isSelected
                        ? AppColors.primaryOrange
                        : AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildBestSellerSection(BuildContext context, RecipeSuccess state) {
    final bestSellers = state.recipes.take(6).toList();

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
                child: const Row(
                  children: [
                    Text(
                      'View All',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryOrange,
                      ),
                    ),
                    SizedBox(width: 2),
                    Icon(
                      Icons.chevron_right_rounded,
                      size: 16,
                      color: AppColors.primaryOrange,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Horizontal List of Food Cards
        SizedBox(
          height: 140,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: bestSellers.length,
            itemBuilder: (context, index) {
              final recipe = bestSellers[index];

              return GestureDetector(
                onTap: () => context.push('/recipe-detail', extra: recipe),
                child: Container(
                  width: 115,
                  margin: const EdgeInsets.symmetric(horizontal: 5),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 6,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      // Image filling card
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: CachedNetworkImage(
                          imageUrl: recipe.image,
                          width: 115,
                          height: 140,
                          fit: BoxFit.cover,
                          placeholder: (context, url) =>
                              Container(color: AppColors.surfaceSoft),
                          errorWidget: (context, url, err) => Container(
                            color: AppColors.surfaceSoft,
                            child: const Icon(
                              Icons.restaurant,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ),

                      // Orange Price Pill at Bottom Right
                      Positioned(
                        bottom: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primaryOrange,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '\$${recipe.price.toStringAsFixed(recipe.price % 1 == 0 ? 1 : 2)}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
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

  Widget _buildPromoBanner(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Container(
            height: 130,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Row(
                children: [
                  // Left: Orange 30% OFF side
                  Expanded(
                    flex: 11,
                    child: Container(
                      color: AppColors.primaryOrange,
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Experience our\ndelicious new dish',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              height: 1.25,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            '30% OFF',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Right: Pizza photo side
                  Expanded(
                    flex: 13,
                    child: Image.asset(
                      AppAssets.imgOnboardingPizza,
                      height: 130,
                      fit: BoxFit.cover,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Pagination Dots below banner
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 3),
                height: 4,
                width: index == 2 ? 18 : 10,
                decoration: BoxDecoration(
                  color: index == 2
                      ? AppColors.primaryOrange
                      : AppColors.inactiveDot,
                  borderRadius: BorderRadius.circular(2),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendSection(BuildContext context, RecipeSuccess state) {
    final recommended = state.recipes.skip(4).take(6).toList();
    if (recommended.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Recommend',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
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
              childAspectRatio: 1.05,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemBuilder: (context, index) {
              final recipe = recommended[index];

              return GestureDetector(
                onTap: () => context.push('/recipe-detail', extra: recipe),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 6,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      // Full food image
                      ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: CachedNetworkImage(
                          imageUrl: recipe.image,
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.cover,
                          placeholder: (context, url) =>
                              Container(color: AppColors.surfaceSoft),
                          errorWidget: (context, url, err) => Container(
                            color: AppColors.surfaceSoft,
                            child: const Icon(
                              Icons.restaurant,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ),

                      // Top-Left Rating & Heart Badge: 5.0 ★ ♥
                      Positioned(
                        top: 8,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.92),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                recipe.rating.toStringAsFixed(1),
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(width: 2),
                              const Icon(
                                Icons.star,
                                size: 10,
                                color: Colors.amber,
                              ),
                              const SizedBox(width: 3),
                              const Icon(
                                Icons.favorite,
                                size: 10,
                                color: AppColors.primaryOrange,
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Bottom-Right Price Tag
                      Positioned(
                        bottom: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primaryOrange,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '\$${recipe.price.toStringAsFixed(recipe.price % 1 == 0 ? 1 : 2)}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
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

  Widget _buildShimmerSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 4,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1.05,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemBuilder: (context, index) => const RecipeCardSkeleton(),
      ),
    );
  }
}
