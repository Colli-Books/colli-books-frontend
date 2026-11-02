import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/widgets/fullscreen_image_viewer.dart';
import '../../../catalogo/data/models/book_models.dart';
import '../../../catalogo/presentation/controllers/saved_books_controller.dart';

const _accent = Color(0xFFA1A32D);

class ObraListCard extends StatefulWidget {
  const ObraListCard({
    super.key,
    required this.book,
    required this.onTap,
    this.highlightThemeId,
  });

  final BookSummary book;
  final VoidCallback onTap;

  /// Tema filtrado: continua visível mesmo fora dos 4 primeiros chips.
  final int? highlightThemeId;

  @override
  State<ObraListCard> createState() => _ObraListCardState();
}

class _ObraListCardState extends State<ObraListCard> {
  bool _expanded = false;

  Future<void> _toggleSaved() async {
    final controller = context.read<SavedBooksController>();
    final messenger = ScaffoldMessenger.of(context); // antes do await
    final title = widget.book.title;

    final error = await controller.toggle(widget.book.id);
    final nowSaved = controller.isSaved(widget.book.id);

    messenger.showSnackBar(
      SnackBar(
        content: Text(
          error != null
              ? SavedBooksController.messageFor(error)
              : nowSaved
              ? '"$title" adicionado à sua Seleção!'
              : '"$title" removido da sua Seleção.',
        ),
        duration: const Duration(seconds: 2),
        backgroundColor: error != null || !nowSaved
            ? const Color(0xFFC62828)
            : _accent,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final book = widget.book;
    final saved = context.watch<SavedBooksController>();
    final isSaved = saved.isSaved(book.id);
    final pending = saved.isPending(book.id);
    final coverUrl = book.coverUri;

    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFF3EFE4),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFEBE8E0)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCover(coverUrl),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            book.title,
                            style: const TextStyle(
                              color: Color(0xFF331212),
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFFEBE8E0)),
                          ),
                          child: Tooltip(
                            message: isSaved ? 'Remover da Seleção' : 'Salvar na Seleção',
                            child: InkWell(
                              onTap: pending ? null : _toggleSaved,
                              child: Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: Icon(
                                  isSaved ? Icons.bookmark : Icons.bookmark_outline,
                                  size: 18,
                                  color: isSaved ? _accent : const Color(0xFF4A2525),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      book.author,
                      style: const TextStyle(
                        color: Color(0xFF8C7A70),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 12),
                    if (book.educationLevel != null) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFD4E6F1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          book.educationLevel!.name,
                          style: const TextStyle(
                            fontSize: 10,
                            color: Color(0xFF1F618D),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                    ],
                    _buildThemeChips(book),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCover(String? coverUrl) {
    const placeholder = Center(
      child: Icon(Icons.menu_book, color: _accent, size: 40),
    );

    final box = Container(
      width: 100,
      height: 140,
      margin: const EdgeInsets.all(8),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: const Color(0xFFEBE8E0),
        borderRadius: BorderRadius.circular(8),
      ),
      child: coverUrl == null
          ? placeholder
          : Image.network(
        coverUrl,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => placeholder,
      ),
    );
    if (coverUrl == null) return box; // sem capa: nada para abrir em tela cheia

    return GestureDetector(
      onTap: () => abrirVisualizadorImagem(
        context,
        imagePath: coverUrl,
        title: widget.book.title,
      ),
      child: Tooltip(
        message: 'Toque para ver a imagem em tela cheia',
        child: Stack(
          children: [
            box,
            Positioned(
              bottom: 12,
              right: 12,
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
    );
  }

  Widget _buildThemeChips(BookSummary book) {
    final themes = book.themes;
    final extraMatches = themes
        .skip(4)
        .where((t) => t.id == widget.highlightThemeId)
        .toList();
    final displayed = _expanded ? themes : [...themes.take(4), ...extraMatches];
    final remaining = themes.length - displayed.length;

    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        for (final t in displayed)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFFDEBD0),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              t.name,
              style: const TextStyle(
                fontSize: 10,
                color: Color(0xFFD35400),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        if (remaining > 0 && !_expanded)
          _toggle('+$remaining', Icons.add, bold: true, onTap: () => setState(() => _expanded = true)),
        if (_expanded && themes.length > 4)
          _toggle('Ver menos', Icons.remove, onTap: () => setState(() => _expanded = false)),
      ],
    );
  }

  Widget _toggle(String label, IconData icon, {required VoidCallback onTap, bool bold = false}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFFFCE4D6),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFE59866), width: 0.8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: const Color(0xFFBA4A00),
                fontWeight: bold ? FontWeight.w800 : FontWeight.bold,
              ),
            ),
            const SizedBox(width: 2),
            Icon(icon, size: 12, color: const Color(0xFFBA4A00)),
          ],
        ),
      ),
    );
  }
}