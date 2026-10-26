import 'package:flutter/material.dart';

import '../../../../core/theme/colors.dart';
import '../../../../core/theme/sizes.dart';
import '../../../../core/widgets/fullscreen_image_viewer.dart';

class ObraCard extends StatelessWidget {
  const ObraCard({
    super.key,
    required this.titulo,
    required this.autores,
    required this.categoria,
    required this.onTap,
    this.capa,
  });

  final String titulo;
  final String autores;
  final String categoria;
  final String? capa;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    const placeholder = ColoredBox(
      color: AppColors.inputBackground,
      child: Center(
        child: Icon(Icons.menu_book, color: AppColors.textSecondary),
      ),
    );

    return Material(
      color: AppColors.cardBackground,
      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: GestureDetector(
                onTap: (capa != null && capa!.isNotEmpty)
                    ? () => abrirVisualizadorImagem(
                          context,
                          imagePath: capa,
                          title: titulo,
                        )
                    : onTap,
                child: Stack(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: double.infinity,
                      child: capa == null || capa!.isEmpty
                          ? placeholder
                          : isPdfCover(capa, null)
                              ? buildPdfCoverThumbnail(label: titulo, compact: true)
                              : (capa!.startsWith('imagens/') || capa!.startsWith('assets/'))
                                  ? Image.asset(
                                      capa!,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, _, _) => placeholder,
                                    )
                                  : Image.network(
                                      capa!,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, _, _) => placeholder,
                                    ),
                    ),
                    if (capa != null && capa!.isNotEmpty)
                      Positioned(
                        bottom: 6,
                        right: 6,
                        child: Container(
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.6),
                            borderRadius: BorderRadius.circular(4),
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
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    categoria.toUpperCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: AppSizes.fontSmall,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: AppSizes.spacingXs),
                  Text(
                    titulo,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: AppSizes.fontBody,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: AppSizes.spacingXs),
                  Text(
                    autores,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: AppSizes.fontSmall,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
