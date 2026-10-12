import 'package:flutter/material.dart';
import 'package:yum_quick/core/constants/app_colors.dart';

class FilterPriceSlider extends StatelessWidget {
  final double value;
  final ValueChanged<double> onChanged;

  const FilterPriceSlider({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Price',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppColors.primaryOrange,
              ),
            ),
            Text(
              value >= 499.0 ? '₹499+' : 'Up to ₹${value.round()}',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryOrange,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: AppColors.primaryOrange,
            inactiveTrackColor: const Color(0xFFE5E5E5),
            thumbColor: AppColors.primaryOrange,
            trackHeight: 5.0,
            thumbShape: const RoundSliderThumbShape(
              enabledThumbRadius: 8.5,
            ),
            overlayShape: const RoundSliderOverlayShape(
              overlayRadius: 16.0,
            ),
            overlayColor: AppColors.primaryOrange.withValues(
              alpha: 0.15,
            ),
          ),
          child: Slider(
            value: value,
            min: 99.0,
            max: 500.0,
            onChanged: onChanged,
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '₹99',
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textMuted,
                ),
              ),
              Text(
                '₹199',
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textMuted,
                ),
              ),
              Text(
                '₹299',
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textMuted,
                ),
              ),
              Text(
                '₹499 >',
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
