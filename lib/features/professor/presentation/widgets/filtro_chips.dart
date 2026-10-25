import 'package:flutter/material.dart';

import '../../../../core/theme/colors.dart';
import '../../../../core/theme/sizes.dart';

class FiltroChips extends StatelessWidget {
  const FiltroChips({
    super.key,
    required this.opcoes,
    required this.selecionado,
    required this.onSelecionado,
  });

  final List<String> opcoes;
  final String? selecionado;
  final ValueChanged<String> onSelecionado;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final opcao in opcoes)
            Padding(
              padding: const EdgeInsets.only(right: AppSizes.spacingSm),
              child: ChoiceChip(
                label: Text(opcao),
                selected: opcao == selecionado,
                onSelected: (_) => onSelecionado(opcao),
                showCheckmark: false,
                backgroundColor: AppColors.surface,
                selectedColor: AppColors.primary,
                side: const BorderSide(color: AppColors.border),
                shape: const StadiumBorder(),
                labelStyle: TextStyle(
                  color: opcao == selecionado
                      ? AppColors.textOnPrimary
                      : AppColors.textPrimary,
                  fontSize: AppSizes.fontBody,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
