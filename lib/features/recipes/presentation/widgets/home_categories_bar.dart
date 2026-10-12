import 'package:flutter/material.dart';
import 'package:yum_quick/core/constants/app_colors.dart';
import 'package:yum_quick/core/utils/category_mapper.dart';

class HomeOrangeCategoriesBar extends StatelessWidget {
  final RecipeCategory currentCategory;
  final List<Map<String, dynamic>> categories;
  final ValueChanged<RecipeCategory> onCategorySelected;

  const HomeOrangeCategoriesBar({
    super.key,
    required this.currentCategory,
    required this.categories,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    final activeCat = (currentCategory == RecipeCategory.all)
        ? RecipeCategory.snacks
        : currentCategory;

    final selectedIndex = categories.indexWhere(
      (item) => (item['cat'] as RecipeCategory) == activeCat,
    );
    final targetIndex = (selectedIndex >= 0 ? selectedIndex : 0).toDouble();

    return SizedBox(
      width: double.infinity,
      height: 104,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: targetIndex, end: targetIndex),
            duration: const Duration(milliseconds: 240),
            curve: Curves.easeInOutCubic,
            builder: (context, animIndex, child) {
              return CustomPaint(
                painter: CategoryBarPainter(
                  animatedIndex: animIndex,
                  totalCount: categories.length,
                  orangeColor: AppColors.primaryOrange,
                  whiteColor: Colors.white,
                ),
                child: child,
              );
            },
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: categories.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                final cat = item['cat'] as RecipeCategory;
                final isSelected =
                    index == (selectedIndex >= 0 ? selectedIndex : 0);

                return Expanded(
                  child: GestureDetector(
                    onTap: () => onCategorySelected(cat),
                    behavior: HitTestBehavior.opaque,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 16),
                        Container(
                          width: 44,
                          height: 48,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primaryYellow
                                : const Color(0xFFFBEBC8),
                            borderRadius: BorderRadius.circular(22),
                          ),
                          padding: const EdgeInsets.all(6),
                          child: Image.asset(
                            item['icon'] as String,
                            color: AppColors.primaryOrange,
                            fit: BoxFit.contain,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          item['label'] as String,
                          maxLines: 1,
                          overflow: TextOverflow.visible,
                          style: TextStyle(
                            fontSize: 12.0,
                            fontWeight: isSelected
                                ? FontWeight.w800
                                : FontWeight.w700,
                            color: isSelected
                                ? const Color(0xFF33150C)
                                : const Color(0xFF5D1D0D),
                            letterSpacing: 0.1,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          );
        },
      ),
    );
  }
}

class HomeDefaultCategoriesRow extends StatelessWidget {
  final List<Map<String, dynamic>> categories;
  final ValueChanged<RecipeCategory> onCategorySelected;

  const HomeDefaultCategoriesRow({
    super.key,
    required this.categories,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: categories.map((item) {
          final cat = item['cat'] as RecipeCategory;
          return Expanded(
            child: GestureDetector(
              onTap: () => onCategorySelected(cat),
              behavior: HitTestBehavior.opaque,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 48,
                    height: 60,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3E9B5),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    padding: const EdgeInsets.all(6),
                    child: Image.asset(
                      item['icon'] as String,
                      color: AppColors.primaryOrange,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item['label'] as String,
                    maxLines: 1,
                    overflow: TextOverflow.visible,
                    style: const TextStyle(
                      fontSize: 12.0,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF33150C),
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class CategoryBarPainter extends CustomPainter {
  final double animatedIndex;
  final int totalCount;
  final Color orangeColor;
  final Color whiteColor;

  CategoryBarPainter({
    required this.animatedIndex,
    required this.totalCount,
    required this.orangeColor,
    required this.whiteColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final orangePaint = Paint()
      ..color = orangeColor
      ..isAntiAlias = true;
    final orangeRRect = RRect.fromRectAndCorners(
      Rect.fromLTWH(0, 0, size.width, size.height),
      topLeft: const Radius.circular(32),
      topRight: const Radius.circular(32),
    );
    canvas.drawRRect(orangeRRect, orangePaint);

    if (animatedIndex < 0 || animatedIndex >= totalCount) return;

    final whitePaint = Paint()
      ..color = whiteColor
      ..isAntiAlias = true;

    final slotWidth = size.width / totalCount;
    final centerX = (animatedIndex + 0.5) * slotWidth;

    const tabWidth = 62.0;
    final left = centerX - tabWidth / 2;
    final right = centerX + tabWidth / 2;
    const topY = 8.0;
    const domeRadius = tabWidth / 2;
    const filletRadius = 12.0;
    final bottomY = size.height;

    final path = Path();
    path.moveTo(left - filletRadius, bottomY);

    path.cubicTo(
      left - filletRadius * 0.45,
      bottomY,
      left,
      bottomY - filletRadius * 0.55,
      left,
      bottomY - filletRadius,
    );

    path.lineTo(left, topY + domeRadius);

    path.cubicTo(
      left,
      topY + domeRadius * 0.45,
      left + domeRadius * 0.45,
      topY,
      left + domeRadius,
      topY,
    );
    path.lineTo(right - domeRadius, topY);
    path.cubicTo(
      right - domeRadius * 0.45,
      topY,
      right,
      topY + domeRadius * 0.45,
      right,
      topY + domeRadius,
    );

    path.lineTo(right, bottomY - filletRadius);

    path.cubicTo(
      right,
      bottomY - filletRadius * 0.55,
      right + filletRadius * 0.45,
      bottomY,
      right + filletRadius,
      bottomY,
    );

    path.lineTo(right + filletRadius, bottomY + 2);
    path.lineTo(left - filletRadius, bottomY + 2);
    path.close();

    canvas.drawPath(path, whitePaint);
  }

  @override
  bool shouldRepaint(covariant CategoryBarPainter oldDelegate) {
    return oldDelegate.animatedIndex != animatedIndex ||
        oldDelegate.totalCount != totalCount ||
        oldDelegate.orangeColor != orangeColor ||
        oldDelegate.whiteColor != whiteColor;
  }
}
