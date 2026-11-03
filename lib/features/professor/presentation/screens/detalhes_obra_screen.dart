import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/theme/sizes.dart';
import '../../../../core/widgets/error_banner.dart';
import '../../../../core/widgets/fullscreen_image_viewer.dart';
import '../../../catalogo/data/models/book_models.dart';
import '../../../catalogo/data/services/catalog_api_service.dart';
import '../../../catalogo/presentation/controllers/saved_books_controller.dart';

final Uri _defaultStoreUri = Uri.parse('https://www.collibooksloja.com/');

class DetalhesObraScreen extends StatefulWidget {
  const DetalhesObraScreen({super.key, required this.bookId});

  /// Só o id: o resumo da lista não traz sinopse, ISBN nem links.
  final int bookId;

  @override
  State<DetalhesObraScreen> createState() => _DetalhesObraScreenState();
}

class _DetalhesObraScreenState extends State<DetalhesObraScreen> {
  late final CatalogApiService _service;
  late final SavedBooksController _saved;

  BookDetail? _book;
  ApiException? _error;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _service = context.read<CatalogApiService>();
    _saved = context.read<SavedBooksController>(); // vive no topo do app
    _load();
  }

  // --- Dados ----------------------------------------------------------------

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final book = await _service.getBook(widget.bookId);
      if (!mounted) return;
      // Antes do setState: o botão já nasce com o estado certo de "salva".
      _saved.sync([book]);
      setState(() => _book = book);
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _error = e);
    } catch (e, st) {
      debugPrint('Falha inesperada ao carregar obra: $e\n$st');
      if (!mounted) return;
      setState(() => _error = ApiException.unexpected('$e'));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _toggleSaved(BookDetail book) async {
    final error = await _saved.toggle(book.id);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          error != null
              ? SavedBooksController.messageFor(error)
              : (_saved.isSaved(book.id)
              ? 'Obra adicionada à sua seleção!'
              : 'Obra removida da seleção.'),
        ),
        backgroundColor: error != null ? const Color(0xFFC62828) : null,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // --- Links ----------------------------------------------------------------

  /// Os links vêm de texto livre digitado pela editora: só abre http(s) com host.
  static Uri? _safeHttpUri(String? raw) {
    final value = raw?.trim() ?? '';
    if (value.isEmpty) return null;
    final uri = Uri.tryParse(value);
    if (uri == null || !uri.hasAuthority) return null;
    if (uri.scheme != 'http' && uri.scheme != 'https') return null;
    return uri;
  }

  Future<void> _abrirLink(String? raw) async {
    final uri = _safeHttpUri(raw);
    if (uri == null) {
      _snack('Este link é inválido.');
      return;
    }
    try {
      final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!ok) _snack('Não foi possível abrir o link.');
    } catch (e) {
      debugPrint('Falha ao abrir link: $e');
      _snack('Não foi possível abrir o link.');
    }
  }

  void _snack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 3)),
    );
  }

  Future<void> _abrirLoja(BookDetail book) async {
    // Link da obra se for válido; senão, a página inicial da loja.
    final uri = _safeHttpUri(book.storeUrl) ?? _defaultStoreUri;
    try {
      final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!ok) _snack('Não foi possível abrir a loja.');
    } catch (e) {
      debugPrint('Falha ao abrir a loja: $e');
      _snack('Não foi possível abrir a loja.');
    }
  }

  // --- UI -------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.titleText),
        title: const Text(
          'Detalhe da Obra',
          style: TextStyle(
            color: AppColors.titleText,
            fontWeight: FontWeight.bold,
            fontSize: AppSizes.fontTitle,
          ),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    final error = _error;
    if (error != null) {
      return Padding(
        padding: const EdgeInsets.all(AppSizes.spacingLg),
        child: ErrorBanner(
          message: error.code == 'NOT_FOUND' ? 'Esta obra não existe mais.' : error.message,
          onRetry: _load,
        ),
      );
    }

    return _buildContent(_book!);
  }

  Widget _buildContent(BookDetail book) {
    final coverUrl = book.coverUri;
    final synopsis = book.synopsis?.trim() ?? '';
    final hasBookLink = _safeHttpUri(book.bookUrl) != null;
    final hasMaterial = _safeHttpUri(book.pedagogicalMaterialUrl) != null;

    final tags = <String>[
      if (book.educationLevel != null) book.educationLevel!.name,
      for (final t in book.themes) t.name,
    ];

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- TOPO: CAPA COM FUNDO ESTÉTICO ---
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                height: 320,
                width: double.infinity,
                color: const Color(0xFFE8E0D5),
                child: coverUrl != null
                    ? Image.network(
                  coverUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(color: const Color(0xFFE8E0D5)),
                )
                    : null,
              ),
              // Camada escura suave para destacar a capa
              Container(
                height: 320,
                width: double.infinity,
                color: Colors.black.withValues(alpha: 0.15),
              ),
              GestureDetector(
                onTap: coverUrl == null
                    ? null // sem capa: nada para abrir em tela cheia
                    : () => abrirVisualizadorImagem(
                  context,
                  imagePath: coverUrl,
                  coverBytes: null,
                  title: book.title,
                ),
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    Container(
                      height: 270,
                      width: 190,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: coverUrl != null
                            ? Image.network(
                          coverUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _coverPlaceholder(),
                        )
                            : _coverPlaceholder(),
                      ),
                    ),
                    if (coverUrl != null)
                      Positioned(
                        bottom: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.65),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.fullscreen_rounded, size: 14, color: Colors.white),
                              SizedBox(width: 4),
                              Text(
                                'Toque para tela cheia',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(AppSizes.spacingLg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- BOTÕES DE AÇÃO PRINCIPAIS ---
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                      ),
                    ),
                    icon: const Icon(Icons.shopping_cart_outlined),
                    label: const Text(
                      'Comprar na Loja',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    onPressed: () => _abrirLoja(book),
                  ),
                ),
                const SizedBox(height: AppSizes.spacingSm),
                if (hasBookLink) ...[
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4A2525),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                        ),
                      ),
                      icon: const Icon(Icons.picture_as_pdf_outlined),
                      label: const Text(
                        'Acessar Livro no Google Drive (PDF)',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      onPressed: () => _abrirLink(book.bookUrl),
                    ),
                  ),
                  const SizedBox(height: AppSizes.spacingSm),
                ],
                // Escuta só o estado de "salva": o resto da tela não reconstrói.
                ListenableBuilder(
                  listenable: _saved,
                  builder: (context, _) {
                    final isSaved = _saved.isSaved(book.id);
                    final pending = _saved.isPending(book.id);
                    return SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          side: const BorderSide(color: AppColors.primary),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                          ),
                        ),
                        icon: Icon(isSaved ? Icons.bookmark : Icons.bookmark_border),
                        label: Text(
                          isSaved ? 'Salvo na Seleção' : 'Salvar na Seleção',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        onPressed: pending ? null : () => _toggleSaved(book),
                      ),
                    );
                  },
                ),
                const SizedBox(height: AppSizes.spacingLg),

                // --- ESCOLARIDADE E TEMAS ---
                if (tags.isNotEmpty) ...[
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final tag in tags)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0E5D8),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            tag.toUpperCase(),
                            style: const TextStyle(
                              color: AppColors.titleText,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: AppSizes.spacingMd),
                ],

                // --- TÍTULO E AUTOR ---
                Text(
                  book.title,
                  style: const TextStyle(
                    color: AppColors.titleText,
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Por ${book.author}',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppSizes.spacingXl),

                // --- SINOPSE ---
                if (synopsis.isNotEmpty) ...[
                  const Text(
                    'Sinopse',
                    style: TextStyle(
                      color: AppColors.titleText,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    synopsis,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 15,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: AppSizes.spacingXl),
                ],

                // --- FICHA TÉCNICA ---
                ..._buildTechnicalInfo(book),

                // --- MATERIAL PEDAGÓGICO ---
                if (hasMaterial)
                  Container(
                    padding: const EdgeInsets.all(AppSizes.spacingMd),
                    decoration: BoxDecoration(
                      color: AppColors.cardBackground,
                      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.school_outlined, color: AppColors.primary),
                            SizedBox(width: 8),
                            Text(
                              'Material Pedagógico',
                              style: TextStyle(
                                color: AppColors.titleText,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Recursos exclusivos desenvolvidos para apoiar o professor na sala de aula.',
                          style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                        ),
                        const SizedBox(height: AppSizes.spacingMd),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                              ),
                            ),
                            icon: const Icon(Icons.school, size: 18),
                            label: const Text(
                              'Acessar Material Pedagógico',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            onPressed: () => _abrirLink(book.pedagogicalMaterialUrl),
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _coverPlaceholder() => Container(
    color: Colors.grey.shade300,
    child: const Center(
      child: Icon(Icons.menu_book, size: 64, color: Colors.grey),
    ),
  );

  /// ISBN, páginas, edição e ano: só as linhas que a obra tem.
  List<Widget> _buildTechnicalInfo(BookDetail book) {
    final rows = <(String, String)>[
      if ((book.isbn ?? '').trim().isNotEmpty) ('ISBN', book.isbn!.trim()),
      if (book.pageCount != null) ('Páginas', '${book.pageCount}'),
      if ((book.edition ?? '').trim().isNotEmpty) ('Edição', book.edition!.trim()),
      if (book.year != null) ('Ano', '${book.year}'),
    ];
    if (rows.isEmpty) return const [];

    return [
      const Text(
        'Ficha Técnica',
        style: TextStyle(
          color: AppColors.titleText,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      const SizedBox(height: 8),
      for (final (label, value) in rows)
        Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 80,
                child: Text(
                  label,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  value,
                  style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
                ),
              ),
            ],
          ),
        ),
      const SizedBox(height: AppSizes.spacingXl),
    ];
  }
}