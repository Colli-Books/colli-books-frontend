import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/colors.dart';
import '../../../../core/theme/sizes.dart';
import '../../../../core/widgets/error_banner.dart';
import '../../../../core/widgets/fullscreen_image_viewer.dart';
import '../../../catalogo/data/models/book_models.dart';
import '../../../catalogo/data/services/catalog_api_service.dart';
import '../../../catalogo/presentation/controllers/books_controller.dart';
import '../../../catalogo/presentation/controllers/catalog_options_controller.dart';
import 'cadastrar_escolaridade_screen.dart';
import 'cadastrar_obra_screen.dart';
import 'cadastrar_tema_screen.dart';
import 'editar_obra_screen.dart';

class CatalogoObrasAdminScreen extends StatefulWidget {
  const CatalogoObrasAdminScreen({super.key});

  @override
  State<CatalogoObrasAdminScreen> createState() => _CatalogoObrasAdminScreenState();
}

class _CatalogoObrasAdminScreenState extends State<CatalogoObrasAdminScreen> {
  // Vivem só enquanto a tela existe: nada de catálogo em memória após o logout.
  late final BooksController _books;
  late final CatalogOptionsController _options;

  final Set<int> _expandedThemes = {}; // ids de obras com a lista de temas expandida

  @override
  void initState() {
    super.initState();
    final service = context.read<CatalogApiService>();
    _books = BooksController(service)..load();
    _options = CatalogOptionsController(service)..load();
  }

  @override
  void dispose() {
    _books.dispose();
    _options.dispose();
    super.dispose();
  }

  Future<void> _reloadAll() async {
    await Future.wait([_books.load(), _options.load()]);
  }

  /// Abre uma tela de cadastro/edição e recarrega tudo ao voltar, com qualquer
  /// resultado (o botão voltar do sistema devolve null). Recarregar também as
  /// opções cobre temas/escolaridades recém-criados ou renomeados.
  Future<void> _abrir(Widget screen) async {
    await Navigator.push<Object?>(
      context,
      MaterialPageRoute<Object?>(builder: (_) => screen),
    );
    if (mounted) _reloadAll();
  }

  // --- Filtros (seleção única) ------------------------------------------------

  Future<void> _filtrarEscolaridade() async {
    final result = await _pickOne(
      title: 'Filtrar por Escolaridade',
      allLabel: 'Todas as escolaridades',
      emptyMessage: 'Nenhuma escolaridade cadastrada.',
      options: [for (final l in _options.levels) (id: l.id, name: l.name)],
      selectedId: _books.levelId,
    );
    if (result != null) _books.setLevel(result.id);
  }

  Future<void> _filtrarTema() async {
    final result = await _pickOne(
      title: 'Filtrar por Tema',
      allLabel: 'Todos os temas',
      emptyMessage: 'Nenhum tema cadastrado.',
      options: [for (final t in _options.themes) (id: t.id, name: t.name)],
      selectedId: _books.themeId,
    );
    if (result != null) _books.setTheme(result.id);
  }

