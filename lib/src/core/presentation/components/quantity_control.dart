import 'package:flutter/material.dart';

import '../../constants/app_assets.dart';
import '../../constants/app_colors.dart';

class QuantityControl extends StatelessWidget {
  final int quantity;
  final ValueChanged<int> onQuantityChanged;
  final int min;
  final int max;

  const QuantityControl({
    super.key,
    required this.quantity,
    required this.onQuantityChanged,
    this.min = 1,
    this.max = 99,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.chipOrangeTint.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(24),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildButton(
            iconPath: AppAssets.icMinus,
            onTap: quantity > min
                ? () => onQuantityChanged(quantity - 1)
                : null,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Text(
              '$quantity',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          _buildButton(
            iconPath: AppAssets.icPlus,
            onTap: quantity < max
                ? () => onQuantityChanged(quantity + 1)
                : null,
          ),
        ],
      ),
    );
  }

  Widget _buildButton({
    required String iconPath,
    required VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: onTap != null ? AppColors.primaryOrange : Colors.grey.shade300,
          shape: BoxShape.circle,
        ),
        padding: const EdgeInsets.all(8),
        child: Image.asset(iconPath, color: Colors.white, fit: BoxFit.contain),
      ),
    );
  }
}
