import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/utils/image_sniffer.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/error_banner.dart';
import '../../../../core/widgets/fullscreen_image_viewer.dart';
import '../../../../core/widgets/pick_many_dialog.dart';
import '../../../catalogo/data/models/book_form.dart';
import '../../../catalogo/data/models/book_models.dart';
import '../../../catalogo/data/models/education_level_model.dart';
import '../../../catalogo/data/models/theme_model.dart';
import '../../../catalogo/data/services/catalog_api_service.dart';
import '../../../catalogo/presentation/controllers/catalog_options_controller.dart';

const _primaryTextColor = Color(0xFF4A2525);
const _secondaryTextColor = Color(0xFF6B6B6B);
const _buttonGreen = Color(0xFFA1A32D);
const _borderColor = Color(0xFFD6D6D6);
const _errorRed = Color(0xFFC62828);
const _maxCoverBytes = 5 * 1024 * 1024; // limite do backend

/// Formulário de obra compartilhado entre cadastro (`initial == null`) e edição.
/// Faz validação, erros campo a campo e envio; quem decide o que fazer com o
/// resultado é a tela (via [onSaved]).
class BookFormView extends StatefulWidget {
  const BookFormView({
    super.key,
    required this.heading,
    required this.submitLabel,
    required this.submittingLabel,
    required this.submitIcon,
    required this.onSubmit,
    required this.onSaved,
    this.subtitle,
    this.centerHeading = false,
    this.separateCoverCard = false,
    this.initial,
    this.uncertainOutcomeHint,
  });

  final String heading;
  final String? subtitle;
  final bool centerHeading;

  /// true = capa em um cartão e campos em outro (layout da edição).
  final bool separateCoverCard;

  final String submitLabel;
  final String submittingLabel;
  final IconData submitIcon;

  /// Não nulo = edição: pré-preenche o formulário.
  final BookDetail? initial;

  /// Anexado à mensagem de erro de rede. Use só quando repetir o envio não é
  /// seguro (cadastro: a obra pode ter sido criada). Edição é idempotente: null.
  final String? uncertainOutcomeHint;

  final Future<BookDetail> Function(BookForm form) onSubmit;
  final void Function(BookDetail saved) onSaved;

  @override
  State<BookFormView> createState() => _BookFormViewState();
}

class _BookFormViewState extends State<BookFormView> {
  /// Campos que o formulário sabe exibir; erros de outros campos vão para a snackbar.
  static const _shownFields = {
    'title',
    'author',
    'isbn',
    'store_url',
    'book_url',
    'pedagogical_material_url',
    'education_level_ids',
    'theme_ids',
    'cover',
  };

  late final TextEditingController _titleController;
  late final TextEditingController _authorController;
  late final TextEditingController _isbnController;
  late final TextEditingController _sinopseController;
  late final TextEditingController _bookUrlController;
  late final TextEditingController _storeUrlController;
  late final TextEditingController _lpUrlController;

  late final CatalogApiService _service;
  late final CatalogOptionsController _options;

  List<EducationLevelModel> _selectedLevels = [];
  List<ThemeModel> _selectedThemes = [];

  /// Capa NOVA escolhida pelo usuário (null = não trocar / não enviar).
  Uint8List? _coverBytes;
  String? _coverFilename;

  /// Capa que a obra já tem no servidor (só na edição).
  String? _existingCoverUrl;

  bool _saving = false;

  /// Erros por campo, na chave do backend (snake_case): 'title', 'isbn', 'cover'...
  final Map<String, String> _fieldErrors = {};

  bool get _isEditing => widget.initial != null;
  bool get _hasNewCover => _coverBytes != null && _coverBytes!.isNotEmpty;
  bool get _hasCover => _hasNewCover || _existingCoverUrl != null;

