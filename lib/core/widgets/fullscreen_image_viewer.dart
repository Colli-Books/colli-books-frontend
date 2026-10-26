import 'dart:typed_data';
import 'package:flutter/material.dart';

/// Abre a imagem selecionada em tela cheia (lightbox) com suporte a zoom (pinch-to-zoom / duplo toque)
/// e fundo imersivo escuro, preenchendo a tela do celular.
void abrirVisualizadorImagem(
  BuildContext context, {
  String? imagePath,
  Uint8List? coverBytes,
  String? title,
  String? heroTag,
}) {
  final hasBytes = coverBytes != null && coverBytes.isNotEmpty;
  final hasPath = imagePath != null && imagePath.trim().isNotEmpty;
  if (!hasBytes && !hasPath) return;

  Navigator.push(
    context,
    PageRouteBuilder<void>(
      opaque: false,
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.95),
      pageBuilder: (context, animation, secondaryAnimation) {
        return FullscreenImageViewer(
          imagePath: imagePath,
          coverBytes: coverBytes,
          title: title,
          heroTag: heroTag,
        );
      },
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    ),
  );
}

class FullscreenImageViewer extends StatefulWidget {
  final String? imagePath;
  final Uint8List? coverBytes;
  final String? title;
  final String? heroTag;

  const FullscreenImageViewer({
    super.key,
    this.imagePath,
    this.coverBytes,
    this.title,
    this.heroTag,
  });

  @override
  State<FullscreenImageViewer> createState() => _FullscreenImageViewerState();
}

class _FullscreenImageViewerState extends State<FullscreenImageViewer> {
  final TransformationController _transformationController = TransformationController();
  TapDownDetails? _doubleTapDetails;
  bool _showControls = true;

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  void _handleDoubleTap() {
    if (_transformationController.value != Matrix4.identity()) {
      _transformationController.value = Matrix4.identity();
    } else {
      final position = _doubleTapDetails?.localPosition ?? Offset.zero;
      _transformationController.value = Matrix4.identity()
        ..translate(-position.dx * 1.5, -position.dy * 1.5)
        ..scale(2.5);
    }
  }

  Widget _buildImage() {
    final hasBytes = widget.coverBytes != null && widget.coverBytes!.isNotEmpty;
    final path = widget.imagePath;

    Widget img;
    if (hasBytes) {
      img = Image.memory(
        widget.coverBytes!,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => _buildErrorWidget(),
      );
    } else if (path != null && (path.startsWith('imagens/') || path.startsWith('assets/'))) {
      img = Image.asset(
        path,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => _buildErrorWidget(),
      );
    } else if (path != null && path.isNotEmpty) {
      img = Image.network(
        path,
        fit: BoxFit.contain,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white70),
            ),
          );
        },
        errorBuilder: (_, __, ___) => _buildErrorWidget(),
      );
    } else {
      img = _buildErrorWidget();
    }

    if (widget.heroTag != null) {
      return Hero(
        tag: widget.heroTag!,
        child: img,
      );
    }
    return img;
  }

  Widget _buildErrorWidget() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.broken_image_rounded, size: 64, color: Colors.white54),
          SizedBox(height: 12),
          Text(
            'Não foi possível carregar a imagem',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Área da imagem interativa (zoom / pan / toque)
          GestureDetector(
            onTapDown: (details) => _doubleTapDetails = details,
            onDoubleTap: _handleDoubleTap,
            onTap: () {
              setState(() {
                _showControls = !_showControls;
              });
            },
            child: InteractiveViewer(
              transformationController: _transformationController,
              minScale: 1.0,
              maxScale: 5.0,
              child: Center(
                child: _buildImage(),
              ),
            ),
          ),

          // Barra Superior com Botão de Fechar e Título Opcional
          AnimatedOpacity(
            opacity: _showControls ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 200),
            child: SafeArea(
              child: Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Botão Fechar
                      Material(
                        color: Colors.black.withValues(alpha: 0.5),
                        shape: const CircleBorder(),
                        clipBehavior: Clip.antiAlias,
                        child: IconButton(
                          icon: const Icon(Icons.close_rounded, color: Colors.white, size: 26),
                          tooltip: 'Fechar',
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ),
                      if (widget.title != null && widget.title!.isNotEmpty) ...[
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            widget.title!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              shadows: [
                                Shadow(color: Colors.black, blurRadius: 6),
                              ],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(width: 48), // balancear espaço com o botão de fechar
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Dica de gesto na parte inferior
          AnimatedOpacity(
            opacity: _showControls ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 200),
            child: SafeArea(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.pinch_rounded, size: 16, color: Colors.white70),
                      SizedBox(width: 8),
                      Text(
                        'Duplo toque ou pinça para zoom',
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
