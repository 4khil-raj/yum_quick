import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:yum_quick/core/constants/app_assets.dart';
import 'package:yum_quick/core/constants/app_colors.dart';
import 'package:yum_quick/core/presentation/components/quantity_control.dart';
import 'package:yum_quick/core/utils/pricing_calculator.dart';
import '../../domain/entities/cart_item_entity.dart';

class CartItemCard extends StatelessWidget {
  final CartItemEntity item;
  final ValueChanged<int> onQuantityChanged;
  final VoidCallback onDismissed;

  const CartItemCard({
    super.key,
    required this.item,
    required this.onQuantityChanged,
    required this.onDismissed,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key('cart_item_${item.recipeId}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Image.asset(
          AppAssets.icDelete,
          width: 24,
          height: 24,
          color: Colors.white,
        ),
      ),
      onDismissed: (_) => onDismissed(),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 8,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: CachedNetworkImage(
                imageUrl: item.recipeImage,
                width: 74,
                height: 74,
                fit: BoxFit.cover,
                errorWidget: (context, url, error) => Container(
                  width: 74,
                  height: 74,
                  color: AppColors.surfaceSoft,
                  child: const Icon(
                    Icons.restaurant,
                    color: AppColors.textMuted,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.recipeName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if (item.selectedAddOns.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      item.selectedAddOns.join(', '),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                  const SizedBox(height: 6),
                  Text(
                    PricingCalculator.formatINR(item.totalPrice),
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primaryOrange,
                    ),
                  ),
                ],
              ),
            ),
            QuantityControl(
              quantity: item.quantity,
              min: 0,
              onQuantityChanged: onQuantityChanged,
            ),
          ],
        ),
      ),
    );
  }
}
