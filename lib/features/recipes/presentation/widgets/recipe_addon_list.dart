import 'package:flutter/material.dart';
import 'package:yum_quick/core/constants/app_colors.dart';
import 'package:yum_quick/core/utils/pricing_calculator.dart';

class RecipeAddOnList extends StatelessWidget {
  final Map<String, double> availableAddOns;
  final Set<String> selectedAddOns;
  final void Function(String addOn, bool isSelected) onAddOnToggled;

  const RecipeAddOnList({
    super.key,
    required this.availableAddOns,
    required this.selectedAddOns,
    required this.onAddOnToggled,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Add-on Toppings & Dips',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        ...availableAddOns.entries.map((entry) {
          final isSelected = selectedAddOns.contains(entry.key);
          return CheckboxListTile(
            value: isSelected,
            activeColor: AppColors.primaryOrange,
            contentPadding: EdgeInsets.zero,
            title: Text(
              entry.key,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            secondary: Text(
              '+${PricingCalculator.formatINR(entry.value)}',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryOrange,
              ),
            ),
            onChanged: (bool? val) {
              onAddOnToggled(entry.key, val == true);
            },
          );
        }),
      ],
    );
  }
}
