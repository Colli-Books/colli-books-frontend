import 'package:flutter/material.dart';
import 'catalogo_data.dart';

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
  late TextEditingController _anoController;
  late TextEditingController _sinopseController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _authorController = TextEditingController();
    _isbnController = TextEditingController();
    _anoController = TextEditingController();
    _sinopseController = TextEditingController();

    _sinopseController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _isbnController.dispose();
    _anoController.dispose();
    _sinopseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const backgroundColor = Color(0xFFF9F5EC);
    const primaryTextColor = Color(0xFF4A2525);
    const secondaryTextColor = Color(0xFF6B6B6B);
    const buttonGreen = Color(0xFFA1A32D);
    const buttonRed = Color(0xFFE56B6F);
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
                  const Text('Capa do Livro', style: TextStyle(color: primaryTextColor, fontSize: 14, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 32.0),
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFBDBDBD), style: BorderStyle.solid, width: 2),
                    ),
                    // Using a custom dashed border is complex, so let's just use a solid border or a dashed package.
                    // A solid border is fine for the prototype.
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: const BoxDecoration(color: Color(0xFFF3EFE4), shape: BoxShape.circle),
                          child: const Icon(Icons.image_outlined, color: primaryTextColor, size: 32),
                        ),
                        const SizedBox(height: 16),
                        const Text('Clique para fazer upload ou arraste\na imagem aqui', textAlign: TextAlign.center, style: TextStyle(color: primaryTextColor, fontWeight: FontWeight.bold, fontSize: 14)),
                        const SizedBox(height: 8),
                        const Text('PNG, JPG até 5MB', style: TextStyle(color: secondaryTextColor, fontSize: 12, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  _buildTextField('Título da Obra', 'Ex: O Pequeno Príncipe', _titleController),
                  const SizedBox(height: 16),

                  _buildTextField('Autor(a)', 'Nome do autor', _authorController),
                  const SizedBox(height: 16),

                  _buildTextField('ISBN', '978-0-000000-0-0', _isbnController),
                  const SizedBox(height: 16),

                  _buildTextField('Ano de Lançamento', 'Ex: 2023', _anoController),
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

                  const Text('Tema', style: TextStyle(color: primaryTextColor, fontSize: 14, fontWeight: FontWeight.w700)),
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
                        final newBook = {
                          'title': _titleController.text.isNotEmpty ? _titleController.text : 'Nova Obra',
                          'author': _authorController.text.isNotEmpty ? _authorController.text : 'Autor Desconhecido',
                          'escolaridades': _selectedEscolaridades,
                          'temas': _selectedTemas,
                          'image': 'https://via.placeholder.com/150',
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

  Widget _buildTextField(String label, String hint, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Color(0xFF4A2525), fontSize: 14, fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
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
