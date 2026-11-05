import 'package:flutter/material.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/sizes.dart';

class BotaoPrincipal extends StatelessWidget {
  final String texto;
  final VoidCallback onPressed;
  final IconData? icone;
  final Color backgroundColor;

  const BotaoPrincipal({
    super.key,
    required this.texto,
    required this.onPressed,
    this.icone,
    this.backgroundColor = AppColors.primary,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: icone != null
          ? ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icone, color: AppColors.textOnPrimary, size: 20),
        label: Text(
          texto,
          style: const TextStyle(
            color: AppColors.textOnPrimary,
            fontSize: AppSizes.fontBody,
            fontWeight: FontWeight.bold,
          ),
        ),
        style: _estiloDoBotao(),
      )
          : ElevatedButton(
        onPressed: onPressed,
        style: _estiloDoBotao(),
        child: Text(
          texto,
          style: const TextStyle(
            color: AppColors.textOnPrimary,
            fontSize: AppSizes.fontBody,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  ButtonStyle _estiloDoBotao() {
    return ElevatedButton.styleFrom(
      backgroundColor: backgroundColor,
      padding: const EdgeInsets.symmetric(vertical: AppSizes.spacingMd),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      ),
      elevation: 0,
    );
  }
}