import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/widgets/error_banner.dart';
import '../../../catalogo/data/models/book_models.dart';
import '../../../catalogo/data/services/catalog_api_service.dart';
import '../../../catalogo/presentation/controllers/saved_books_controller.dart';
import '../widgets/obra_list_card.dart';
import 'detalhes_obra_screen.dart';

const _accent = Color(0xFFA1A32D);
const _primaryText = Color(0xFF331212);
const _secondaryText = Color(0xFF8C7A70);

class SelecaoProfessorScreen extends StatefulWidget {
  const SelecaoProfessorScreen({
    super.key,
    required this.active,
    required this.onExplorar,
  });

  /// A aba fica viva dentro do IndexedStack; ao voltar a ela, recarrega
  /// (obras salvas no catálogo nesse meio-tempo entram na lista).
  final bool active;

  /// Leva o professor à aba do catálogo (botão do estado vazio).
  final VoidCallback onExplorar;

  @override
  State<SelecaoProfessorScreen> createState() => _SelecaoProfessorScreenState();
}

class _SelecaoProfessorScreenState extends State<SelecaoProfessorScreen> {
  late final CatalogApiService _service;
  late final SavedBooksController _saved;

  List<BookSummary> _items = const [];
  ApiException? _error;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _service = context.read<CatalogApiService>();
    _saved = context.read<SavedBooksController>();
    _load();
  }

  @override
  void didUpdateWidget(SelecaoProfessorScreen old) {
    super.didUpdateWidget(old);
    if (widget.active && !old.active) _load(showSpinner: false);
  }

  Future<void> _load({bool showSpinner = true}) async {
    if (showSpinner) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }
    try {
      final list = await _service.listSavedBooks();
      if (!mounted) return;
      _saved.markSaved([for (final b in list) b.id]); // tudo aqui está salvo
      setState(() {
        _items = list;
        _error = null;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _error = e);
    } catch (e, st) {
      debugPrint('Falha inesperada ao carregar a seleção: $e\n$st');
      if (!mounted) return;
      setState(() => _error = ApiException.unexpected('$e'));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading && _items.isEmpty) {
      return const Center(child: CircularProgressIndicator(color: _accent));
    }

    final error = _error;
    if (error != null && _items.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: ErrorBanner(message: error.message, onRetry: _load),
      );
    }

    // Quem foi removido (aqui ou no catálogo) some na hora, sem recarregar.
    return ListenableBuilder(
      listenable: _saved,
      builder: (context, _) {
        final visible = [for (final b in _items) if (_saved.isSaved(b.id)) b];
        if (visible.isEmpty) return _buildEmpty();

        return RefreshIndicator(
          onRefresh: _load,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (error != null)
                  ErrorBanner(message: error.message, onRetry: _load),
                Text(
                  'Minha Seleção (${visible.length})',
                  style: const TextStyle(
                    color: _primaryText,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Livros selecionados para suas turmas e planos de aula.',
                  style: TextStyle(color: _secondaryText, fontSize: 14),
                ),
                const SizedBox(height: 20),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: visible.length,
                  itemBuilder: (context, index) {
                    final book = visible[index];
                    return ObraListCard(
                      key: ValueKey(book.id),
                      book: book,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute<void>(
                          builder: (_) => DetalhesObraScreen(bookId: book.id),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Color(0xFFEBE8E0),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.bookmark_outline, size: 56, color: _accent),
            ),
            const SizedBox(height: 20),
            const Text(
              'Sua Seleção está vazia',
              style: TextStyle(color: _primaryText, fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Navegue pelo acervo de ColliBooks e salve as obras que deseja utilizar em seus projetos pedagógicos.',
              textAlign: TextAlign.center,
              style: TextStyle(color: _secondaryText, fontSize: 14, height: 1.4),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: widget.onExplorar,
              style: ElevatedButton.styleFrom(
                backgroundColor: _accent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text(
                'Explorar Obras',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}