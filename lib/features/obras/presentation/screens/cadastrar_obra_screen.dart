import 'package:flutter/material.dart';

import 'catalogo_data.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/theme/sizes.dart';
import '../../../../core/widgets/botaoPrincipal.dart';
import '../../../../core/widgets/botaoSecundario.dart';
import '../../../../core/widgets/botaoTerciario.dart';

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
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'Cadastrar Nova Obra',
              style: TextStyle(
                color: AppColors.titleText,
                fontSize: AppSizes.fontHeading,
                fontWeight: FontWeight.w800,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSizes.spacingXl),

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
                    'Capa do Livro',
                    style: TextStyle(
                      color: AppColors.titleText,
                      fontSize: AppSizes.fontBody,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: AppSizes.spacingSm),

                  // Área de Upload de Imagem
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSizes.spacingXl,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                      border: Border.all(
                        color: AppColors.divider,
                        style: BorderStyle.solid,
                        width: 2,
                      ),
                    ),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: const BoxDecoration(
                            color: AppColors.inputBackground,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.image_outlined,
                            color: AppColors.titleText,
                            size: 32,
                          ),
                        ),
                        const SizedBox(height: AppSizes.spacingMd),
                        const Text(
                          'Clique para fazer upload ou arraste\na imagem aqui',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.titleText,
                            fontWeight: FontWeight.bold,
                            fontSize: AppSizes.fontBody,
                          ),
                        ),
                        const SizedBox(height: AppSizes.spacingSm),
                        const Text(
                          'PNG, JPG até 5MB',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: AppSizes.fontSmall,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSizes.spacingLg),

                  // Campos de Texto Padronizados
                  _buildTextField(
                    'Título da Obra',
                    'Ex: O Pequeno Príncipe',
                    _titleController,
                  ),
                  const SizedBox(height: AppSizes.spacingMd),

                  _buildTextField(
                    'Autor(a)',
                    'Nome do autor',
                    _authorController,
                  ),
                  const SizedBox(height: AppSizes.spacingMd),

                  _buildTextField('ISBN', '978-0-000000-0-0', _isbnController),
                  const SizedBox(height: AppSizes.spacingMd),

                  _buildTextField(
                    'Ano de Lançamento',
                    'Ex: 2023',
                    _anoController,
                  ),
                  const SizedBox(height: AppSizes.spacingMd),

                  // Seleção de Escolaridade
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

                  // Seleção de Tema
                  const Text(
                    'Tema',
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

                  // Campo de Sinopse / Descrição
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

                  // Botões Finais Padronizados
                  BotaoPrincipal(
                    texto: 'Cadastrar Obra',
                    icone: Icons.add_circle_outline,
                    onPressed: () {
                      final newBook = {
                        'title': _titleController.text.isNotEmpty
                            ? _titleController.text
                            : 'Nova Obra',
                        'author': _authorController.text.isNotEmpty
                            ? _authorController.text
                            : 'Autor Desconhecido',
                        'escolaridades': _selectedEscolaridades,
                        'temas': _selectedTemas,
                        'image': 'https://via.placeholder.com/150',
                      };
                      Navigator.pop(context, newBook);
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

  // --- Widgets Auxiliares ---

  Widget _buildTextField(
    String label,
    String hint,
    TextEditingController controller,
  ) {
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
            hintText: hint,
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
