import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';

enum AppButtonVariant { primary, secondary, outlined }

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final AppButtonVariant variant;
  final double? width;
  final double height;
  final Widget? icon;
  final Color? customColor;

  const AppButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.variant = AppButtonVariant.primary,
    this.width,
    this.height = 54,
    this.icon,
    this.customColor,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor =
        customColor ??
        (variant == AppButtonVariant.secondary
            ? AppColors.primaryYellow
            : AppColors.primaryOrange);

    final isOutlined = variant == AppButtonVariant.outlined;

    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isOutlined ? Colors.transparent : effectiveColor,
          foregroundColor: isOutlined
              ? AppColors.primaryOrange
              : (variant == AppButtonVariant.secondary
                    ? AppColors.textPrimary
                    : Colors.white),
          elevation: isOutlined ? 0 : 0,
          side: isOutlined
              ? const BorderSide(color: AppColors.primaryOrange, width: 1.5)
              : BorderSide.none,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24),
        ),
        child: isLoading
            ? const SizedBox(
                height: 22,
                width: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[icon!, const SizedBox(width: 8)],
                  Text(
                    text,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: isOutlined
                          ? AppColors.primaryOrange
                          : (variant == AppButtonVariant.secondary
                                ? AppColors.textPrimary
                                : Colors.white),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
