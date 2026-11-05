import 'package:flutter/material.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/sizes.dart';

class BotaoTerciario extends StatelessWidget {
  final VoidCallback onPressed;
  final String? texto;
  final IconData? icone;
  final Color? cor;
  final bool isVertical;

  const BotaoTerciario({
    super.key,
    required this.onPressed,
    this.texto,
    this.icone,
    this.cor,
    this.isVertical = false,
  }) : assert(texto != null || icone != null, 'O botão terciário deve ter texto ou ícone.');

  @override
  Widget build(BuildContext context) {
    final Color currentColor = cor ?? AppColors.titleText;

    // Apenas um ícone
    if (texto == null && icone != null) {
      return IconButton(
        onPressed: onPressed,
        icon: Icon(icone, color: currentColor, size: 20),
        splashRadius: 20,
        padding: const EdgeInsets.all(AppSizes.spacingSm),
        constraints: const BoxConstraints(),
      );
    }

    // Formato vertical
    if (isVertical && icone != null && texto != null) {
      return InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(AppSizes.radiusSm),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: AppSizes.spacingSm,
            horizontal: AppSizes.spacingMd,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icone, color: currentColor, size: 24),
              const SizedBox(height: AppSizes.spacingXs),
              Text(
                texto!,
                style: TextStyle(
                  color: currentColor,
                  fontSize: AppSizes.fontSmall,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      );
    }
    // Formato horizontal
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: currentColor,
        padding: const EdgeInsets.symmetric(
          vertical: AppSizes.spacingSm,
          horizontal: AppSizes.spacingMd,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusSm),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icone != null) ...[
            Icon(icone, size: 18),
            const SizedBox(width: AppSizes.spacingSm),
          ],
          if (texto != null)
            Text(
              texto!,
              style: const TextStyle(
                fontSize: AppSizes.fontBody,
                fontWeight: FontWeight.w600,
              ),
            ),
        ],
      ),
    );
  }
}