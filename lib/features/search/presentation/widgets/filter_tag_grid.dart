import 'package:flutter/material.dart';
import 'package:yum_quick/core/constants/app_colors.dart';

class FilterTagGrid extends StatelessWidget {
  final List<String> tags;
  final Set<String> selectedTags;
  final ValueChanged<String> onTagToggled;

  const FilterTagGrid({
    super.key,
    required this.tags,
    required this.selectedTags,
    required this.onTagToggled,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: tags.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 2.7,
      ),
      itemBuilder: (context, index) {
        final tag = tags[index];
        final isSelected = selectedTags.contains(tag);

        return GestureDetector(
          onTap: () => onTagToggled(tag),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primaryOrange
                  : const Color(0xFFFDEECF),
              borderRadius: BorderRadius.circular(18),
            ),
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Text(
              tag,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                color: isSelected ? Colors.white : AppColors.primaryOrange,
              ),
            ),
          ),
        );
      },
    );
  }
}
