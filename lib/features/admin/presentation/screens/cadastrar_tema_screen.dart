import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/network/api_exception.dart';
import '../../../catalogo/data/models/theme_model.dart';
import '../../../catalogo/data/services/catalog_api_service.dart';

const _backgroundColor = Color(0xFFF9F5EC);
const _primaryTextColor = Color(0xFF4A2525);
const _buttonGreen = Color(0xFFA1A32D);

class CadastrarTemaScreen extends StatefulWidget {
  const CadastrarTemaScreen({super.key});

  @override
  State<CadastrarTemaScreen> createState() => _CadastrarTemaScreenState();
}

class _CadastrarTemaScreenState extends State<CadastrarTemaScreen> {
  final TextEditingController _controller = TextEditingController();
  late final CatalogApiService _service;

  List<ThemeModel> _themes = const [];
  bool _loading = true;
  bool _saving = false; // criando ou renomeando
  ApiException? _loadError;

  @override
  void initState() {
    super.initState();
    _service = context.read<CatalogApiService>();
    _load();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // --- Dados ----------------------------------------------------------------

  Future<void> _load({bool showSpinner = true}) async {
    if (showSpinner) {
      setState(() {
        _loading = true;
        _loadError = null;
      });
    }
    try {
      final list = await _service.listThemes(); // já vem em ordem alfabética
      if (!mounted) return;
      setState(() {
        _themes = list;
        _loadError = null;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _loadError = e);
    } catch (e, st) {
      debugPrint('Falha inesperada ao listar temas: $e\n$st');
      if (!mounted) return;
      setState(() => _loadError = ApiException.unexpected('$e'));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _cadastrar() async {
    final name = _controller.text.trim();
    if (name.isEmpty || _saving) return;

    setState(() => _saving = true);
    try {
      await _service.createTheme(name: name);
      if (!mounted) return;
      _controller.clear();
      _showSuccess('Tema "$name" cadastrado com sucesso!');
      await _load(showSpinner: false);
    } on ApiException catch (e) {
      if (!mounted) return;
      _showError(_messageFor(e));
    } catch (e, st) {
      debugPrint('Falha inesperada ao cadastrar tema: $e\n$st');
      if (!mounted) return;
      _showError('Ocorreu um erro inesperado. Tente novamente.');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _renomear(ThemeModel theme) async {
    final newName = await showDialog<String>(
      context: context,
      builder: (_) => _RenameDialog(initialName: theme.name),
    );
    if (!mounted || newName == null || newName == theme.name || _saving) return;

    setState(() => _saving = true);
    try {
      await _service.updateTheme(theme.id, name: newName);
      if (!mounted) return;
      _showSuccess('Tema renomeado para "$newName".');
      await _load(showSpinner: false);
    } on ApiException catch (e) {
      if (!mounted) return;
      _showError(_messageFor(e));
      // Lista desatualizada (outro admin removeu/alterou): sincroniza.
      if (e.code == 'NOT_FOUND') await _load(showSpinner: false);
    } catch (e, st) {
      debugPrint('Falha inesperada ao renomear tema: $e\n$st');
      if (!mounted) return;
      _showError('Ocorreu um erro inesperado. Tente novamente.');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  // --- Mensagens ------------------------------------------------------------

  String _messageFor(ApiException e) => switch (e.code) {
    'THEME_ALREADY_EXISTS' => 'Este tema já existe!',
    'VALIDATION_ERROR' => 'Confira o nome informado (até 120 caracteres).',
    'FORBIDDEN' => 'Você não tem permissão para esta ação.',
    'NOT_FOUND' => 'Este tema não existe mais. Atualizando a lista.',
    _ when e.isNetworkError =>
    '${e.message} Se estava cadastrando, confira a lista antes de tentar de novo.',
    _ => e.message,
  };

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: _buttonGreen),
    );
  }

  // --- UI -------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        backgroundColor: _backgroundColor,
        elevation: 0,
        leadingWidth: 100,
        leading: TextButton.icon(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: _primaryTextColor, size: 20),
          label: const Text('Voltar', style: TextStyle(color: _primaryTextColor, fontSize: 16)),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () => _load(showSpinner: false),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'Cadastrar Tema',
                style: TextStyle(color: _primaryTextColor, fontSize: 24, fontWeight: FontWeight.w800),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24.0),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3EFE4),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFEBE8E0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Tema',
                      style: TextStyle(color: _primaryTextColor, fontSize: 14, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      key: const ValueKey('theme_name_input'),
                      controller: _controller,
                      maxLength: 120,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _cadastrar(),
                      decoration: InputDecoration(
                        hintText: 'Ex: Bullying',
                        counterText: '',
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Color(0xFFD6D6D6)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Color(0xFFD6D6D6)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: _buttonGreen),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Divider(color: Color(0xFFEBE8E0)),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        key: const ValueKey('theme_submit'),
                        onPressed: _saving ? null : _cadastrar,
                        icon: _saving
                            ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                            : const Icon(Icons.add_circle_outline, color: Colors.white, size: 20),
                        label: Text(
                          _saving ? 'Salvando...' : 'Cadastrar Tema',
                          style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _buttonGreen,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          elevation: 0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'Temas Cadastrados',
                style: TextStyle(color: _primaryTextColor, fontSize: 18, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 16),

              if (_loading)
                const Padding(
                  padding: EdgeInsets.all(24),
                  child: CircularProgressIndicator(color: _buttonGreen),
                ),

              if (_loadError != null)
                _LoadError(message: _loadError!.message, onRetry: _load),

              if (!_loading && _loadError == null && _themes.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'Nenhum tema cadastrado ainda.',
                    style: TextStyle(color: Color(0xFF6B7280)),
                  ),
                ),

              for (final theme in _themes)
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFEBE8E0)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          theme.name,
                          style: const TextStyle(color: _primaryTextColor, fontWeight: FontWeight.w600),
                        ),
                      ),
                      IconButton(
                        key: ValueKey('theme_edit_${theme.id}'),
                        tooltip: 'Renomear',
                        icon: const Icon(Icons.edit_outlined, color: _primaryTextColor),
                        onPressed: _saving ? null : () => _renomear(theme),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LoadError extends StatelessWidget {
  const _LoadError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFDECEA),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFF5C2C0)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Color(0xFFC62828), size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: Color(0xFF7F1D1D), fontSize: 13, height: 1.3),
            ),
          ),
          TextButton(onPressed: onRetry, child: const Text('Tentar de novo')),
        ],
      ),
    );
  }
}

/// Diálogo próprio para o TextEditingController ser descartado corretamente.
class _RenameDialog extends StatefulWidget {
  const _RenameDialog({required this.initialName});

  final String initialName;

  @override
  State<_RenameDialog> createState() => _RenameDialogState();
}

class _RenameDialogState extends State<_RenameDialog> {
  late final TextEditingController _ctrl = TextEditingController(text: widget.initialName);

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _submit() {
    final value = _ctrl.text.trim();
    if (value.isEmpty) return;
    Navigator.pop(context, value);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Renomear tema'),
      content: TextField(
        key: const ValueKey('rename_input'),
        controller: _ctrl,
        autofocus: true,
        maxLength: 120,
        textInputAction: TextInputAction.done,
        onSubmitted: (_) => _submit(),
        decoration: const InputDecoration(counterText: ''),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
        ),
        TextButton(
          onPressed: _submit,
          child: const Text('Salvar', style: TextStyle(color: _buttonGreen, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}