  @override
  void initState() {
    super.initState();
    _service = context.read<CatalogApiService>();
    _options = CatalogOptionsController(_service)..load();

    final i = widget.initial;
    _titleController = TextEditingController(text: i?.title ?? '');
    _authorController = TextEditingController(text: i?.author ?? '');
    _isbnController = TextEditingController(text: i?.isbn ?? '');
    _sinopseController = TextEditingController(text: i?.synopsis ?? '');
    _bookUrlController = TextEditingController(text: i?.bookUrl ?? '');
    _storeUrlController = TextEditingController(text: i?.storeUrl ?? '');
    _lpUrlController = TextEditingController(text: i?.pedagogicalMaterialUrl ?? '');
    _selectedLevels = List<EducationLevelModel>.of(i?.educationLevels ?? const []);
    _selectedThemes = List<ThemeModel>.of(i?.themes ?? const []);
    _existingCoverUrl = i?.coverUri;

    for (final c in [
      _sinopseController,
      _isbnController,
      _bookUrlController,
      _storeUrlController,
      _lpUrlController,
    ]) {
      c.addListener(_refresh);
    }
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _isbnController.dispose();
    _sinopseController.dispose();
    _bookUrlController.dispose();
    _storeUrlController.dispose();
    _lpUrlController.dispose();
    _options.dispose();
    super.dispose();
  }

  // --- Envio ----------------------------------------------------------------

  BookForm _buildForm() {
    final i = widget.initial;
    return BookForm(
      title: _titleController.text,
      author: _authorController.text,
      synopsis: _sinopseController.text,
      isbn: _isbnController.text,
      storeUrl: _storeUrlController.text,
      bookUrl: _bookUrlController.text,
      pedagogicalMaterialUrl: _lpUrlController.text,
      // Campos que o formulário não exibe: na edição, reenvia os valores
      // atuais (o PATCH completo trata "vazio" como "limpar").
      pageCount: i?.pageCount,
      edition: i?.edition,
      year: i?.year,
      educationLevelIds: [for (final l in _selectedLevels) l.id],
      themeIds: [for (final t in _selectedThemes) t.id],
      coverBytes: _coverBytes,
      coverFilename: _coverFilename,
    );
  }

  bool _validateLocally() {
    final errors = <String, String>{};
    if (_titleController.text.trim().isEmpty) errors['title'] = 'Informe o título da obra.';
    if (_authorController.text.trim().isEmpty) errors['author'] = 'Informe o autor(a).';

    final urlsOk = FormValidators.isValidUrl(_bookUrlController.text) &&
        FormValidators.isValidUrl(_storeUrlController.text) &&
        FormValidators.isValidUrl(_lpUrlController.text);

    setState(() {
      _fieldErrors
        ..clear()
        ..addAll(errors);
    });

    if (errors.isNotEmpty) {
      _showError('Preencha os campos obrigatórios destacados.');
      return false;
    }
    if (!urlsOk) {
      _showError('Por favor, corrija o formato dos links destacados antes de salvar.');
      return false;
    }
    return true;
  }