  /// Devolve null se o usuário cancelou, e `(id: null)` se escolheu "todos".
  Future<({int? id})?> _pickOne({
    required String title,
    required String allLabel,
    required String emptyMessage,
    required List<({int id, String name})> options,
    required int? selectedId,
  }) {
    return showDialog<({int? id})>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFFF9F5EC),
        title: Text(
          title,
          style: const TextStyle(color: Color(0xFF4A2525), fontWeight: FontWeight.bold, fontSize: 18),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: options.isEmpty
              ? Text(emptyMessage)
              : ListView(
            shrinkWrap: true,
            children: [
              ListTile(
                key: const ValueKey('pick_option_all'),
                title: Text(allLabel, style: const TextStyle(color: Color(0xFF6B6B6B))),
                trailing: selectedId == null
                    ? const Icon(Icons.check, color: Color(0xFFA1A32D))
                    : null,
                onTap: () => Navigator.pop(dialogContext, (id: null)),
              ),
              for (final o in options)
                ListTile(
                  key: ValueKey('pick_option_${o.id}'),
                  title: Text(o.name, style: const TextStyle(color: Color(0xFF4A2525))),
                  trailing: o.id == selectedId
                      ? const Icon(Icons.check, color: Color(0xFFA1A32D))
                      : null,
                  onTap: () => Navigator.pop(dialogContext, (id: o.id)),
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
          ),
        ],
      ),
    );
  }

  // --- UI -------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _reloadAll,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.spacingLg,
          vertical: AppSizes.spacingLg,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Catálogo de Obras',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: AppSizes.spacingLg,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: AppSizes.spacingSm),
            Text(
              'Gerencie o acervo literário da plataforma.',
              style: TextStyle(color: AppColors.textSecondary, fontSize: AppSizes.fontBody),
            ),
            const SizedBox(height: AppSizes.spacingLg),

            _addButton('Adicionar Nova Obra', () => _abrir(const CadastrarObraScreen())),
            const SizedBox(height: AppSizes.spacingMd),
            _addButton('Adicionar Escolaridade', () => _abrir(const CadastrarEscolaridadeScreen())),
            const SizedBox(height: AppSizes.spacingMd),
            _addButton('Adicionar Tema', () => _abrir(const CadastrarTemaScreen())),
            const SizedBox(height: AppSizes.spacingLg),

            // Fora do ListenableBuilder: digitar não reconstrói o campo.
            TextField(
              key: const ValueKey('catalog_search'),
              onChanged: _books.setQuery, // debounce de 400 ms no controller
              decoration: InputDecoration(
                hintText: 'Buscar por título ou autor...',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFEBE8E0)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFEBE8E0)),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            const SizedBox(height: 12),

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
                  const SizedBox(height: AppSizes.spacingLg),
                  _buildResults(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _addButton(String label, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          label,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.spacingLg)),
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
          child: _filterButton(
            label: levelName ?? 'Escolaridades',
            active: levelName != null,
            onPressed: ready ? _filtrarEscolaridade : null,
            key: const ValueKey('catalog_filter_level')
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _filterButton(
            label: themeName ?? 'Temas',
            active: themeName != null,
            onPressed: ready ? _filtrarTema : null,
            key: const ValueKey('catalog_filter_theme')
          ),
        ),
      ],
    );
  }

  Widget _filterButton({
    required String label,
    required bool active,
    required VoidCallback? onPressed,
    Key? key,
  }) {
    return OutlinedButton.icon(
      key: key,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        side: BorderSide(
          color: active ? AppColors.primary : const Color(0xFFEBE8E0),
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
        child: Center(child: CircularProgressIndicator()),
      );
    }

    // Sem resultado não é erro: é um estado vazio.
    if (_books.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Text(
            _books.hasFilters
                ? 'Nenhuma obra encontrada com esses filtros.'
                : 'Nenhuma obra cadastrada ainda.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary, fontSize: AppSizes.fontBody),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_books.isLoading) const LinearProgressIndicator(minHeight: 2), // atualizando
        const SizedBox(height: AppSizes.spacingSm),
        Text(
          '${items.length} obra(s) encontrada(s)',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: AppSizes.fontBody,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppSizes.spacingMd),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          itemBuilder: (context, index) => _buildBookCard(items[index]),
        ),
      ],
    );
  }

  // --- Cartão da obra ---------------------------------------------------------

  Widget _buildCover(BookSummary book) {
    final url = book.coverUri;
    final box = Container(
      width: 100,
      height: 140,
      margin: const EdgeInsets.all(8),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(8),
      ),
      child: _coverImage(url),
    );
    if (url == null) return box; // sem capa: nada para abrir em tela cheia

    return GestureDetector(
      onTap: () => abrirVisualizadorImagem(
        context,
        imagePath: url,
        coverBytes: null,
        title: book.title,
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

  Widget _coverImage(String? url) {
    const placeholder = Center(child: Icon(Icons.menu_book, size: 32, color: Colors.grey));
    if (url == null) return placeholder;
    return Image.network(
      url,
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => placeholder,
      loadingBuilder: (context, child, progress) => progress == null
          ? child
          : const Center(
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    );
  }

  Widget _buildBookCard(BookSummary book) {
    final level = book.educationLevel;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.spacingMd),
      decoration: BoxDecoration(
        color: const Color(0xFFF3EFE4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCover(book),
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
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFEBE8E0)),
                        ),
                        child: Tooltip(
                          message: 'Editar obra',
                          child: InkWell(
                            key: ValueKey('book_edit_${book.id}'),
                            onTap: () => _abrir(EditarObraScreen(bookId: book.id)),
                            child: const Padding(
                              padding: EdgeInsets.all(2.0),
                              child: Icon(Icons.edit, size: 16, color: Color(0xFF4A2525)),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    book.author,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  if (level != null) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD4E6F1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        level.name,
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
    );
  }

  Widget _buildThemeChips(BookSummary book) {
    final themes = book.themes;
    final isExpanded = _expandedThemes.contains(book.id);

    // Tema filtrado que não está entre os 4 primeiros continua visível.
    final filterId = _books.themeId;
    final extraMatches = themes.skip(4).where((t) => t.id == filterId).toList();

    final displayed = isExpanded ? themes : [...themes.take(4), ...extraMatches];
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
        if (remaining > 0 && !isExpanded)
          _themeToggle(
            label: '+$remaining',
            icon: Icons.add,
            bold: true,
            onTap: () => setState(() => _expandedThemes.add(book.id)),
          ),
        if (isExpanded && themes.length > 4)
          _themeToggle(
            label: 'Ver menos',
            icon: Icons.remove,
            onTap: () => setState(() => _expandedThemes.remove(book.id)),
          ),
      ],
    );
  }

  Widget _themeToggle({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
    bool bold = false,
  }) {
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