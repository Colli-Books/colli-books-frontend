import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/widgets/error_banner.dart';
import '../../../../core/widgets/pick_one_dialog.dart';
import '../../../catalogo/data/services/catalog_api_service.dart';
import '../../../catalogo/presentation/controllers/books_controller.dart';
import '../../../catalogo/presentation/controllers/catalog_options_controller.dart';
import '../../../catalogo/presentation/controllers/saved_books_controller.dart';
import '../widgets/obra_list_card.dart';
import 'detalhes_obra_screen.dart';

const _accent = Color(0xFFA1A32D);
const _secondaryText = Color(0xFF8C7A70);

class CatalogoProfessorView extends StatefulWidget {
  const CatalogoProfessorView({super.key});

  @override
  State<CatalogoProfessorView> createState() => _CatalogoProfessorViewState();
}

class _CatalogoProfessorViewState extends State<CatalogoProfessorView> {
  late final BooksController _books;
  late final CatalogOptionsController _options;

  @override
  void initState() {
    super.initState();
    final service = context.read<CatalogApiService>();
    final saved = context.read<SavedBooksController>();
    // Cada lista carregada alimenta o estado compartilhado de "salva".
    _books = BooksController(service, onLoaded: saved.sync)..load();
    _options = CatalogOptionsController(service)..load();
  }

  @override
  void dispose() {
    _books.dispose();
    _options.dispose();
    super.dispose();
  }

  Future<void> _reload() => Future.wait([_books.load(), _options.load()]);

  Future<void> _filtrarEscolaridade() async {
    final r = await showPickOneDialog(
      context,
      title: 'Filtrar por Escolaridade',
      allLabel: 'Todas as escolaridades',
      emptyMessage: 'Nenhuma escolaridade cadastrada.',
      options: [for (final l in _options.levels) (id: l.id, name: l.name)],
      selectedId: _books.levelId,
    );
    if (r != null) _books.setLevel(r.id);
  }

  Future<void> _filtrarTema() async {
    final r = await showPickOneDialog(
      context,
      title: 'Filtrar por Tema',
      allLabel: 'Todos os temas',
      emptyMessage: 'Nenhum tema cadastrado.',
      options: [for (final t in _options.themes) (id: t.id, name: t.name)],
      selectedId: _books.themeId,
    );
    if (r != null) _books.setTheme(r.id);
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _reload,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Fora do ListenableBuilder: digitar não reconstrói o campo.
            TextField(
              onChanged: _books.setQuery, // debounce de 400 ms no controller
              decoration: InputDecoration(
                hintText: 'Buscar por título ou autor...',
                hintStyle: const TextStyle(color: _secondaryText, fontSize: 14),
                prefixIcon: const Icon(Icons.search, color: _secondaryText),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFEBE8E0)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFEBE8E0)),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                  borderSide: BorderSide(color: _accent),
                ),
              ),
            ),
            const SizedBox(height: 16),
            ListenableBuilder(
              listenable: Listenable.merge([_books, _options]),
              builder: (context, _) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_options.error != null)
                    ErrorBanner(
                      message: 'Não foi possível carregar os filtros. ${_options.error!.message}',
                      onRetry: _options.load,
                    ),
                  _buildFilters(),
                  const SizedBox(height: 24),
                  _buildResults(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilters() {
    final ready = !_options.isLoading && _options.error == null;
    final levelName =
        _options.levels.where((l) => l.id == _books.levelId).map((l) => l.name).firstOrNull;
    final themeName =
        _options.themes.where((t) => t.id == _books.themeId).map((t) => t.name).firstOrNull;

    return Row(
      children: [
        Expanded(
          child: _filterButton(levelName ?? 'Escolaridades', levelName != null,
              ready ? _filtrarEscolaridade : null),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _filterButton(themeName ?? 'Temas', themeName != null,
              ready ? _filtrarTema : null),
        ),
      ],
    );
  }

  Widget _filterButton(String label, bool active, VoidCallback? onPressed) {
    return OutlinedButton.icon(
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        side: BorderSide(
          color: active ? _accent : const Color(0xFFEBE8E0),
          width: active ? 1.5 : 1,
        ),
        backgroundColor: Colors.white,
      ),
      icon: const Icon(Icons.filter_list, size: 16, color: Color(0xFF4A2525)),
      label: Text(
        label,
        style: const TextStyle(color: Color(0xFF4A2525), fontSize: 12, fontWeight: FontWeight.bold),
        overflow: TextOverflow.ellipsis,
      ),
      onPressed: onPressed,
    );
  }

  Widget _buildResults() {
    final error = _books.error;
    if (error != null) {
      return ErrorBanner(message: error.message, onRetry: _books.load);
    }

    final items = _books.items;
    if (_books.isLoading && items.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(32),
        child: Center(child: CircularProgressIndicator(color: _accent)),
      );
    }

    if (_books.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 48),
          child: Column(
            children: [
              const Icon(Icons.search_off, size: 48, color: _secondaryText),
              const SizedBox(height: 12),
              Text(
                _books.hasFilters
                    ? 'Nenhuma obra encontrada para esta pesquisa.'
                    : 'Nenhuma obra cadastrada ainda.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: _secondaryText, fontSize: 14),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_books.isLoading) const LinearProgressIndicator(minHeight: 2),
        const SizedBox(height: 8),
        Text(
          '${items.length} obra(s) encontrada(s)',
          style: const TextStyle(color: _secondaryText, fontSize: 14, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final book = items[index];
            return ObraListCard(
              key: ValueKey(book.id),
              book: book,
              highlightThemeId: _books.themeId,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute<void>(builder: (_) => DetalhesObraScreen(bookId: book.id)),
              ),
            );
          },
        ),
      ],
    );
  }
}