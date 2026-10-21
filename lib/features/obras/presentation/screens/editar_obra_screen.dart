import 'package:flutter/material.dart';

import 'catalogo_data.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/theme/sizes.dart';
import '../../../../core/widgets/botaoPrincipal.dart';
import '../../../../core/widgets/botaoSecundario.dart';
import '../../../../core/widgets/botaoTerciario.dart';

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

    // Avisamos que é uma Lista e fazemos o cast de forma segura
    final escolaridades =
        widget.bookData['escolaridades'] as List<dynamic>? ?? [];
    _selectedEscolaridades = List<String>.from(escolaridades);

    final temas = widget.bookData['temas'] as List<dynamic>? ?? [];
    _selectedTemas = List<String>.from(temas);

    // Usamos o ?.toString() para garantir ao Flutter que passamos uma String para o Controller
    _titleController = TextEditingController(
      text: widget.bookData['title']?.toString(),
    );
    _authorController = TextEditingController(
      text: widget.bookData['author']?.toString(),
    );
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
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leadingWidth: 120,
        leading: BotaoTerciario(
          texto: 'Voltar',
          icone: Icons.arrow_back,
          cor: AppColors.titleText,
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.spacingLg,
          vertical: AppSizes.spacingMd,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Edição de Obra',
              style: TextStyle(
                color: AppColors.titleText,
                fontSize: AppSizes.fontHeading,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: AppSizes.spacingSm),
            const Text(
              'Atualize as informações bibliográficas no acervo.',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: AppSizes.fontBody,
              ),
            ),
            const SizedBox(height: AppSizes.spacingXl),

            // Secção: Capa da Obra
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSizes.spacingLg),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Capa da Obra',
                    style: TextStyle(
                      color: AppColors.titleText,
                      fontSize: AppSizes.fontTitle,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: AppSizes.spacingMd),
                  Container(
                    width: double.infinity,
                    height: 300,
                    decoration: BoxDecoration(
                      color: AppColors.inputBackground,
                      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                    ),
                    // Aqui entraria a imagem da capa da obra selecionada
                  ),
                  const SizedBox(height: AppSizes.spacingMd),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(
                        Icons.delete_outline,
                        color: AppColors.danger,
                        size: 18,
                      ),
                      label: const Text(
                        'Remover Capa',
                        style: TextStyle(
                          color: AppColors.danger,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          vertical: AppSizes.spacingMd,
                        ),
                        side: const BorderSide(color: AppColors.danger),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppSizes.radiusMd,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSizes.spacingXl),

            // Secção: Informações Bibliográficas
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSizes.spacingLg),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Informações Bibliográficas',
                    style: TextStyle(
                      color: AppColors.titleText,
                      fontSize: AppSizes.fontTitle,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: AppSizes.spacingLg),

                  _buildTextField('Título da Obra *', _titleController),
                  const SizedBox(height: AppSizes.spacingMd),

                  _buildTextField('Autor(es) *', _authorController),
                  const SizedBox(height: AppSizes.spacingMd),

                  _buildTextField('Editora', _editoraController),
                  const SizedBox(height: AppSizes.spacingMd),

                  _buildTextField('ISBN', _isbnController),
                  const SizedBox(height: AppSizes.spacingMd),

                  _buildTextField('Ano de Publicação', _anoController),
                  const SizedBox(height: AppSizes.spacingMd),

                  _buildTextField('Nº de Páginas', _paginasController),
                  const SizedBox(height: AppSizes.spacingMd),

                  const Text(
                    'Escolaridade',
                    style: TextStyle(
                      color: AppColors.titleText,
                      fontSize: AppSizes.fontBody,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: AppSizes.spacingSm),
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
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSizes.spacingMd,
                        vertical: AppSizes.spacingMd,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.cardBackground,
                        borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                        border: Border.all(color: AppColors.divider),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              _selectedEscolaridades.isEmpty
                                  ? 'Selecione a(s) escolaridade(s)...'
                                  : '${_selectedEscolaridades.length} selecionada(s)',
                              style: TextStyle(
                                color: _selectedEscolaridades.isEmpty
                                    ? AppColors.textSecondary
                                    : AppColors.textPrimary,
                                fontSize: AppSizes.fontBody,
                              ),
                            ),
                          ),
                          const Icon(
                            Icons.arrow_drop_down,
                            color: AppColors.textSecondary,
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (_selectedEscolaridades.isNotEmpty) ...[
                    const SizedBox(height: AppSizes.spacingSm),
                    Wrap(
                      spacing: AppSizes.spacingSm,
                      runSpacing: AppSizes.spacingSm,
                      children: _selectedEscolaridades
                          .map((e) => _buildOutlinedChip(e))
                          .toList(),
                    ),
                  ],
                  const SizedBox(height: AppSizes.spacingMd),

                  const Text(
                    'Temas Abordados:',
                    style: TextStyle(
                      color: AppColors.titleText,
                      fontSize: AppSizes.fontBody,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: AppSizes.spacingSm),
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
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSizes.spacingMd,
                        vertical: AppSizes.spacingMd,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.cardBackground,
                        borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                        border: Border.all(color: AppColors.divider),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              _selectedTemas.isEmpty
                                  ? 'Selecione o(s) tema(s)...'
                                  : '${_selectedTemas.length} selecionado(s)',
                              style: TextStyle(
                                color: _selectedTemas.isEmpty
                                    ? AppColors.textSecondary
                                    : AppColors.textPrimary,
                                fontSize: AppSizes.fontBody,
                              ),
                            ),
                          ),
                          const Icon(
                            Icons.arrow_drop_down,
                            color: AppColors.textSecondary,
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (_selectedTemas.isNotEmpty) ...[
                    const SizedBox(height: AppSizes.spacingSm),
                    Wrap(
                      spacing: AppSizes.spacingSm,
                      runSpacing: AppSizes.spacingSm,
                      children: _selectedTemas
                          .map((t) => _buildOutlinedChip(t))
                          .toList(),
                    ),
                  ],
                  const SizedBox(height: AppSizes.spacingMd),

                  const Text(
                    'Sinopse / Descrição',
                    style: TextStyle(
                      color: AppColors.titleText,
                      fontSize: AppSizes.fontBody,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: AppSizes.spacingSm),
                  TextField(
                    controller: _sinopseController,
                    maxLines: 5,
                    maxLength: 1000,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: AppColors.cardBackground,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppSizes.spacingMd,
                        vertical: AppSizes.spacingMd,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                        borderSide: const BorderSide(color: AppColors.divider),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                        borderSide: const BorderSide(color: AppColors.divider),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                        borderSide: const BorderSide(color: AppColors.primary),
                      ),
                      counterText: '',
                    ),
                  ),
                  const SizedBox(height: AppSizes.spacingSm),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      '${_sinopseController.text.length} / 1000 caracteres',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: AppSizes.fontSmall,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSizes.spacingXl),

                  BotaoPrincipal(
                    texto: 'Salvar Alterações',
                    icone: Icons.edit_document,
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
                  ),
                  const SizedBox(height: AppSizes.spacingMd),
                  BotaoSecundario(
                    texto: 'Cancelar',
                    icone: Icons.close,
                    onPressed: () => Navigator.pop(context),
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
        Text(
          label,
          style: const TextStyle(
            color: AppColors.titleText,
            fontSize: AppSizes.fontBody,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: AppSizes.spacingSm),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.cardBackground,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSizes.spacingMd,
              vertical: AppSizes.spacingMd,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusSm),
              borderSide: const BorderSide(color: AppColors.divider),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusSm),
              borderSide: const BorderSide(color: AppColors.divider),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusSm),
              borderSide: const BorderSide(color: AppColors.primary),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOutlinedChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.spacingMd,
        vertical: AppSizes.spacingSm,
      ),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppSizes.radiusSm),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: AppSizes.fontBody,
          fontWeight: FontWeight.w500,
        ),
      ),
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
              backgroundColor: AppColors.surface,
              title: Text(
                title,
                style: const TextStyle(
                  color: AppColors.titleText,
                  fontWeight: FontWeight.bold,
                  fontSize: AppSizes.fontTitle,
                ),
              ),
              content: SizedBox(
                width: double.maxFinite,
                child: ListView(
                  shrinkWrap: true,
                  children: allItems.map((item) {
                    return CheckboxListTile(
                      title: Text(
                        item,
                        style: const TextStyle(color: AppColors.textPrimary),
                      ),
                      activeColor: AppColors.primary,
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
                BotaoTerciario(
                  texto: 'Cancelar',
                  cor: AppColors.textSecondary,
                  onPressed: () => Navigator.pop(context),
                ),
                BotaoTerciario(
                  texto: 'Aplicar',
                  cor: AppColors.primary,
                  onPressed: () {
                    onConfirm(tempSelected);
                    Navigator.pop(context);
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }
}
