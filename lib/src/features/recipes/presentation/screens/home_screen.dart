import 'dart:async';

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
import 'package:yum_quick/src/core/utils/pricing_calculator.dart';
import 'package:yum_quick/src/features/cart/presentation/bloc/cart_bloc.dart';
import 'package:yum_quick/src/features/cart/presentation/bloc/cart_state.dart';
import 'package:yum_quick/src/features/recipes/domain/entities/recipe_entity.dart';
import 'package:yum_quick/src/features/recipes/presentation/bloc/recipe_bloc.dart';
import 'package:yum_quick/src/features/recipes/presentation/bloc/recipe_event.dart';
import 'package:yum_quick/src/features/recipes/presentation/bloc/recipe_state.dart';
import 'package:yum_quick/src/features/search/presentation/bloc/search_bloc.dart';
import 'package:yum_quick/src/features/search/presentation/bloc/search_event.dart';
import 'package:yum_quick/src/features/search/presentation/bloc/search_state.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  Timer? _debounceTimer;

  late final PageController _promoPageController;
  int _currentPromoPage = 0;
  Timer? _promoAutoPlayTimer;

  final List<Map<String, dynamic>> _promoBanners = [
    {
      'title': 'Experience our\ndelicious new dish',
      'discount': '30% OFF',
      'image': AppAssets.imgOnboardingPizza,
      'color': AppColors.primaryOrange,
    },
    {
      'title': 'Sweeten your day with\nfresh baked treats',
      'discount': '25% OFF',
      'image': AppAssets.imgOnboardingBrownie,
      'color': const Color(0xFFE65100),
    },
    {
      'title': 'Morning kickstart with\npremium hot brews',
      'discount': 'BUY 1 GET 1',
      'image': AppAssets.imgOnboardingCoffee,
      'color': const Color(0xFFD84315),
    },
    {
      'title': 'Chef Special Gourmet\nWeekend Delight',
      'discount': '40% OFF',
      'image': AppAssets.imgOnboardingPizza,
      'color': AppColors.primaryOrange,
    },
    {
      'title': 'Free Delivery on\nyour first 3 orders',
      'discount': 'CODE: YUMFREE',
      'image': AppAssets.imgOnboardingBrownie,
      'color': const Color(0xFFEF6C00),
    },
  ];

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
  void initState() {
    super.initState();
    _promoPageController = PageController();
    _startPromoAutoPlay();
    _scrollController.addListener(_onScroll);
    final searchBloc = context.read<SearchBloc>();
    if (searchBloc.state is SearchInitial) {
      searchBloc.add(const SearchRecipesReq(''));
    }
  }

  void _startPromoAutoPlay() {
    _promoAutoPlayTimer?.cancel();
    _promoAutoPlayTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_promoPageController.hasClients) {
        final nextPage = (_currentPromoPage + 1) % _promoBanners.length;
        _promoPageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 450),
          curve: Curves.easeInOutCubic,
        );
      }
    });
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
    _promoAutoPlayTimer?.cancel();
    _promoPageController.dispose();
    _debounceTimer?.cancel();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      context.read<SearchBloc>().add(SearchRecipesReq(query));
    });
  }

  void _onCategorySelected(RecipeCategory cat) {
    final searchBloc = context.read<SearchBloc>();
    final currentCat = searchBloc.state.selectedCategory;
    final newCat = (currentCat == cat) ? RecipeCategory.all : cat;

    searchBloc.add(
      UpdateFilterReq(
        category: newCat,
        selectedTags: const {},
      ),
    );
    context.read<RecipeBloc>().add(ChangeCategoryReq(newCat));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryYellow,
      body: BlocBuilder<SearchBloc, SearchState>(
        builder: (context, searchState) {
          final recipeState = context.watch<RecipeBloc>().state;
          final isOffline =
              recipeState is RecipeSuccess && recipeState.isOfflineFallback;
          final currentCat = searchState.selectedCategory;
          final isCategorized = currentCat != RecipeCategory.all;
          final isSearching = _searchController.text.trim().isNotEmpty;
          final showCategorizedOrSearch = isCategorized || isSearching;

          return SafeArea(
            bottom: false,
            child: Column(
              children: [
                OfflineBanner(isOffline: isOffline),

                // 1. Top Yellow Area (Status bar + Search Row + Greetings if not categorized)
                Padding(
                  padding: EdgeInsets.only(
                    left: 20,
                    right: 20,
                    top: 8,
                    bottom: isCategorized ? 12 : 16,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Search Row + 3 Action Icons
                      Row(
                        children: [
                          // Search Pill Field
                          Expanded(
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
                                  Expanded(
                                    child: TextField(
                                      controller: _searchController,
                                      onChanged: _onSearchChanged,
                                      decoration: const InputDecoration(
                                        hintText: 'Search',
                                        hintStyle: TextStyle(
                                          color: AppColors.textMuted,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        border: InputBorder.none,
                                        enabledBorder: InputBorder.none,
                                        focusedBorder: InputBorder.none,
                                        filled: false,
                                        contentPadding: EdgeInsets.zero,
                                      ),
                                    ),
                                  ),
                                  if (_searchController.text.isNotEmpty)
                                    GestureDetector(
                                      onTap: () {
                                        _searchController.clear();
                                        _onSearchChanged('');
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.only(right: 6),
                                        child: Image.asset(
                                          AppAssets.icClose,
                                          width: 14,
                                          height: 14,
                                          color: AppColors.textMuted,
                                        ),
                                      ),
                                    ),
                                  GestureDetector(
                                    onTap: () => context.push('/menu/filter'),
                                    child: Container(
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
                                  ),
                                ],
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
                                  width: 21,
                                  height: 21,
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
                              width: 21,
                              height: 21,
                              color: AppColors.primaryOrange,
                            ),
                            onTap: () => _showNotificationDrawer(context),
                          ),
                          const SizedBox(width: 8),

                          // Profile Button
                          _buildCircleHeaderAction(
                            icon: Image.asset(
                              AppAssets.icProfile,
                              width: 21,
                              height: 21,
                              color: AppColors.primaryOrange,
                            ),
                            onTap: () => context.push('/profile'),
                          ),
                        ],
                      ),
                      if (!isCategorized && !isSearching) ...[
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
                    ],
                  ),
                ),

              // 2. Orange Curved Categories Banner (Only when a category is selected)
              if (isCategorized) _buildOrangeCategoriesBar(currentCat),

              // 3. White Sheet Body
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: isCategorized
                        ? BorderRadius.zero
                        : const BorderRadius.vertical(top: Radius.circular(36)),
                  ),
                  child: ClipRRect(
                    borderRadius: isCategorized
                        ? BorderRadius.zero
                        : const BorderRadius.vertical(top: Radius.circular(36)),
                    child: RefreshIndicator(
                      color: AppColors.primaryOrange,
                      onRefresh: () async {
                        context.read<RecipeBloc>().add(
                          const RefreshRecipesReq(),
                        );
                        context.read<SearchBloc>().add(
                          SearchRecipesReq(_searchController.text),
                        );
                      },
                      child: SingleChildScrollView(
                        controller: _scrollController,
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.only(top: 20, bottom: 80),
                        child: showCategorizedOrSearch
                            ? _buildCategorizedFeed(context, searchState)
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Default Categories Row (5 capsules on white card)
                                  _buildDefaultCategoriesRow(),
                                  const SizedBox(height: 20),

                                  // Content based on state
                                  if (recipeState is RecipeLoading) ...[
                                    _buildShimmerSection(),
                                  ] else if (recipeState is RecipeError) ...[
                                    ErrorRetryWidget(
                                      message: recipeState.message,
                                      onRetry: () {
                                        context.read<RecipeBloc>().add(
                                          const FetchRecipesReq(),
                                        );
                                      },
                                    ),
                                  ] else if (recipeState is RecipeEmpty) ...[
                                    EmptyStateWidget(
                                      title: 'No Recipes Found',
                                      message:
                                          'No recipes match this category.',
                                      buttonText: 'View All',
                                      onButtonPressed: () {
                                        _onCategorySelected(RecipeCategory.all);
                                      },
                                    ),
                                  ] else if (recipeState is RecipeSuccess) ...[
                                    // Best Seller Section
                                    _buildBestSellerSection(
                                      context,
                                      recipeState,
                                    ),
                                    const SizedBox(height: 24),

                                    // 30% OFF Promo Banner
                                    _buildPromoBanner(context),
                                    const SizedBox(height: 24),

                                    // Recommend Section
                                    _buildRecommendSection(
                                      context,
                                      recipeState,
                                    ),
                                  ],
                                ],
                              ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    ),
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

  void _showNotificationDrawer(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Notifications',
      barrierColor: Colors.black38,
      transitionDuration: const Duration(milliseconds: 280),
      pageBuilder: (context, anim1, anim2) {
        return Align(
          alignment: Alignment.centerRight,
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.82,
              height: double.infinity,
              decoration: const BoxDecoration(
                color: AppColors.primaryOrange,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(44),
                  bottomLeft: Radius.circular(28),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 16,
                    offset: Offset(-4, 0),
                  ),
                ],
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 24,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header: Bell Icon + "Notifications"
                      Row(
                        children: [
                          Image.asset(
                            AppAssets.icNotification,
                            width: 24,
                            height: 24,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Notifications',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                          const Spacer(),
                          GestureDetector(
                            onTap: () => Navigator.of(context).pop(),
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.white24,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close_rounded,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      const Divider(color: Colors.white38, height: 1),
                      const SizedBox(height: 8),

                      // Notification Items (matching Figma 4.2 - A)
                      _buildNotificationItem(
                        icon: AppAssets.icKnifeFork,
                        text: 'We have added a product you might like.',
                      ),
                      const Divider(color: Colors.white24, height: 1),
                      _buildNotificationItem(
                        icon: AppAssets.icFavorite,
                        text: 'One of your favorite is on promotion.',
                      ),
                      const Divider(color: Colors.white24, height: 1),
                      _buildNotificationItem(
                        icon: AppAssets.icOrders,
                        text: 'Your order has been delivered',
                      ),
                      const Divider(color: Colors.white24, height: 1),
                      _buildNotificationItem(
                        icon: AppAssets.icDelivery,
                        text: 'The delivery is on his way',
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, anim, secondaryAnim, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
          child: child,
        );
      },
    );
  }

  Widget _buildNotificationItem({required String icon, required String text}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            padding: const EdgeInsets.all(10),
            child: Image.asset(
              icon,
              color: AppColors.primaryOrange,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrangeCategoriesBar(RecipeCategory currentCat) {
    final activeCat = (currentCat == RecipeCategory.all)
        ? RecipeCategory.snacks
        : currentCat;

    final selectedIndex = _categories.indexWhere(
      (item) => (item['cat'] as RecipeCategory) == activeCat,
    );
    final targetIndex = (selectedIndex >= 0 ? selectedIndex : 0).toDouble();

    return SizedBox(
      width: double.infinity,
      height: 104,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: targetIndex, end: targetIndex),
            duration: const Duration(milliseconds: 240),
            curve: Curves.easeInOutCubic,
            builder: (context, animIndex, child) {
              return CustomPaint(
                painter: CategoryBarPainter(
                  animatedIndex: animIndex,
                  totalCount: _categories.length,
                  orangeColor: AppColors.primaryOrange,
                  whiteColor: Colors.white,
                ),
                child: child,
              );
            },
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: _categories.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                final cat = item['cat'] as RecipeCategory;
                final isSelected =
                    index == (selectedIndex >= 0 ? selectedIndex : 0);

                return Expanded(
                  child: GestureDetector(
                    onTap: () => _onCategorySelected(cat),
                    behavior: HitTestBehavior.opaque,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 16),
                        Container(
                          width: 44,
                          height: 48,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primaryYellow
                                : const Color(0xFFFBEBC8),
                            borderRadius: BorderRadius.circular(22),
                          ),
                          padding: const EdgeInsets.all(6),
                          child: Image.asset(
                            item['icon'] as String,
                            color: AppColors.primaryOrange,
                            fit: BoxFit.contain,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          item['label'] as String,
                          maxLines: 1,
                          overflow: TextOverflow.visible,
                          style: TextStyle(
                            fontSize: 12.0,
                            fontWeight: isSelected
                                ? FontWeight.w800
                                : FontWeight.w700,
                            color: isSelected
                                ? const Color(0xFF33150C)
                                : const Color(0xFF5D1D0D),
                            letterSpacing: 0.1,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDefaultCategoriesRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: _categories.map((item) {
          final cat = item['cat'] as RecipeCategory;
          return Expanded(
            child: GestureDetector(
              onTap: () => _onCategorySelected(cat),
              behavior: HitTestBehavior.opaque,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 48,
                    height: 60,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3E9B5),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    padding: const EdgeInsets.all(6),
                    child: Image.asset(
                      item['icon'] as String,
                      color: AppColors.primaryOrange,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item['label'] as String,
                    maxLines: 1,
                    overflow: TextOverflow.visible,
                    style: const TextStyle(
                      fontSize: 12.0,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF33150C),
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCategorizedFeed(BuildContext context, SearchState searchState) {
    if (searchState is SearchLoading || searchState is SearchInitial) {
      return _buildShimmerSection();
    } else if (searchState is SearchError) {
      return ErrorRetryWidget(
        message: searchState.message,
        onRetry: () {
          context.read<SearchBloc>().add(
            SearchRecipesReq(_searchController.text),
          );
        },
      );
    } else if (searchState is SearchEmpty) {
      return EmptyStateWidget(
        title: 'No Recipes Found',
        message: 'No recipes match your criteria.',
        buttonText: 'Reset Filters',
        onButtonPressed: () {
          _searchController.clear();
          context.read<SearchBloc>().add(const ClearFiltersReq());
          context.read<RecipeBloc>().add(
            const ChangeCategoryReq(RecipeCategory.all),
          );
        },
      );
    } else if (searchState is SearchSuccess) {
      final recipes = searchState.results;
      if (recipes.isEmpty) {
        return EmptyStateWidget(
          title: 'No Recipes Found',
          message: 'No recipes match your criteria.',
          buttonText: 'Reset Filters',
          onButtonPressed: () {
            _searchController.clear();
            context.read<SearchBloc>().add(const ClearFiltersReq());
            context.read<RecipeBloc>().add(
              const ChangeCategoryReq(RecipeCategory.all),
            );
          },
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sort By Row + Filter Icon
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            child: Row(
              children: [
                const Text(
                  'Sort By ',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  _getSortLabel(searchState.sortOption),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryOrange,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => context.push('/menu/filter'),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.primaryOrange,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.tune_rounded,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Vertical List of Categorized Food Cards
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: recipes.length,
            separatorBuilder: (context, index) => const SizedBox(height: 22),
            itemBuilder: (context, index) {
              return _buildCategorizedFoodCard(context, recipes[index]);
            },
          ),
        ],
      );
    }
    return const SizedBox.shrink();
  }

  String _getSortLabel(SortOption option) {
    switch (option) {
      case SortOption.relevance:
        return 'Popular';
      case SortOption.ratingHighToLow:
        return 'Top Rated';
      case SortOption.priceLowToHigh:
        return 'Price: Low to High';
      case SortOption.priceHighToLow:
        return 'Price: High to Low';
      case SortOption.timeFastest:
        return 'Fastest Prep';
    }
  }

  Widget _buildCategorizedFoodCard(BuildContext context, RecipeEntity recipe) {
    return GestureDetector(
      onTap: () => context.push('/recipe-detail', extra: recipe),
      behavior: HitTestBehavior.opaque,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Food Image with rounded corners and shadow
          Container(
            height: 180,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 8,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: CachedNetworkImage(
                imageUrl: recipe.image,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: AppColors.surfaceSoft,
                  child: const Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.primaryOrange,
                      ),
                    ),
                  ),
                ),
                errorWidget: (context, url, err) => Container(
                  color: AppColors.surfaceSoft,
                  child: const Icon(
                    Icons.restaurant,
                    color: Colors.grey,
                    size: 40,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Title • Rating and Price
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Flexible(
                      child: Text(
                        recipe.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      '•',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        color: AppColors.primaryOrange,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 5,
                        vertical: 1.5,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryOrange,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            recipe.rating.toStringAsFixed(1),
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 2),
                          const Icon(Icons.star, size: 10, color: Colors.amber),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                PricingCalculator.formatINR(recipe.price),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primaryOrange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),

          // Subtitle / Ingredients
          Text(
            recipe.ingredients.isNotEmpty
                ? recipe.ingredients.take(4).join(', ')
                : '${recipe.cuisine} • ${recipe.difficulty}',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textMuted,
              height: 1.3,
            ),
          ),
        ],
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
                            PricingCalculator.formatINR(recipe.price),
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
          SizedBox(
            height: 130,
            child: PageView.builder(
              controller: _promoPageController,
              onPageChanged: (index) {
                setState(() {
                  _currentPromoPage = index;
                });
              },
              itemCount: _promoBanners.length,
              itemBuilder: (context, index) {
                final item = _promoBanners[index];
                return GestureDetector(
                  onTap: () => context.push('/menu'),
                  behavior: HitTestBehavior.opaque,
                  child: Container(
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
                          // Left: Promo details side
                          Expanded(
                            flex: 11,
                            child: Container(
                              color: item['color'] as Color,
                              padding: const EdgeInsets.all(14),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    item['title'] as String,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      height: 1.25,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    item['discount'] as String,
                                    style: const TextStyle(
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

                          // Right: Food image side
                          Expanded(
                            flex: 13,
                            child: Image.asset(
                              item['image'] as String,
                              height: 130,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 10),

          // Pagination Dots below banner
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_promoBanners.length, (index) {
              final isSelected = index == _currentPromoPage;
              return GestureDetector(
                onTap: () {
                  _promoPageController.animateToPage(
                    index,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeInOut,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  height: 4,
                  width: isSelected ? 18 : 10,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primaryOrange
                        : AppColors.inactiveDot,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendSection(BuildContext context, RecipeSuccess state) {
    final recommended = state.recipes.length > 4
        ? state.recipes.skip(4).toList()
        : state.recipes;
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
                            PricingCalculator.formatINR(recipe.price),
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

        // Pagination loading indicator / footer
        if (state.isLoadingMore) ...[
          const SizedBox(height: 16),
          const Center(
            child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: AppColors.primaryOrange,
              ),
            ),
          ),
          const SizedBox(height: 12),
        ] else if (state.paginationError != null) ...[
          const SizedBox(height: 12),
          Center(
            child: TextButton.icon(
              onPressed: () {
                context.read<RecipeBloc>().add(const LoadMoreRecipesReq());
              },
              icon: const Icon(
                Icons.refresh,
                size: 16,
                color: AppColors.primaryOrange,
              ),
              label: const Text(
                'Failed to load more. Tap to retry',
                style: TextStyle(
                  color: AppColors.primaryOrange,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ] else if (!state.hasMore && recommended.isNotEmpty) ...[
          const SizedBox(height: 20),
          const Center(
            child: Text(
              "You've reached the end of recommendations",
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textMuted,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 10),
        ],
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

class CategoryBarPainter extends CustomPainter {
  final double animatedIndex;
  final int totalCount;
  final Color orangeColor;
  final Color whiteColor;

  CategoryBarPainter({
    required this.animatedIndex,
    required this.totalCount,
    required this.orangeColor,
    required this.whiteColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Draw orange container with rounded top corners
    final orangePaint = Paint()
      ..color = orangeColor
      ..isAntiAlias = true;
    final orangeRRect = RRect.fromRectAndCorners(
      Rect.fromLTWH(0, 0, size.width, size.height),
      topLeft: const Radius.circular(32),
      topRight: const Radius.circular(32),
    );
    canvas.drawRRect(orangeRRect, orangePaint);

    if (animatedIndex < 0 || animatedIndex >= totalCount) return;

    // 2. Draw white surface with arched tab and smooth concave fillets
    final whitePaint = Paint()
      ..color = whiteColor
      ..isAntiAlias = true;

    final slotWidth = size.width / totalCount;
    final centerX = (animatedIndex + 0.5) * slotWidth;

    const tabWidth = 62.0;
    final left = centerX - tabWidth / 2;
    final right = centerX + tabWidth / 2;
    const topY = 8.0;
    const domeRadius = tabWidth / 2; // 31.0
    const filletRadius = 12.0;
    final bottomY = size.height;

    final path = Path();
    path.moveTo(left - filletRadius, bottomY);

    // Left concave fillet (curving from bottom edge up into left wall)
    path.cubicTo(
      left - filletRadius * 0.45,
      bottomY,
      left,
      bottomY - filletRadius * 0.55,
      left,
      bottomY - filletRadius,
    );

    // Left vertical wall
    path.lineTo(left, topY + domeRadius);

    // Top rounded dome from left to right
    path.cubicTo(
      left,
      topY + domeRadius * 0.45,
      left + domeRadius * 0.45,
      topY,
      left + domeRadius,
      topY,
    );
    path.lineTo(right - domeRadius, topY);
    path.cubicTo(
      right - domeRadius * 0.45,
      topY,
      right,
      topY + domeRadius * 0.45,
      right,
      topY + domeRadius,
    );

    // Right vertical wall
    path.lineTo(right, bottomY - filletRadius);

    // Right concave fillet (curving from right wall down into bottom edge)
    path.cubicTo(
      right,
      bottomY - filletRadius * 0.55,
      right + filletRadius * 0.45,
      bottomY,
      right + filletRadius,
      bottomY,
    );

    // Close across bottom
    path.lineTo(right + filletRadius, bottomY + 2);
    path.lineTo(left - filletRadius, bottomY + 2);
    path.close();

    canvas.drawPath(path, whitePaint);
  }

  @override
  bool shouldRepaint(covariant CategoryBarPainter oldDelegate) {
    return oldDelegate.animatedIndex != animatedIndex ||
        oldDelegate.totalCount != totalCount ||
        oldDelegate.orangeColor != orangeColor ||
        oldDelegate.whiteColor != whiteColor;
  }
}
