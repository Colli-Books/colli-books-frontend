import 'package:flutter/material.dart';
import 'catalogo_data.dart';

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
  late TextEditingController _anoController;
  late TextEditingController _paginasController;
  late TextEditingController _sinopseController;

  @override
  void initState() {
    super.initState();
    _selectedEscolaridades = List.from(widget.bookData['escolaridades'] ?? []);
    _selectedTemas = List.from(widget.bookData['temas'] ?? []);
    
    _titleController = TextEditingController(text: widget.bookData['title']);
    _authorController = TextEditingController(text: widget.bookData['author']);
    _editoraController = TextEditingController(text: 'Agir');
    _isbnController = TextEditingController(text: '9788520922593');
    _anoController = TextEditingController(text: '2009');
    _paginasController = TextEditingController(text: '96');
    _sinopseController = TextEditingController();
    
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
    _anoController.dispose();
    _paginasController.dispose();
    _sinopseController.dispose();
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

                  _buildTextField('Ano de Publicação', _anoController),
                  const SizedBox(height: 16),

                  _buildTextField('Nº de Páginas', _paginasController),
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
                    maxLines: 5,
                    maxLength: 1000,
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
                  const SizedBox(height: 32),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        final updatedBook = {
                          ...widget.bookData,
                          'title': _titleController.text,
                          'author': _authorController.text,
                          'escolaridades': _selectedEscolaridades,
                          'temas': _selectedTemas,
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

  Widget _buildTextField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Color(0xFF4A2525), fontSize: 14, fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          decoration: InputDecoration(
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
    required Function(List<String>) onConfirm,
  }) {
    List<String> tempSelected = List.from(selectedItems);
    showDialog(
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
