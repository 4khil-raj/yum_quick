import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';

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
    final topPadding = MediaQuery.of(context).padding.top;

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
      padding: EdgeInsets.only(
        top: topPadding + 10,
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
    );
  }
}
