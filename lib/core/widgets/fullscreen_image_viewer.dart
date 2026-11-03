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

/// Detecta se o arquivo/recurso de capa é um documento PDF (por extensão ou magic bytes %PDF).
bool isPdfCover(String? path, Uint8List? bytes) {
  if (path != null && path.toLowerCase().endsWith('.pdf')) {
    return true;
  }
  if (bytes != null && bytes.length >= 4) {
    if (bytes[0] == 0x25 && bytes[1] == 0x50 && bytes[2] == 0x44 && bytes[3] == 0x46) {
      return true;
    }
  }
  return false;
}

/// Constrói um cartão visual estilizado representando a 1ª página do arquivo PDF carregado.
Widget buildPdfCoverThumbnail({
  double width = 170,
  double height = 250,
  String? label,
  bool compact = false,
}) {
  return Container(
    width: width,
    height: height,
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF8B2522), Color(0xFF5A1412)],
      ),
      borderRadius: BorderRadius.circular(compact ? 6 : 10),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.2),
          blurRadius: compact ? 4 : 8,
          offset: const Offset(0, 3),
        ),
      ],
    ),
    child: Stack(
      children: [
        Positioned(
          left: 0,
          top: 0,
          bottom: 0,
          width: compact ? 6 : 12,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.25),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(compact ? 6 : 10),
                bottomLeft: Radius.circular(compact ? 6 : 10),
              ),
            ),
          ),
        ),
        Center(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: compact ? 4 : 12,
              vertical: compact ? 6 : 16,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.all(compact ? 6 : 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.picture_as_pdf_rounded,
                    color: Colors.white,
                    size: compact ? 22 : 40,
                  ),
                ),
                SizedBox(height: compact ? 4 : 10),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: compact ? 4 : 8,
                    vertical: compact ? 2 : 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'PDF • 1ª PÁGINA',
                    style: TextStyle(
                      color: const Color(0xFF8B2522),
                      fontSize: compact ? 8 : 10,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                if (!compact && label != null && label.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
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

    if (isPdfCover(path, widget.coverBytes)) {
      return _buildPdfFullscreen();
    }

    Widget img;
    if (hasBytes) {
      img = Image.memory(
        widget.coverBytes!,
        fit: BoxFit.contain,
        errorBuilder: (_, _, _) => _buildErrorWidget(),
      );
    } else if (path != null && (path.startsWith('imagens/') || path.startsWith('assets/'))) {
      img = Image.asset(
        path,
        fit: BoxFit.contain,
        errorBuilder: (_, _, _) => _buildErrorWidget(),
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
        errorBuilder: (_, _, _) => _buildErrorWidget(),
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

  Widget _buildPdfFullscreen() {
    final name = widget.title ?? widget.imagePath ?? 'Documento PDF';
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 360, maxHeight: 520),
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFD32F2F).withValues(alpha: 0.6), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.6),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFD32F2F).withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.picture_as_pdf_rounded,
                color: Color(0xFFEF5350),
                size: 64,
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFD32F2F),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                'ARQUIVO PDF CARREGADO',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            const Text(
              'A primeira página deste arquivo PDF será processada e utilizada como capa da obra.',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 13,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            if (widget.coverBytes != null && widget.coverBytes!.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                'Tamanho: ${(widget.coverBytes!.lengthInBytes / (1024 * 1024)).toStringAsFixed(2)} MB',
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 12,
                ),
              ),
            ],
          ],
        ),
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
