import 'package:flutter/material.dart';
import 'package:yum_quick/core/constants/app_colors.dart';

class OrderTabSelector extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTabSelected;

  const OrderTabSelector({
    super.key,
    required this.selectedIndex,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildPillTab(title: 'Active', index: 0),
          _buildPillTab(title: 'Completed', index: 1),
          _buildPillTab(title: 'Cancelled', index: 2),
        ],
      ),
    );
  }

  Widget _buildPillTab({required String title, required int index}) {
    final isSelected = selectedIndex == index;

    return GestureDetector(
      onTap: () => onTabSelected(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryOrange : AppColors.creamButton,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: isSelected ? Colors.white : AppColors.primaryOrange,
          ),
        ),
      ),
    );
  }
}
