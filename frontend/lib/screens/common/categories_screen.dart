import 'package:flutter/material.dart';
import 'package:buildacad/constants/colors.dart';
import 'package:buildacad/theme/app_theme.dart';
import 'package:buildacad/screens/common/category_detail_screen.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return Scaffold(
      backgroundColor: AppColors.background(brightness),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Browse Categories', style: AppTypography.headlineSmMobile.copyWith(
          color: AppColors.textOnSurface(brightness), fontWeight: FontWeight.w700,
        )),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12,
          childAspectRatio: 1.2,
        ),
        itemCount: _categories.length,
        itemBuilder: (context, i) {
          final cat = _categories[i];
          return GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(
              builder: (_) => CategoryDetailScreen(categoryName: cat['name'] as String),
            )),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest(brightness),
                borderRadius: AppRadius.cardAll,
                border: Border.all(color: AppColors.border(brightness)),
                boxShadow: AppShadow.card,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 48, height: 48,
                    decoration: BoxDecoration(
                      color: cat['color'] as Color,
                      borderRadius: AppRadius.mdAll,
                    ),
                    child: Icon(cat['icon'] as IconData, color: Colors.white, size: 24),
                  ),
                  const SizedBox(height: 12),
                  Text(cat['name'] as String, textAlign: TextAlign.center, style: AppTypography.bodyMd.copyWith(
                    fontWeight: FontWeight.w600, color: AppColors.textOnSurface(brightness),
                  )),
                  const SizedBox(height: 4),
                  Text('${cat['courses']} courses', style: AppTypography.bodySm.copyWith(
                    color: AppColors.outline(brightness), fontSize: 12,
                  )),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

final _categories = [
  {'name': 'Robotics', 'courses': 42, 'icon': Icons.precision_manufacturing_rounded, 'color': AppColors.primary},
  {'name': 'Machine Learning', 'courses': 68, 'icon': Icons.psychology_rounded, 'color': AppColors.brandOrange},
  {'name': 'Sustainable Design', 'courses': 35, 'icon': Icons.eco_rounded, 'color': AppColors.brandGreen},
  {'name': 'Computer Vision', 'courses': 28, 'icon': Icons.visibility_rounded, 'color': AppColors.brandAmber},
  {'name': 'Embedded Systems', 'courses': 51, 'icon': Icons.memory_rounded, 'color': AppColors.brandViolet},
  {'name': 'Data Science', 'courses': 73, 'icon': Icons.analytics_rounded, 'color': AppColors.brandTeal},
  {'name': 'IoT', 'courses': 39, 'icon': Icons.wifi_rounded, 'color': AppColors.brandRed},
  {'name': 'Cybersecurity', 'courses': 44, 'icon': Icons.shield_rounded, 'color': const Color(0xFF64748B)},
];