  Future<void> _submit() async {
    if (_saving || !_validateLocally()) return;

    setState(() => _saving = true);
    try {
      final book = await widget.onSubmit(_buildForm());
      if (!mounted) return;
      widget.onSaved(book);
    } on ApiException catch (e) {
      if (!mounted) return;
      _applyApiError(e);
    } catch (e, st) {
      debugPrint('Falha inesperada ao salvar obra: $e\n$st');
      if (!mounted) return;
      _showError('Ocorreu um erro inesperado. Tente novamente.');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _applyApiError(ApiException e) {
    setState(() {
      _fieldErrors
        ..clear()
        ..addAll(e.fieldErrors);
      switch (e.code) {
        case 'ISBN_ALREADY_REGISTERED':
          _fieldErrors['isbn'] = 'Este ISBN já está cadastrado em outra obra.';
        case 'IMAGE_INVALID':
          _fieldErrors['cover'] = 'A capa deve ser uma imagem PNG ou JPEG.';
        case 'IMAGE_TOO_LARGE':
          _fieldErrors['cover'] = 'A capa excede o limite de 5 MB.';
      }
    });

    final hidden = e.fieldErrors.entries.where((x) => !_shownFields.contains(x.key));
    _showError(
      hidden.isNotEmpty ? '${hidden.first.key}: ${hidden.first.value}' : _messageFor(e),
    );
  }

  String _messageFor(ApiException e) => switch (e.code) {
    'ISBN_ALREADY_REGISTERED' => 'Já existe uma obra com este ISBN.',
    'IMAGE_INVALID' => 'A capa deve ser uma imagem PNG ou JPEG.',
    'IMAGE_TOO_LARGE' => 'A capa excede o limite de 5 MB.',
    'VALIDATION_ERROR' => 'Confira os campos destacados.',
    'FORBIDDEN' => 'Você não tem permissão para esta ação.',
    'NOT_FOUND' => 'Esta obra não existe mais.',
    _ when e.isNetworkError && widget.uncertainOutcomeHint != null =>
    '${e.message} ${widget.uncertainOutcomeHint}',
    _ => e.message,
  };

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: _errorRed,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  // --- Capa -----------------------------------------------------------------

  String? _validateCover(Uint8List bytes) {
    if (sniffImage(bytes) == null) return 'A capa deve ser uma imagem PNG ou JPEG.';
    if (bytes.length > _maxCoverBytes) return 'A capa excede o limite de 5 MB.';
    return null;
  }

  void _openFullscreen(BuildContext ctx, {Uint8List? bytes, String? name, String? url, String? title}) {
    abrirVisualizadorImagem(
      ctx,
      imagePath: bytes != null ? name : url,
      coverBytes: bytes,
      title: title ?? (_titleController.text.isNotEmpty ? _titleController.text : 'Capa da Obra'),
    );
  }

  void _showChangeCoverDialog() {
    String? previewName = _coverFilename;
    Uint8List? previewBytes = _coverBytes;
    String? pickError;

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return AlertDialog(
              backgroundColor: const Color(0xFFF9F5EC),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Row(
                children: [
                  Icon(Icons.photo_library_outlined, color: _primaryTextColor),
                  SizedBox(width: 8),
                  Text(
                    'Definir Capa da Obra',
                    style: TextStyle(color: _primaryTextColor, fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ],
              ),
              content: SizedBox(
                width: 480,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            try {
                              final file = await FilePicker.pickFile(
                                type: FileType.custom,
                                allowedExtensions: ['png', 'jpg', 'jpeg'],
                              );
                              if (file == null) return;
                              final bytes = await file.readAsBytes();
                              final error = _validateCover(bytes);
                              setDialogState(() {
                                pickError = error;
                                if (error == null) {
                                  previewBytes = bytes;
                                  previewName = file.name;
                                }
                              });
                            } catch (e) {
                              debugPrint('Erro ao selecionar arquivo: $e');
                              setDialogState(
                                    () => pickError = 'Não foi possível ler o arquivo selecionado.',
                              );
                            }
                          },
                          icon: const Icon(Icons.upload_file_rounded, color: Colors.white, size: 20),
                          label: const Text(
                            'Carregar Arquivo (PNG ou JPEG)',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _buttonGreen,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Formatos aceitos: PNG ou JPEG, até 5 MB.',
                        style: TextStyle(fontSize: 11, color: Color(0xFF8C7A70)),
                      ),
                      if (pickError != null) _FieldErrorText(pickError!),
                      const SizedBox(height: 20),
                      Center(
                        child: Column(
                          children: [
                            const Text(
                              'Pré-visualização da Capa:',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF8C7A70)),
                            ),
                            const SizedBox(height: 8),
                            InkWell(
                              onTap: !(previewBytes != null || _existingCoverUrl != null)
                                  ? null
                                  : () => _openFullscreen(
                                dialogContext,
                                bytes: previewBytes,
                                name: previewName,
                                url: _existingCoverUrl,
                                title: 'Pré-visualização da Capa',
                              ),
                              borderRadius: BorderRadius.circular(10),
                              child: _buildCoverPreview(
                                bytes: previewBytes,
                                url: _existingCoverUrl,
                                width: 120,
                                height: 175,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _coverBytes = previewBytes;
                      _coverFilename = previewName;
                      _fieldErrors.remove('cover');
                    });
                    Navigator.pop(dialogContext);
                  },
                  icon: const Icon(Icons.check, color: Colors.white, size: 18),
                  label: const Text('Confirmar Capa', style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _buttonGreen,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // --- Escolaridades e temas (múltiplos) -------------------------------------

  Future<void> _pickLevels() async {
    final all = _options.levels;
    final result = await showPickManyDialog(
      context,
      title: 'Selecionar Escolaridades',
      emptyMessage: 'Nenhuma escolaridade cadastrada ainda. Cadastre escolaridades primeiro.',
      options: [for (final l in all) (id: l.id, name: l.name)],
      selectedIds: {for (final l in _selectedLevels) l.id},
    );
    if (!mounted || result == null) return;
    setState(() {
      _selectedLevels = [for (final l in all) if (result.contains(l.id)) l];
      _fieldErrors.remove('education_level_ids');
    });
  }

  void _pickThemes() {
    final all = _options.themes;
    final temp = {for (final t in _selectedThemes) t.id};

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setStateDialog) {
            return AlertDialog(
              backgroundColor: const Color(0xFFF9F5EC),
              title: const Text(
                'Selecionar Temas',
                style: TextStyle(color: _primaryTextColor, fontWeight: FontWeight.bold, fontSize: 18),
              ),
              content: SizedBox(
                width: double.maxFinite,
                child: all.isEmpty
                    ? const Text('Nenhum tema cadastrado ainda. Cadastre temas primeiro.')
                    : ListView(
                  shrinkWrap: true,
                  children: [
                    for (final t in all)
                      CheckboxListTile(
                        key: ValueKey('theme_option_${t.id}'),
                        title: Text(t.name, style: const TextStyle(color: _primaryTextColor)),
                        activeColor: _buttonGreen,
                        value: temp.contains(t.id),
                        onChanged: (checked) => setStateDialog(() {
                          if (checked == true) {
                            temp.add(t.id);
                          } else {
                            temp.remove(t.id);
                          }
                        }),
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _selectedThemes = [for (final t in all) if (temp.contains(t.id)) t];
                      _fieldErrors.remove('theme_ids');
                    });
                    Navigator.pop(dialogContext);
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: _buttonGreen),
                  child: const Text('Aplicar', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // --- UI -------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final cover = _buildCoverSection();
    final fields = _buildFieldsSection();

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: widget.centerHeading ? CrossAxisAlignment.center : CrossAxisAlignment.start,
        children: [
          Text(
            widget.heading,
            textAlign: widget.centerHeading ? TextAlign.center : TextAlign.start,
            style: const TextStyle(color: _primaryTextColor, fontSize: 24, fontWeight: FontWeight.w800),
          ),
          if (widget.subtitle != null) ...[
            const SizedBox(height: 8),
            Text(widget.subtitle!, style: const TextStyle(color: _secondaryTextColor, fontSize: 14)),
          ],
          const SizedBox(height: 32),
          if (widget.separateCoverCard) ...[
            _card(cover),
            const SizedBox(height: 32),
            _card(fields),
          ] else
            _card(Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [cover, const SizedBox(height: 24), fields],
            )),
        ],
      ),
    );
  }

  Widget _card(Widget child) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(24.0),
    decoration: BoxDecoration(
      color: const Color(0xFFF3EFE4),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: const Color(0xFFEBE8E0)),
    ),
    child: child,
  );

  Widget _label(String text) => Text(
    text,
    style: const TextStyle(color: _primaryTextColor, fontSize: 14, fontWeight: FontWeight.w700),
  );

  Widget _buildCoverSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Capa da Obra',
              style: TextStyle(color: _primaryTextColor, fontSize: 16, fontWeight: FontWeight.w800),
            ),
            if (_hasCover)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFA5D6A7)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.check_circle, size: 14, color: Color(0xFF2E7D32)),
                    const SizedBox(width: 4),
                    Text(
                      _isEditing ? 'Capa ativa' : 'Capa definida',
                      style: const TextStyle(color: Color(0xFF2E7D32), fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          _isEditing
              ? 'Carregue um arquivo (PNG ou JPEG, até 5 MB) para substituir a capa atual.'
              : 'Carregue um arquivo do seu dispositivo (PNG ou JPEG, até 5 MB).',
          style: const TextStyle(color: _secondaryTextColor, fontSize: 12),
        ),
        const SizedBox(height: 20),
        Center(
          child: InkWell(
            onTap: _hasCover
                ? () => _openFullscreen(context, bytes: _coverBytes, name: _coverFilename, url: _existingCoverUrl)
                : _showChangeCoverDialog,
            borderRadius: BorderRadius.circular(12),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                _buildCoverPreview(bytes: _coverBytes, url: _existingCoverUrl, width: 170, height: 250),
                if (_hasCover)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                            'Tela Cheia',
                            style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 10,
          children: [
            ElevatedButton.icon(
              onPressed: _showChangeCoverDialog,
              icon: const Icon(Icons.file_upload_outlined, size: 18, color: Colors.white),
              label: Text(
                _isEditing ? 'Trocar Capa' : 'Carregar Capa',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _buttonGreen,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            // Só descarta o arquivo escolhido nesta sessão: a API não remove capas.
            if (_hasNewCover)
              OutlinedButton.icon(
                onPressed: () {
                  setState(() {
                    _coverBytes = null;
                    _coverFilename = null;
                    _fieldErrors.remove('cover');
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(_isEditing ? 'Nova capa descartada.' : 'Capa removida.'),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
                icon: const Icon(Icons.delete_outline, color: _errorRed, size: 18),
                label: Text(
                  _isEditing ? 'Descartar nova capa' : 'Remover Capa',
                  style: const TextStyle(color: _errorRed, fontWeight: FontWeight.bold),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  side: const BorderSide(color: Color(0xFFEF9A9A)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
          ],
        ),
        if (_fieldErrors['cover'] != null) _FieldErrorText(_fieldErrors['cover']!),
      ],
    );
  }

  Widget _buildFieldsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.separateCoverCard) ...[
          const Text(
            'Informações Bibliográficas',
            style: TextStyle(color: _primaryTextColor, fontSize: 18, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 24),
        ],
        _buildTextField('Título da Obra *', 'Ex: O Pequeno Príncipe', _titleController,
            fieldKey: 'title', maxLength: 255),
        const SizedBox(height: 16),
        _buildTextField('Autor(a) *', 'Nome do autor', _authorController,
            fieldKey: 'author', maxLength: 255),
        const SizedBox(height: 16),
        _buildTextField(
          'ISBN',
          '978-65-6079-046-9',
          _isbnController,
          fieldKey: 'isbn',
          keyboardType: TextInputType.number,
          inputFormatters: [IsbnInputFormatter()],
          isIsbnField: true,
        ),
        const SizedBox(height: 16),
        _buildPickers(),
        const SizedBox(height: 16),
        _label('Sinopse / Descrição'),
        const SizedBox(height: 8),
        TextField(
          key: ValueKey('book_field_synopsis'),
          controller: _sinopseController,
          minLines: 4,
          maxLines: null,
          maxLength: 1000,
          keyboardType: TextInputType.multiline,
          decoration: InputDecoration(
            hintText: 'Digite a sinopse ou descrição da obra...',
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: _borderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: _borderColor),
            ),
            counterText: '',
          ),
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            '${_sinopseController.text.length} / 1000 caracteres',
            style: const TextStyle(color: Color(0xFFBCAAA4), fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ),
        const SizedBox(height: 24),
        const Divider(color: Color(0xFFEBE8E0), height: 1),
        const SizedBox(height: 24),
        const Text(
          'Links e Recursos da Obra',
          style: TextStyle(color: _primaryTextColor, fontSize: 16, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 4),
        const Text(
          'Acessos para leitura digital, compra e materiais complementares.',
          style: TextStyle(color: _secondaryTextColor, fontSize: 12),
        ),
        const SizedBox(height: 16),
        _buildTextField(
          'Link do Livro (Google Drive / PDF)',
          'Ex: https://drive.google.com/file/d/...',
          _bookUrlController,
          fieldKey: 'book_url',
          prefixIcon: Icons.picture_as_pdf_outlined,
          keyboardType: TextInputType.url,
          isUrlField: true,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          'Link da Loja',
          'Ex: https://www.collibooksloja.com/infantil/o-segredo-de-aurora',
          _storeUrlController,
          fieldKey: 'store_url',
          prefixIcon: Icons.shopping_bag_outlined,
          keyboardType: TextInputType.url,
          isUrlField: true,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          'Link da Página de Material Pedagógico',
          'Ex: https://www.collibooks.com/o-segredo-de-aurora-lp/',
          _lpUrlController,
          fieldKey: 'pedagogical_material_url',
          prefixIcon: Icons.school_outlined,
          keyboardType: TextInputType.url,
          isUrlField: true,
        ),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _saving ? null : _submit,
            icon: _saving
                ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
            )
                : Icon(widget.submitIcon, color: Colors.white, size: 20),
            label: Text(
              _saving ? widget.submittingLabel : widget.submitLabel,
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
    );
  }

  Widget _buildPickers() {
    return ListenableBuilder(
      listenable: _options,
      builder: (context, _) {
        final loading = _options.isLoading;
        final error = _options.error;
        final ready = !loading && error == null;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (error != null)
              ErrorBanner(
                message: 'Não foi possível carregar escolaridades e temas. ${error.message}',
                onRetry: _options.load,
                margin: const EdgeInsets.only(bottom: 14),
              ),
            _label('Escolaridades'),
            const SizedBox(height: 8),
            _pickerField(
              fieldKey: const ValueKey('book_picker_level'),
              icon: Icons.school_outlined,
              placeholder: loading ? 'Carregando escolaridades...' : 'Selecione as escolaridades...',
              selectedText: _selectedLevels.isEmpty ? null : '${_selectedLevels.length} selecionada(s)',
              badgeBg: const Color(0xFFD4E6F1),
              badgeFg: const Color(0xFF1B4F72),
              onTap: ready ? _pickLevels : null,
            ),
            if (_selectedLevels.isNotEmpty) ...[
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final l in _selectedLevels)
                    _chip(
                      label: l.name,
                      icon: Icons.school_rounded,
                      bg: const Color(0xFFEAF2F8),
                      border: const Color(0xFFAED6F1),
                      fg: const Color(0xFF1B4F72),
                      closeBg: const Color(0xFFD4E6F1),
                      onRemove: () => setState(() => _selectedLevels.remove(l)),
                    ),
                ],
              ),
            ],
            if (_fieldErrors['education_level_ids'] != null)
              _FieldErrorText(_fieldErrors['education_level_ids']!),
            const SizedBox(height: 20),
            _label('Temas Abordados'),
            const SizedBox(height: 8),
            _pickerField(
              fieldKey: const ValueKey('book_picker_themes'),
              icon: Icons.category_outlined,
              placeholder: loading ? 'Carregando temas...' : 'Selecione os temas abordados...',
              selectedText: _selectedThemes.isEmpty ? null : '${_selectedThemes.length} selecionado(s)',
              badgeBg: const Color(0xFFFDEBD0),
              badgeFg: const Color(0xFFD35400),
              onTap: ready ? _pickThemes : null,
            ),
            if (_selectedThemes.isNotEmpty) ...[
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final t in _selectedThemes)
                    _chip(
                      label: t.name,
                      icon: Icons.label_rounded,
                      bg: const Color(0xFFFDF2E9),
                      border: const Color(0xFFF5CBA7),
                      fg: const Color(0xFFBA4A00),
                      closeBg: const Color(0xFFFCE4D6),
                      onRemove: () => setState(() => _selectedThemes.remove(t)),
                    ),
                ],
              ),
            ],
            if (_fieldErrors['theme_ids'] != null) _FieldErrorText(_fieldErrors['theme_ids']!),
          ],
        );
      },
    );
  }

  Widget _pickerField({
    required IconData icon,
    required String placeholder,
    required String? selectedText,
    required Color badgeBg,
    required Color badgeFg,
    required VoidCallback? onTap,
    Key? fieldKey,
  }) {
    final hasSelection = selectedText != null && selectedText.isNotEmpty;
    return InkWell(
      key: fieldKey,
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: hasSelection ? _buttonGreen : _borderColor,
            width: hasSelection ? 1.5 : 1.0,
          ),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 4, offset: const Offset(0, 2)),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: _buttonGreen, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: hasSelection
                  ? Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: badgeBg, borderRadius: BorderRadius.circular(12)),
                  child: Text(
                    selectedText,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: badgeFg, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              )
                  : Text(placeholder, style: const TextStyle(color: Color(0xFF9E9E9E), fontSize: 14)),
            ),
            Text(
              hasSelection ? 'Alterar' : 'Escolher',
              style: const TextStyle(color: _buttonGreen, fontSize: 12, fontWeight: FontWeight.bold),
            ),
            const Icon(Icons.arrow_drop_down, color: _buttonGreen),
          ],
        ),
      ),
    );
  }

  Widget _chip({
    required String label,
    required IconData icon,
    required Color bg,
    required Color border,
    required Color fg,
    required Color closeBg,
    required VoidCallback onRemove,
  }) {
    return Container(
      padding: const EdgeInsets.only(left: 10, right: 6, top: 6, bottom: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border, width: 1.2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: fg),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(color: fg, fontSize: 12.5, fontWeight: FontWeight.w700)),
          const SizedBox(width: 6),
          InkWell(
            onTap: onRemove,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(color: closeBg, shape: BoxShape.circle),
              child: Icon(Icons.close_rounded, size: 13, color: fg),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
      String label,
      String hint,
      TextEditingController controller, {
        required String fieldKey,
        IconData? prefixIcon,
        List<TextInputFormatter>? inputFormatters,
        TextInputType? keyboardType,
        int? maxLength,
        bool isUrlField = false,
        bool isIsbnField = false,
      }) {
    final text = controller.text;
    final urlError = (isUrlField && text.trim().isNotEmpty) ? FormValidators.validateUrl(text) : null;
    final errorText = _fieldErrors[fieldKey] ?? urlError;
    final hasError = errorText != null;
    final isbnDigits = text.replaceAll(RegExp(r'\D'), '');

    Widget? suffixIcon;
    if (isUrlField && text.trim().isNotEmpty) {
      suffixIcon = Tooltip(
        message: hasError ? errorText : 'Link válido',
        child: Padding(
          padding: const EdgeInsets.only(right: 12),
          child: Icon(
            hasError ? Icons.error_outline_rounded : Icons.check_circle_rounded,
            color: hasError ? _errorRed : const Color(0xFF2E7D32),
            size: 20,
          ),
        ),
      );
    } else if (isIsbnField && isbnDigits.isNotEmpty) {
      suffixIcon = isbnDigits.length == 13
          ? const Tooltip(
        message: 'ISBN-13 Completo',
        child: Padding(
          padding: EdgeInsets.only(right: 12),
          child: Icon(Icons.check_circle_rounded, color: Color(0xFF2E7D32), size: 20),
        ),
      )
          : Padding(
        padding: const EdgeInsets.only(right: 12),
        child: Center(
          widthFactor: 1.0,
          child: Text(
            '${isbnDigits.length}/13',
            style: const TextStyle(color: Color(0xFF8C7A70), fontSize: 11, fontWeight: FontWeight.bold),
          ),
        ),
      );
    }

    final borderColor = hasError ? _errorRed : _borderColor;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(label),
        const SizedBox(height: 8),
        TextField(
          key: ValueKey('book_field_$fieldKey'),
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          maxLength: maxLength,
          onChanged: (_) {
            // Editou o campo: o erro vindo do servidor deixa de valer.
            if (_fieldErrors.containsKey(fieldKey)) {
              setState(() => _fieldErrors.remove(fieldKey));
            }
          },
          decoration: InputDecoration(
            hintText: hint,
            counterText: '',
            prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: _buttonGreen, size: 20) : null,
            suffixIcon: suffixIcon,
            suffixIconConstraints: const BoxConstraints(minWidth: 32, minHeight: 20),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: borderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: hasError ? _errorRed : _buttonGreen, width: 1.5),
            ),
          ),
        ),
        if (hasError) _FieldErrorText(errorText),
      ],
    );
  }

  /// Mostra os bytes da capa nova; se não houver, a capa atual do servidor.
  Widget _buildCoverPreview({
    Uint8List? bytes,
    String? url,
    required double width,
    required double height,
  }) {
    final hasBytes = bytes != null && bytes.isNotEmpty;

    if (!hasBytes && url == null) {
      return Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: const Color(0xFFEBE8E0),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: _borderColor),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_photo_alternate_outlined, size: 48, color: Color(0xFFBCAAA4)),
            SizedBox(height: 8),
            Text(
              'Sem capa definida',
              style: TextStyle(color: Color(0xFF8C7A70), fontSize: 13, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 4),
            Text('Toque para adicionar', style: TextStyle(color: Color(0xFFBCAAA4), fontSize: 11)),
          ],
        ),
      );
    }

    Widget fallback() => Container(
      width: width,
      height: height,
      color: const Color(0xFFEBE8E0),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.broken_image_outlined, size: 36, color: Color(0xFFBCAAA4)),
            SizedBox(height: 6),
            Text('Erro na imagem', style: TextStyle(color: Color(0xFF8C7A70), fontSize: 11)),
          ],
        ),
      ),
    );

    final Widget image = hasBytes
        ? Image.memory(bytes, fit: BoxFit.cover, width: width, height: height, errorBuilder: (_, _, _) => fallback())
        : Image.network(url!, fit: BoxFit.cover, width: width, height: height, errorBuilder: (_, _, _) => fallback());

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: image,
    );
  }
}

class _FieldErrorText extends StatelessWidget {
  const _FieldErrorText(this.message);

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 6, left: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 1),
            child: Icon(Icons.warning_amber_rounded, size: 14, color: _errorRed),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: _errorRed, fontSize: 11, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}