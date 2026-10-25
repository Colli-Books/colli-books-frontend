import 'package:flutter/material.dart';

import '../../data/catalogo_data.dart';

class EditarObraScreen extends StatefulWidget {
  final Map<String, dynamic> bookData;

  const EditarObraScreen({super.key, required this.bookData});

  @override
  State<EditarObraScreen> createState() => _EditarObraScreenState();
}

class _EditarObraScreenState extends State<EditarObraScreen> {
  List<String> _selectedEscolaridades = [];
  List<String> _selectedTemas = [];
  
  late TextEditingController _titleController;
  late TextEditingController _authorController;
  late TextEditingController _editoraController;
  late TextEditingController _isbnController;
  late TextEditingController _sinopseController;
  late TextEditingController _bookUrlController;
  late TextEditingController _storeUrlController;
  late TextEditingController _lpUrlController;

  @override
  void initState() {
    super.initState();
    _selectedEscolaridades = List<String>.from(widget.bookData['escolaridades'] as List? ?? []);
    _selectedTemas = List<String>.from(widget.bookData['temas'] as List? ?? []);
    
    _titleController = TextEditingController(text: widget.bookData['title']?.toString() ?? '');
    _authorController = TextEditingController(text: widget.bookData['author']?.toString() ?? '');
    _editoraController = TextEditingController(text: widget.bookData['editora']?.toString() ?? 'Colli Books');
    _isbnController = TextEditingController(text: widget.bookData['isbn']?.toString() ?? '');
    _sinopseController = TextEditingController(text: widget.bookData['sinopse']?.toString() ?? '');
    _bookUrlController = TextEditingController(text: widget.bookData['bookUrl']?.toString() ?? '');
    _storeUrlController = TextEditingController(text: widget.bookData['storeUrl']?.toString() ?? '');
    _lpUrlController = TextEditingController(text: widget.bookData['lpUrl']?.toString() ?? '');
    
    _sinopseController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _editoraController.dispose();
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Edição de Obra',
              style: TextStyle(color: primaryTextColor, fontSize: 24, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            const Text(
              'Atualize as informações bibliográficas no acervo.',
              style: TextStyle(color: secondaryTextColor, fontSize: 14),
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
                  const Text('Capa da Obra', style: TextStyle(color: primaryTextColor, fontSize: 18, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    height: 300,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE2E0D5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.delete_outline, color: primaryTextColor, size: 18),
                      label: const Text('Remover Capa', style: TextStyle(color: primaryTextColor, fontWeight: FontWeight.bold)),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: const BorderSide(color: Color(0xFFBCAAA4)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ),
                ],
              ),
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
                  const Text('Informações Bibliográficas', style: TextStyle(color: primaryTextColor, fontSize: 18, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 24),
                  
                  _buildTextField('Título da Obra *', _titleController),
                  const SizedBox(height: 16),
                  
                  _buildTextField('Autor(es) *', _authorController),
                  const SizedBox(height: 16),

                  _buildTextField('Editora', _editoraController),
                  const SizedBox(height: 16),

                  _buildTextField('ISBN', _isbnController),
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
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: borderColor),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              _selectedEscolaridades.isEmpty ? 'Selecione a(s) escolaridade(s)...' : '${_selectedEscolaridades.length} selecionada(s)',
                              style: TextStyle(color: _selectedEscolaridades.isEmpty ? Colors.grey : primaryTextColor, fontSize: 14),
                            ),
                          ),
                          const Icon(Icons.arrow_drop_down, color: Colors.grey),
                        ],
                      ),
                    ),
                  ),
                  if (_selectedEscolaridades.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _selectedEscolaridades.map((e) => _buildOutlinedChip(e)).toList(),
                    ),
                  ],
                  const SizedBox(height: 16),

                  const Text('Temas Abordados:', style: TextStyle(color: primaryTextColor, fontSize: 14, fontWeight: FontWeight.w700)),
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
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: borderColor),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              _selectedTemas.isEmpty ? 'Selecione o(s) tema(s)...' : '${_selectedTemas.length} selecionado(s)',
                              style: TextStyle(color: _selectedTemas.isEmpty ? Colors.grey : primaryTextColor, fontSize: 14),
                            ),
                          ),
                          const Icon(Icons.arrow_drop_down, color: Colors.grey),
                        ],
                      ),
                    ),
                  ),
                  if (_selectedTemas.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _selectedTemas.map((t) => _buildOutlinedChip(t)).toList(),
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
                    _bookUrlController,
                    hint: 'Ex: https://drive.google.com/file/d/...',
                    prefixIcon: Icons.picture_as_pdf_outlined,
                  ),
                  const SizedBox(height: 16),

                  _buildTextField(
                    'Link da Loja',
                    _storeUrlController,
                    hint: 'Ex: https://www.collibooksloja.com/infantil/o-segredo-de-aurora',
                    prefixIcon: Icons.shopping_bag_outlined,
                  ),
                  const SizedBox(height: 16),

                  _buildTextField(
                    'Link da Página de Material Pedagógico',
                    _lpUrlController,
                    hint: 'Ex: https://www.collibooks.com/o-segredo-de-aurora-lp/',
                    prefixIcon: Icons.school_outlined,
                  ),
                  const SizedBox(height: 32),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        final updatedBook = {
                          ...widget.bookData,
                          'title': _titleController.text,
                          'author': _authorController.text,
                          'editora': _editoraController.text,
                          'isbn': _isbnController.text,
                          'sinopse': _sinopseController.text,
                          'escolaridades': _selectedEscolaridades,
                          'temas': _selectedTemas,
                          'bookUrl': _bookUrlController.text.trim(),
                          'storeUrl': _storeUrlController.text.trim(),
                          'lpUrl': _lpUrlController.text.trim(),
                        };
                        Navigator.pop(context, updatedBook);
                      },
                      icon: const Icon(Icons.edit_document, color: Colors.white, size: 20),
                      label: const Text('Salvar Alterações', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
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
    TextEditingController controller, {
    String? hint,
    IconData? prefixIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Color(0xFF4A2525), fontSize: 14, fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: const Color(0xFFA1A32D), size: 20) : null,
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFD6D6D6))),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFD6D6D6))),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFA1A32D))),
          ),
        ),
      ],
    );
  }

  Widget _buildOutlinedChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFBCAAA4)),
      ),
      child: Text(label, style: const TextStyle(color: Color(0xFF4A2525), fontSize: 14, fontWeight: FontWeight.w500)),
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
