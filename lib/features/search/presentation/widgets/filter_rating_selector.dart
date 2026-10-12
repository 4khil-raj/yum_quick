import 'package:flutter/material.dart';
import 'package:yum_quick/core/constants/app_colors.dart';

class FilterRatingSelector extends StatelessWidget {
  final int selectedRating;
  final ValueChanged<int> onRatingChanged;

  const FilterRatingSelector({
    super.key,
    required this.selectedRating,
    required this.onRatingChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Text(
          'Top Rated',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(width: 14),
        Row(
          children: List.generate(5, (index) {
            final starNum = index + 1;
            final isFilled = starNum <= selectedRating;
            return GestureDetector(
              onTap: () {
                onRatingChanged(selectedRating == starNum ? 0 : starNum);
              },
              child: Padding(
                padding: const EdgeInsets.only(right: 3),
                child: Icon(
                  isFilled ? Icons.star_rounded : Icons.star_border_rounded,
                  size: 20,
                  color: AppColors.primaryOrange,
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}
