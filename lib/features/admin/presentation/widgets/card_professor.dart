import 'package:flutter/material.dart';

import '../../../../core/theme/colors.dart';
import '../../../../core/theme/sizes.dart';

class CardProfessor extends StatelessWidget {
  final Map<String, dynamic> prof;
  final VoidCallback? onDelete; // 👈 Callback parameter to notify parent

  const CardProfessor({
    super.key,
    required this.prof,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isAtivo = prof['status'] == 'Ativo';

    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.spacingMd),
      padding: const EdgeInsets.all(AppSizes.spacingLg),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppSizes.spacingMd),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundColor: AppColors.inputBackground,
                radius: AppSizes.radiusXl,
                child: Text(
                  prof['iniciais'] ?? '',
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: AppSizes.spacingLg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      prof['nome'] ?? '',
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: AppSizes.fontTitle,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    if (isAtivo && prof['email'] != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        prof['email']!,
                        style: const TextStyle(
                          color: AppColors.textSecondary, // 👈 Using textSecondary
                          fontSize: AppSizes.fontSmall,
                        ),
                      ),
                    ],
                    if (prof['escola'] != null && prof['escola']!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.school_outlined,
                            size: AppSizes.fontBody,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              prof['escola']!,
                              style: const TextStyle(
                                color: AppColors.textSecondary, // 👈 Using textSecondary
                                fontSize: AppSizes.fontSmall,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: isAtivo
                          ? AppColors.activeBadgeBg
                          : AppColors.pendingBadgeBg,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.circle,
                          size: 8,
                          color: isAtivo
                              ? AppColors.activeBadgeText
                              : AppColors.pendingBadgeText,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          prof['status'] ?? '',
                          style: TextStyle(
                            color: isAtivo
                                ? AppColors.activeBadgeText
                                : AppColors.pendingBadgeText,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isAtivo) ...[
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Excluir Professor'),
                            content: Text(
                              'Tem certeza que deseja excluir "${prof['nome']}"?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Cancelar'),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  onDelete?.call(); // 👈 Trigger parent delete callback!
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Professor excluído!'),
                                      backgroundColor: AppColors.danger,
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.danger,
                                ),
                                child: const Text(
                                  'Excluir',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                      child: const Padding(
                        padding: EdgeInsets.all(4.0),
                        child: Icon(
                          Icons.delete_outline,
                          size: 20,
                          color: AppColors.danger,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: AppColors.border, height: 1),
          const SizedBox(height: 16),
          Text(
            prof['data'] ?? '',
            style: const TextStyle(
              color: AppColors.textSecondary, // 👈 Using textSecondary
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}