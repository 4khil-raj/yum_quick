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
      floatingActionButton: BlocBuilder<CartBloc, CartState>(
        builder: (context, state) {
          if (state is CartLoaded && state.totalItemCount > 0) {
            return FloatingActionButton.extended(
              onPressed: () => context.push('/cart'),
              backgroundColor: AppColors.primaryOrange,
              elevation: 6,
              icon: Badge(
                label: Text('${state.totalItemCount}'),
                backgroundColor: AppColors.primaryYellow,
                textColor: AppColors.textPrimary,
                child: Image.asset(
                  AppAssets.icCart,
                  width: 22,
                  height: 22,
                  color: Colors.white,
                ),
              ),
              label: Text(
                'View Cart • ${PricingCalculator.formatINR(state.total)}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 16,
              offset: Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  index: 0,
                  currentIndex: currentIndex,
                  iconPath: AppAssets.icKnifeFork,
                  label: 'Home',
                ),
                _buildNavItem(
                  index: 1,
                  currentIndex: currentIndex,
                  iconPath: AppAssets.icSnacks,
                  label: 'Menu',
                ),
                _buildNavItem(
                  index: 2,
                  currentIndex: currentIndex,
                  iconPath: AppAssets.icFavorite,
                  label: 'Favorites',
                ),
                _buildNavItem(
                  index: 3,
                  currentIndex: currentIndex,
                  iconPath: AppAssets.icOrders,
                  label: 'Orders',
                ),
                _buildNavItem(
                  index: 4,
                  currentIndex: currentIndex,
                  iconPath: AppAssets.icProfile,
                  label: 'Profile',
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
    required String iconPath,
    required String label,
  }) {
    final isSelected = index == currentIndex;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _onItemTapped(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.chipOrangeTint.withValues(alpha: 0.6)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              iconPath,
              width: 22,
              height: 22,
              color: isSelected ? AppColors.primaryOrange : AppColors.textMuted,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                color: isSelected
                    ? AppColors.primaryOrange
                    : AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
