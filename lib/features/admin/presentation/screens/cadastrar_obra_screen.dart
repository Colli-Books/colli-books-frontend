import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/fullscreen_image_viewer.dart';
import '../../data/catalogo_data.dart';

class CadastrarObraScreen extends StatefulWidget {
  const CadastrarObraScreen({super.key});

  @override
  State<CadastrarObraScreen> createState() => _CadastrarObraScreenState();
}

class _CadastrarObraScreenState extends State<CadastrarObraScreen> {
  List<String> _selectedEscolaridades = [];
  List<String> _selectedTemas = [];

  late TextEditingController _titleController;
  late TextEditingController _authorController;
  late TextEditingController _isbnController;
  late TextEditingController _sinopseController;
  late TextEditingController _bookUrlController;
  late TextEditingController _storeUrlController;
  late TextEditingController _lpUrlController;
  String? _coverImagePath;
  Uint8List? _coverBytes;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _authorController = TextEditingController();
    _isbnController = TextEditingController();
    _sinopseController = TextEditingController();
    _bookUrlController = TextEditingController();
    _storeUrlController = TextEditingController();
    _lpUrlController = TextEditingController();

    _sinopseController.addListener(() => setState(() {}));
    _isbnController.addListener(() => setState(() {}));
    _bookUrlController.addListener(() => setState(() {}));
    _storeUrlController.addListener(() => setState(() {}));
    _lpUrlController.addListener(() => setState(() {}));
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const backgroundColor = Color(0xFFF9F5EC);
    const primaryTextColor = Color(0xFF4A2525);
    const secondaryTextColor = Color(0xFF6B6B6B);
    const buttonGreen = Color(0xFFA1A32D);
    const borderColor = Color(0xFFD6D6D6);

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
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'Cadastrar Nova Obra',
              style: TextStyle(color: primaryTextColor, fontSize: 24, fontWeight: FontWeight.w800),
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Capa da Obra', style: TextStyle(color: primaryTextColor, fontSize: 16, fontWeight: FontWeight.w800)),
                      if ((_coverImagePath != null && _coverImagePath!.isNotEmpty) || _coverBytes != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F5E9),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFA5D6A7)),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.check_circle, size: 14, color: Color(0xFF2E7D32)),
                              SizedBox(width: 4),
                              Text('Capa definida', style: TextStyle(color: Color(0xFF2E7D32), fontSize: 11, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Carregue um arquivo do seu dispositivo (PNG, JPG, PDF).',
                    style: TextStyle(color: secondaryTextColor, fontSize: 12),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: InkWell(
                      onTap: ((_coverImagePath != null && _coverImagePath!.isNotEmpty) || _coverBytes != null)
                          ? () => abrirVisualizadorImagem(
                                context,
                                imagePath: _coverImagePath,
                                coverBytes: _coverBytes,
                                title: _titleController.text.isNotEmpty ? _titleController.text : 'Capa da Obra',
                              )
                          : _showChangeCoverDialog,
                      borderRadius: BorderRadius.circular(12),
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          _buildCoverPreview(
                            imagePath: _coverImagePath,
                            coverBytes: _coverBytes,
                            width: 170,
                            height: 250,
                          ),
                          if ((_coverImagePath != null && _coverImagePath!.isNotEmpty) || _coverBytes != null)
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
                                    Text('Tela Cheia', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
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
                        label: const Text(
                          'Carregar Capa',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: buttonGreen,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                      if ((_coverImagePath != null && _coverImagePath!.isNotEmpty) || _coverBytes != null)
                        OutlinedButton.icon(
                          onPressed: () {
                            setState(() {
                              _coverImagePath = null;
                              _coverBytes = null;
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Capa removida.'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          },
                          icon: const Icon(Icons.delete_outline, color: Color(0xFFC62828), size: 18),
                          label: const Text('Remover Capa', style: TextStyle(color: Color(0xFFC62828), fontWeight: FontWeight.bold)),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            side: const BorderSide(color: Color(0xFFEF9A9A)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  _buildTextField('Título da Obra', 'Ex: O Pequeno Príncipe', _titleController),
                  const SizedBox(height: 16),

                  _buildTextField('Autor(a)', 'Nome do autor', _authorController),
                  const SizedBox(height: 16),

                  _buildTextField(
                    'ISBN',
                    '978-65-6079-046-9',
                    _isbnController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [IsbnInputFormatter()],
                    isIsbnField: true,
                  ),
                  const SizedBox(height: 16),


                  const Text('Escolaridade', style: TextStyle(color: primaryTextColor, fontSize: 14, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: () {
                      _showMultiSelectDialog(
                        title: 'Selecionar Escolaridades',
                        allItems: CatalogoData.escolaridades,
                        selectedItems: _selectedEscolaridades,
                        onConfirm: (results) {
                          setState(() {
                            _selectedEscolaridades = results;
                          });
                        },
                      );
                    },
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: _selectedEscolaridades.isNotEmpty ? const Color(0xFFA1A32D) : borderColor,
                          width: _selectedEscolaridades.isNotEmpty ? 1.5 : 1.0,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.02),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.school_outlined, color: Color(0xFFA1A32D), size: 20),
                              const SizedBox(width: 10),
                              if (_selectedEscolaridades.isEmpty)
                                const Text(
                                  'Selecione as escolaridades atendidas...',
                                  style: TextStyle(color: Color(0xFF9E9E9E), fontSize: 14),
                                )
                              else
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFD4E6F1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    '${_selectedEscolaridades.length} selecionada(s)',
                                    style: const TextStyle(
                                      color: Color(0xFF1B4F72),
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _selectedEscolaridades.isEmpty ? 'Escolher' : 'Alterar',
                                style: const TextStyle(
                                  color: Color(0xFFA1A32D),
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Icon(Icons.arrow_drop_down, color: Color(0xFFA1A32D)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (_selectedEscolaridades.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _selectedEscolaridades.map((e) => _buildEscolaridadeChip(e)).toList(),
                    ),
                  ],
                  const SizedBox(height: 20),

                  const Text('Temas Abordados', style: TextStyle(color: primaryTextColor, fontSize: 14, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: () {
                      _showMultiSelectDialog(
                        title: 'Selecionar Temas',
                        allItems: CatalogoData.temas,
                        selectedItems: _selectedTemas,
                        onConfirm: (results) {
                          setState(() {
                            _selectedTemas = results;
                          });
                        },
                      );
                    },
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: _selectedTemas.isNotEmpty ? const Color(0xFFA1A32D) : borderColor,
                          width: _selectedTemas.isNotEmpty ? 1.5 : 1.0,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.02),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.category_outlined, color: Color(0xFFA1A32D), size: 20),
                              const SizedBox(width: 10),
                              if (_selectedTemas.isEmpty)
                                const Text(
                                  'Selecione os temas abordados...',
                                  style: TextStyle(color: Color(0xFF9E9E9E), fontSize: 14),
                                )
                              else
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFDEBD0),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    '${_selectedTemas.length} selecionado(s)',
                                    style: const TextStyle(
                                      color: Color(0xFFD35400),
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _selectedTemas.isEmpty ? 'Escolher' : 'Alterar',
                                style: const TextStyle(
                                  color: Color(0xFFA1A32D),
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Icon(Icons.arrow_drop_down, color: Color(0xFFA1A32D)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (_selectedTemas.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _selectedTemas.map((t) => _buildTemaChip(t)).toList(),
                    ),
                  ],
                  const SizedBox(height: 16),

                  const Text('Sinopse / Descrição', style: TextStyle(color: primaryTextColor, fontSize: 14, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  TextField(
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
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: borderColor)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: borderColor)),
                      counterText: '',
                    ),
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text('${_sinopseController.text.length} / 1000 caracteres', style: const TextStyle(color: Color(0xFFBCAAA4), fontSize: 12, fontWeight: FontWeight.w600)),
                  ),
                  const SizedBox(height: 24),

                  const Divider(color: Color(0xFFEBE8E0), height: 1),
                  const SizedBox(height: 24),

                  const Text(
                    'Links e Recursos da Obra',
                    style: TextStyle(color: primaryTextColor, fontSize: 16, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Acessos para leitura digital, compra e materiais complementares.',
                    style: TextStyle(color: secondaryTextColor, fontSize: 12),
                  ),
                  const SizedBox(height: 16),

                  _buildTextField(
                    'Link do Livro (Google Drive / PDF)',
                    'Ex: https://drive.google.com/file/d/...',
                    _bookUrlController,
                    prefixIcon: Icons.picture_as_pdf_outlined,
                    keyboardType: TextInputType.url,
                    isUrlField: true,
                  ),
                  const SizedBox(height: 16),

                  _buildTextField(
                    'Link da Loja',
                    'Ex: https://www.collibooksloja.com/infantil/o-segredo-de-aurora',
                    _storeUrlController,
                    prefixIcon: Icons.shopping_bag_outlined,
                    keyboardType: TextInputType.url,
                    isUrlField: true,
                  ),
                  const SizedBox(height: 16),

                  _buildTextField(
                    'Link da Página de Material Pedagógico',
                    'Ex: https://www.collibooks.com/o-segredo-de-aurora-lp/',
                    _lpUrlController,
                    prefixIcon: Icons.school_outlined,
                    keyboardType: TextInputType.url,
                    isUrlField: true,
                  ),
                  const SizedBox(height: 32),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        if (!FormValidators.isValidUrl(_bookUrlController.text) ||
                            !FormValidators.isValidUrl(_storeUrlController.text) ||
                            !FormValidators.isValidUrl(_lpUrlController.text)) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Por favor, corrija o formato dos links destacados antes de cadastrar.'),
                              backgroundColor: Color(0xFFC62828),
                              duration: Duration(seconds: 3),
                            ),
                          );
                          return;
                        }

                        final newBook = {
                          'title': _titleController.text.isNotEmpty ? _titleController.text : 'Nova Obra',
                          'author': _authorController.text.isNotEmpty ? _authorController.text : 'Autor Desconhecido',
                          'isbn': _isbnController.text,
                          'sinopse': _sinopseController.text,
                          'escolaridades': _selectedEscolaridades,
                          'temas': _selectedTemas,
                          'bookUrl': _bookUrlController.text.trim(),
                          'storeUrl': _storeUrlController.text.trim(),
                          'lpUrl': _lpUrlController.text.trim(),
                          'image': _coverImagePath ?? 'imagens/o_segredo_de_aurora.png',
                          'coverBytes': _coverBytes,
                        };
                        Navigator.pop(context, newBook);
                      },
                      icon: const Icon(Icons.add_circle_outline, color: Colors.white, size: 20),
                      label: const Text('Cadastrar Obra', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: buttonGreen,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        elevation: 0,
                      ),
                    ),
                  ),

                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    String hint,
    TextEditingController controller, {
    IconData? prefixIcon,
    List<TextInputFormatter>? inputFormatters,
    TextInputType? keyboardType,
    bool isUrlField = false,
    bool isIsbnField = false,
  }) {
    String? urlError;
    if (isUrlField && controller.text.trim().isNotEmpty) {
      urlError = FormValidators.validateUrl(controller.text);
    }

    final isbnDigits = controller.text.replaceAll(RegExp(r'\D'), '');

    Widget? suffixIcon;
    if (isUrlField && controller.text.trim().isNotEmpty) {
      if (urlError == null) {
        suffixIcon = const Tooltip(
          message: 'Link válido',
          child: Padding(
            padding: EdgeInsets.only(right: 12),
            child: Icon(Icons.check_circle_rounded, color: Color(0xFF2E7D32), size: 20),
          ),
        );
      } else {
        suffixIcon = Tooltip(
          message: urlError,
          child: const Padding(
            padding: EdgeInsets.only(right: 12),
            child: Icon(Icons.error_outline_rounded, color: Color(0xFFC62828), size: 20),
          ),
        );
      }
    } else if (isIsbnField && isbnDigits.isNotEmpty) {
      if (isbnDigits.length == 13) {
        suffixIcon = const Tooltip(
          message: 'ISBN-13 Completo',
          child: Padding(
            padding: EdgeInsets.only(right: 12),
            child: Icon(Icons.check_circle_rounded, color: Color(0xFF2E7D32), size: 20),
          ),
        );
      } else {
        suffixIcon = Padding(
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
    }

    final hasError = urlError != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Color(0xFF4A2525), fontSize: 14, fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: const Color(0xFFA1A32D), size: 20) : null,
            suffixIcon: suffixIcon,
            suffixIconConstraints: const BoxConstraints(minWidth: 32, minHeight: 20),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: hasError ? const Color(0xFFC62828) : const Color(0xFFD6D6D6)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: hasError ? const Color(0xFFC62828) : const Color(0xFFD6D6D6)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: hasError ? const Color(0xFFC62828) : const Color(0xFFA1A32D), width: 1.5),
            ),
          ),
        ),
        if (hasError)
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 4),
            child: Row(
              children: [
                const Icon(Icons.warning_amber_rounded, size: 14, color: Color(0xFFC62828)),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    urlError,
                    style: const TextStyle(color: Color(0xFFC62828), fontSize: 11, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildCoverPreview({
    String? imagePath,
    Uint8List? coverBytes,
    double width = 170,
    double height = 250,
  }) {
    final hasBytes = coverBytes != null && coverBytes.isNotEmpty;
    final hasPath = imagePath != null && imagePath.isNotEmpty;

    if (!hasBytes && !hasPath) {
      return Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: const Color(0xFFEBE8E0),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFD6D6D6)),
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
            Text(
              'Toque para adicionar',
              style: TextStyle(color: Color(0xFFBCAAA4), fontSize: 11),
            ),
          ],
        ),
      );
    }

    if (isPdfCover(imagePath, coverBytes)) {
      return buildPdfCoverThumbnail(
        width: width,
        height: height,
        label: _titleController.text.isNotEmpty ? _titleController.text : null,
      );
    }

    Widget imgWidget;
    if (hasBytes) {
      imgWidget = Image.memory(
        coverBytes,
        fit: BoxFit.cover,
        width: width,
        height: height,
        errorBuilder: (_, _, _) => _buildCoverFallback(width, height),
      );
    } else if (imagePath!.startsWith('imagens/') || imagePath.startsWith('assets/')) {
      imgWidget = Image.asset(
        imagePath,
        fit: BoxFit.cover,
        width: width,
        height: height,
        errorBuilder: (_, _, _) => _buildCoverFallback(width, height),
      );
    } else {
      imgWidget = Image.network(
        imagePath,
        fit: BoxFit.cover,
        width: width,
        height: height,
        errorBuilder: (_, _, _) => _buildCoverFallback(width, height),
      );
    }

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: imgWidget,
    );
  }

  Widget _buildCoverFallback(double width, double height) {
    return Container(
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
  }

  void _showChangeCoverDialog() {
    String? previewUrl = _coverImagePath;
    Uint8List? previewBytes = _coverBytes;

    showDialog<void>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: const Color(0xFFF9F5EC),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Row(
                children: [
                  Icon(Icons.photo_library_outlined, color: Color(0xFF4A2525)),
                  SizedBox(width: 8),
                  Text(
                    'Definir Capa da Obra',
                    style: TextStyle(color: Color(0xFF4A2525), fontWeight: FontWeight.bold, fontSize: 18),
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
                      // BOTÃO DE UPLOAD DO COMPUTADOR (IMAGEM OU PDF)
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            try {
                              final file = await FilePicker.pickFile(
                                type: FileType.custom,
                                allowedExtensions: ['png', 'jpg', 'jpeg', 'webp', 'pdf'],
                              );
                              if (file != null) {
                                final bytes = await file.readAsBytes();
                                setDialogState(() {
                                  previewBytes = bytes;
                                  previewUrl = file.name;
                                });
                              }
                            } catch (e) {
                              debugPrint('Erro ao selecionar arquivo: $e');
                            }
                          },
                          icon: const Icon(Icons.upload_file_rounded, color: Colors.white, size: 20),
                          label: const Text(
                            'Carregar Arquivo (PNG, JPG, PDF...)',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFA1A32D),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Formatos suportados: PNG, JPG, JPEG, WEBP ou documento PDF (a 1ª página será utilizada como capa).',
                        style: TextStyle(fontSize: 11, color: Color(0xFF8C7A70)),
                      ),

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
                              onTap: () => abrirVisualizadorImagem(
                                context,
                                imagePath: previewUrl,
                                coverBytes: previewBytes,
                                title: 'Pré-visualização da Capa',
                              ),
                              borderRadius: BorderRadius.circular(10),
                              child: _buildCoverPreview(
                                imagePath: previewUrl,
                                coverBytes: previewBytes,
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
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _coverImagePath = previewUrl?.isEmpty == true ? null : previewUrl;
                      _coverBytes = previewBytes;
                    });
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.check, color: Colors.white, size: 18),
                  label: const Text('Confirmar Capa', style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFA1A32D),
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

  Widget _buildEscolaridadeChip(String label) {
    return Container(
      padding: const EdgeInsets.only(left: 10, right: 6, top: 6, bottom: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFEBF5FB),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFAED6F1), width: 1.2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.school_rounded, size: 14, color: Color(0xFF1F618D)),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF1B4F72),
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 6),
          InkWell(
            onTap: () {
              setState(() {
                _selectedEscolaridades.remove(label);
              });
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(
                color: Color(0xFFD4E6F1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close_rounded, size: 13, color: Color(0xFF1B4F72)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTemaChip(String label) {
    return Container(
      padding: const EdgeInsets.only(left: 10, right: 6, top: 6, bottom: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFFDF2E9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF5CBA7), width: 1.2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.label_rounded, size: 14, color: Color(0xFFD35400)),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFFBA4A00),
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 6),
          InkWell(
            onTap: () {
              setState(() {
                _selectedTemas.remove(label);
              });
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(
                color: Color(0xFFFCE4D6),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close_rounded, size: 13, color: Color(0xFFBA4A00)),
            ),
          ),
        ],
      ),
    );
  }

  void _showMultiSelectDialog({
    required String title,
    required List<String> allItems,
    required List<String> selectedItems,
    required void Function(List<String>) onConfirm,
  }) {
    final tempSelected = List<String>.from(selectedItems);
    showDialog<void>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: Text(title, style: const TextStyle(color: Color(0xFF4A2525), fontWeight: FontWeight.bold, fontSize: 18)),
              backgroundColor: const Color(0xFFF9F5EC),
              content: SizedBox(
                width: double.maxFinite,
                child: ListView(
                  shrinkWrap: true,
                  children: allItems.map((item) {
                    return CheckboxListTile(
                      title: Text(item, style: const TextStyle(color: Color(0xFF4A2525))),
                      activeColor: const Color(0xFFA1A32D),
                      value: tempSelected.contains(item),
                      onChanged: (bool? checked) {
                        setStateDialog(() {
                          if (checked == true) {
                            tempSelected.add(item);
                          } else {
                            tempSelected.remove(item);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  onPressed: () {
                    onConfirm(tempSelected);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFA1A32D)),
                  child: const Text('Aplicar', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
