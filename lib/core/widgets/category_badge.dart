import 'package:flutter/material.dart';

import '../theme/colors.dart';
import '../theme/sizes.dart';

class CategoryBadge extends StatelessWidget {
  final String label;

  const CategoryBadge({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.inputBackground,
        borderRadius: BorderRadius.circular(AppSizes.radiusSm),
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          color: AppColors.titleText,
          fontSize: AppSizes.fontSmall,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
