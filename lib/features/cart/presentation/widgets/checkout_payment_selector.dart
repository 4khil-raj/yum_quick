import 'package:flutter/material.dart';
import 'package:yum_quick/core/constants/app_assets.dart';
import 'package:yum_quick/core/constants/app_colors.dart';

class CheckoutPaymentSelector extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onSelect;

  const CheckoutPaymentSelector({
    super.key,
    required this.selectedIndex,
    required this.onSelect,
  });

  static const List<Map<String, String>> paymentMethods = [
    {
      'title': 'UPI / Instant Pay',
      'subtitle': 'Google Pay, PhonePe, Paytm',
      'icon': AppAssets.icPayment,
    },
    {
      'title': 'Credit / Debit Card',
      'subtitle': 'Visa, MasterCard, RuPay',
      'icon': AppAssets.icPayment,
    },
    {
      'title': 'Cash on Delivery',
      'subtitle': 'Pay cash upon delivery',
      'icon': AppAssets.icDelivery,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: paymentMethods.asMap().entries.map((entry) {
        final index = entry.key;
        final item = entry.value;
        final isSelected = selectedIndex == index;

        return GestureDetector(
          onTap: () => onSelect(index),
          child: Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isSelected ? AppColors.primaryOrange : AppColors.border,
                width: isSelected ? 1.5 : 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.chipOrangeTint
                        : AppColors.surfaceSoft,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Image.asset(
                    item['icon']!,
                    width: 20,
                    height: 20,
                    color: isSelected
                        ? AppColors.primaryOrange
                        : AppColors.textSecondary,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['title']!,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        item['subtitle']!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primaryOrange
                          : Colors.grey.shade400,
                      width: 2,
                    ),
                  ),
                  padding: const EdgeInsets.all(3),
                  child: isSelected
                      ? Container(
                          decoration: const BoxDecoration(
                            color: AppColors.primaryOrange,
                            shape: BoxShape.circle,
                          ),
                        )
                      : null,
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
