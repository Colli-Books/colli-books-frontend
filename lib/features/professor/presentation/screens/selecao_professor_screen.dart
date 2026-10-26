import 'dart:typed_data';
import 'package:flutter/material.dart';

import '../../../../core/theme/colors.dart';
import '../../../../core/theme/sizes.dart';
import '../../../../core/widgets/fullscreen_image_viewer.dart';
import 'detalhes_obra_screen.dart';

class SelecaoProfessorScreen extends StatelessWidget {
  final List<Map<String, dynamic>> selecionados;
  final Function(Map<String, dynamic>) onRemove;

  const SelecaoProfessorScreen({
    super.key,
    required this.selecionados,
    required this.onRemove,
  });

  void _confirmarRemocao(BuildContext context, Map<String, dynamic> obra) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text(
          'Remover Obra',
          style: TextStyle(
            color: AppColors.titleText,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Deseja realmente remover "${obra['titulo'] ?? 'esta obra'}" da sua seleção?',
          style: const TextStyle(color: AppColors.textPrimary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: () {
              Navigator.pop(ctx);
              onRemove(obra);
            },
            child: const Text('Remover', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (selecionados.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bookmark_border, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            const Text(
              'Sua seleção está vazia.',
              style: TextStyle(
                fontSize: AppSizes.fontSubTitle,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Navegue pelo catálogo para adicionar obras.',
              style: TextStyle(
                fontSize: AppSizes.fontSmall,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(AppSizes.spacingLg),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Obras Selecionadas',
                    style: TextStyle(
                      fontSize: AppSizes.fontHeading,
                      fontWeight: FontWeight.w800,
                      color: AppColors.titleText,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Material reservado para uso pedagógico.',
                    style: TextStyle(
                      fontSize: AppSizes.fontSmall,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${selecionados.length} ${selecionados.length == 1 ? 'Item' : 'Itens'}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: AppSizes.fontSmall,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.spacingLg),
            itemCount: selecionados.length,
            itemBuilder: (context, index) {
              final obra = selecionados[index];

              // Recupera as tags cadastradas de forma segura
              final rawTags = obra['tags'];
              final List<String> tags = rawTags is List
                  ? rawTags.map((e) => e.toString()).toList()
                  : [
                      obra['tagEscolar']?.toString() ?? 'Ensino Fundamental',
                      obra['tagTematica']?.toString() ?? 'História',
                    ];

              return Container(
                margin: const EdgeInsets.only(bottom: AppSizes.spacingMd),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Capa da Obra
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(AppSizes.radiusMd),
                      ),
                      child: GestureDetector(
                        onTap: () => abrirVisualizadorImagem(
                          context,
                          imagePath: (obra['capa'] ?? obra['image'])?.toString(),
                          coverBytes: obra['coverBytes'] as Uint8List?,
                          title: (obra['titulo'] ?? obra['title'])?.toString(),
                        ),
                        child: Stack(
                          children: [
                            SizedBox(
                              height: 200,
                              width: double.infinity,
                              child: () {
                                final capaStr = (obra['capa'] ?? obra['image'])?.toString();
                                final coverBytes = obra['coverBytes'] as Uint8List?;
                                final titulo = (obra['titulo'] ?? obra['title'])?.toString();
                                if (isPdfCover(capaStr, coverBytes)) {
                                  return buildPdfCoverThumbnail(
                                    width: double.infinity,
                                    height: 200,
                                    label: titulo,
                                  );
                                }
                                if (coverBytes != null && coverBytes.isNotEmpty) {
                                  return Image.memory(coverBytes, fit: BoxFit.cover);
                                }
                                if (capaStr != null && capaStr.isNotEmpty) {
                                  if (capaStr.startsWith('imagens/') || capaStr.startsWith('assets/')) {
                                    return Image.asset(capaStr, fit: BoxFit.cover);
                                  }
                                  return Image.network(capaStr, fit: BoxFit.cover);
                                }
                                return Container(
                                  color: Colors.grey.shade300,
                                  child: const Center(
                                    child: Icon(
                                      Icons.menu_book,
                                      size: 48,
                                      color: Colors.grey,
                                    ),
                                  ),
                                );
                              }(),
                            ),
                            Positioned(
                              bottom: 8,
                              right: 8,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.65),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Icon(Icons.fullscreen_rounded, size: 14, color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(AppSizes.spacingMd),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Tags dinâmicas da obra
                          Wrap(
                            spacing: 8,
                            runSpacing: 4,
                            children: tags.map((tag) {
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEADCC9),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  tag,
                                  style: const TextStyle(
                                    color: AppColors.titleText,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: AppSizes.spacingSm),
                          // Título
                          Text(
                            obra['titulo']?.toString() ?? 'Sem título',
                            style: const TextStyle(
                              color: AppColors.titleText,
                              fontSize: AppSizes.fontTitle,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 4),
                          // Autor
                          Text(
                            obra['autores']?.toString() ??
                                obra['autor']?.toString() ??
                                'Sem autor',
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: AppSizes.fontSmall,
                            ),
                          ),
                          const SizedBox(height: AppSizes.spacingMd),
                          // Botões de Ação (Ver Detalhes + Lixeira)
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                        AppSizes.radiusSm,
                                      ),
                                    ),
                                  ),
                                  icon: const Icon(
                                    Icons.remove_red_eye_outlined,
                                    size: 18,
                                  ),
                                  label: const Text('Ver Detalhes'),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            DetalhesObraScreen(obra: obra),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(width: AppSizes.spacingSm),
                              IconButton(
                                style: IconButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      AppSizes.radiusSm,
                                    ),
                                    side: const BorderSide(
                                      color: AppColors.border,
                                    ),
                                  ),
                                  padding: const EdgeInsets.all(12),
                                ),
                                icon: const Icon(
                                  Icons.delete_outline,
                                  color: AppColors.danger,
                                ),
                                onPressed: () =>
                                    _confirmarRemocao(context, obra),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
