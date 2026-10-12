import 'package:flutter/material.dart';
import 'package:yum_quick/core/constants/app_colors.dart';

class HomePromoCarousel extends StatelessWidget {
  final PageController controller;
  final int currentPage;
  final ValueChanged<int> onPageChanged;
  final List<Map<String, dynamic>> banners;
  final VoidCallback onBannerTap;

  const HomePromoCarousel({
    super.key,
    required this.controller,
    required this.currentPage,
    required this.onPageChanged,
    required this.banners,
    required this.onBannerTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          SizedBox(
            height: 130,
            child: PageView.builder(
              controller: controller,
              onPageChanged: onPageChanged,
              itemCount: banners.length,
              itemBuilder: (context, index) {
                final item = banners[index];
                return GestureDetector(
                  onTap: onBannerTap,
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 11,
                            child: Container(
                              color: item['color'] as Color,
                              padding: const EdgeInsets.all(14),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    item['title'] as String,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      height: 1.25,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    item['discount'] as String,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 22,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          Expanded(
                            flex: 13,
                            child: Image.asset(
                              item['image'] as String,
                              height: 130,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 10),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(banners.length, (index) {
              final isSelected = index == currentPage;
              return GestureDetector(
                onTap: () {
                  controller.animateToPage(
                    index,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeInOut,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  height: 4,
                  width: isSelected ? 18 : 10,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primaryOrange
                        : AppColors.inactiveDot,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
