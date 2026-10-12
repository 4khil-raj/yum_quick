import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';
import 'offline_banner.dart';

class CurvedHeader extends StatelessWidget {
  final Widget? leading;
  final Widget? title;
  final List<Widget>? actions;
  final Widget? child;
  final double bottomRadius;
  final Color backgroundColor;

  const CurvedHeader({
    super.key,
    this.leading,
    this.title,
    this.actions,
    this.child,
    this.bottomRadius = 28.0,
    this.backgroundColor = AppColors.primaryYellow,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(bottomRadius),
        ),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const OfflineBanner(),
            Padding(
              padding: const EdgeInsets.only(
                top: 10,
                bottom: 20,
                left: 20,
                right: 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      ?leading,
                      const SizedBox(width: 8),
                      if (title != null) Expanded(child: title!),
                      ...?actions,
                    ],
                  ),
                  if (child != null) ...[const SizedBox(height: 16), child!],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
