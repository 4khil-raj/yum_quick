import 'package:flutter/material.dart';
import 'package:yum_quick/core/constants/app_assets.dart';
import 'package:yum_quick/core/constants/app_colors.dart';
import 'package:yum_quick/core/presentation/components/app_button.dart';
import 'package:yum_quick/core/utils/pricing_calculator.dart';

class RecipeBottomBar extends StatelessWidget {
  final double totalPrice;
  final VoidCallback onAddToCart;

  const RecipeBottomBar({
    super.key,
    required this.totalPrice,
    required this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
      padding: const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 16,
      ),
      child: SafeArea(
        child: Row(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Total Price',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  PricingCalculator.formatINR(totalPrice),
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: AppColors.primaryOrange,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 24),
            Expanded(
              child: AppButton(
                text: 'Add to Cart',
                icon: Image.asset(
                  AppAssets.icCart,
                  width: 20,
                  height: 20,
                  color: Colors.white,
                ),
                onPressed: onAddToCart,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
