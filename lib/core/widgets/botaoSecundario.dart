import 'package:flutter/material.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/sizes.dart';

class BotaoSecundario extends StatelessWidget {
  final String texto;
  final VoidCallback onPressed;
  final IconData? icone;

  const BotaoSecundario({
    super.key,
    required this.texto,
    required this.onPressed,
    this.icone,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: icone != null
          ? ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icone, color: AppColors.textOnDanger, size: 20),
        label: Text(
          texto,
          style: const TextStyle(
            color: AppColors.textOnDanger,
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
            color: AppColors.textOnDanger,
            fontSize: AppSizes.fontBody,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  ButtonStyle _estiloDoBotao() {
    return ElevatedButton.styleFrom(
      backgroundColor: AppColors.danger,
      padding: const EdgeInsets.symmetric(vertical: AppSizes.spacingMd),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      ),
      elevation: 0,
    );
  }
}