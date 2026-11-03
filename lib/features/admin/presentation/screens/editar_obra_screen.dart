import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/widgets/error_banner.dart';
import '../../../catalogo/data/models/book_models.dart';
import '../../../catalogo/data/services/catalog_api_service.dart';
import '../widgets/book_form_view.dart';

class EditarObraScreen extends StatefulWidget {
  const EditarObraScreen({super.key, required this.bookId});

  /// Só o id: a lista do catálogo não traz sinopse, ISBN nem links; o detalhe vem da API.
  final int bookId;

  @override
  State<EditarObraScreen> createState() => _EditarObraScreenState();
}

class _EditarObraScreenState extends State<EditarObraScreen> {
  late final CatalogApiService _service;

  BookDetail? _book;
  ApiException? _error;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _service = context.read<CatalogApiService>();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final book = await _service.getBook(widget.bookId);
      if (!mounted) return;
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

  @override
  Widget build(BuildContext context) {
    const backgroundColor = Color(0xFFF9F5EC);
    const primaryTextColor = Color(0xFF4A2525);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        leadingWidth: 100,
        leading: TextButton.icon(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: primaryTextColor, size: 20),
          label: const Text('Voltar', style: TextStyle(color: primaryTextColor, fontSize: 16)),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFFA1A32D)));
    }

    final error = _error;
    if (error != null) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: ErrorBanner(
          message: error.code == 'NOT_FOUND' ? 'Esta obra não existe mais.' : error.message,
          onRetry: _load,
        ),
      );
    }

    final book = _book!;
    return BookFormView(
      // key por id: se a tela for reutilizada com outra obra, o formulário recomeça.
      key: ValueKey(book.id),
      heading: 'Edição de Obra',
      subtitle: 'Atualize as informações bibliográficas no acervo.',
      separateCoverCard: true,
      initial: book,
      submitLabel: 'Salvar Alterações',
      submittingLabel: 'Salvando...',
      submitIcon: Icons.edit_document,
      // PATCH completo é idempotente: repetir após falha de rede é seguro.
      onSubmit: (form) => _service.updateBook(book.id, form),
      onSaved: (saved) => Navigator.pop(context, saved),
    );
  }
}