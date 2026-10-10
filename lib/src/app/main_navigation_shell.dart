import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:yum_quick/src/core/constants/app_assets.dart';
import 'package:yum_quick/src/core/constants/app_colors.dart';
import 'package:yum_quick/src/core/utils/pricing_calculator.dart';

import '../features/cart/state/cart_bloc.dart';
import '../features/cart/state/cart_state.dart';

class MainNavigationShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const MainNavigationShell({super.key, required this.navigationShell});

  void _onItemTapped(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = navigationShell.currentIndex;

    return Scaffold(
      body: navigationShell,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: BlocBuilder<CartBloc, CartState>(
        builder: (context, state) {
          if (state is CartLoaded && state.totalItemCount > 0) {
            return Container(
              margin: const EdgeInsets.only(bottom: 74),
              child: FloatingActionButton.extended(
                onPressed: () => context.push('/cart'),
                backgroundColor: AppColors.primaryYellow,
                foregroundColor: AppColors.textPrimary,
                elevation: 6,
                icon: Badge(
                  label: Text(
                    '${state.totalItemCount}',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  backgroundColor: AppColors.primaryOrange,
                  textColor: Colors.white,
                  child: Image.asset(
                    AppAssets.icCart,
                    width: 22,
                    height: 22,
                    color: AppColors.textPrimary,
                  ),
                ),
                label: Text(
                  'Cart • ${PricingCalculator.formatINR(state.total)}',
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.primaryOrange,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 64,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  index: 0,
                  currentIndex: currentIndex,
                  assetPath: AppAssets.navHome,
                ),
                _buildNavItem(
                  index: 1,
                  currentIndex: currentIndex,
                  assetPath: AppAssets.navMenu,
                ),
                _buildNavItem(
                  index: 2,
                  currentIndex: currentIndex,
                  assetPath: AppAssets.navFavorite,
                ),
                _buildNavItem(
                  index: 3,
                  currentIndex: currentIndex,
                  assetPath: AppAssets.navOrders,
                ),
                _buildNavItem(
                  index: 4,
                  currentIndex: currentIndex,
                  assetPath: AppAssets.navSupport,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required int currentIndex,
    String? assetPath,
    Widget? icon,
  }) {
    final isSelected = index == currentIndex;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _onItemTapped(index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: isSelected
                  ? BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.22),
                      shape: BoxShape.circle,
                    )
                  : null,
              child:
                  icon ??
                  Image.asset(
                    assetPath!,
                    width: 24,
                    height: 24,
                    color: Colors.white,
                  ),
            ),
            if (isSelected)
              Container(
                margin: const EdgeInsets.only(top: 2),
                width: 4,
                height: 4,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
