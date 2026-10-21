import 'package:flutter/material.dart';

import '../theme/colors.dart';
import '../theme/sizes.dart';

class CampoBusca extends StatelessWidget {
  final String hintText;
  final ValueChanged<String>? onChanged;

  const CampoBusca({super.key, this.hintText = 'Buscar...', this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.inputBackground,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(color: AppColors.border),
      ),
      child: TextField(
        onChanged: onChanged,
        style: const TextStyle(
          fontSize: AppSizes.fontBody,
          color: AppColors.textPrimary,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(
            fontSize: AppSizes.fontBody,
            color: AppColors.textSecondary,
          ),
          prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSizes.spacingMd,
            vertical:
                14.0, // Altura fixa para centralizar bem o ícone com o texto
          ),
        ),
      ),
    );
  }
}
