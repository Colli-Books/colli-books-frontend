import 'package:flutter/material.dart';

import 'catalogo_data.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/theme/sizes.dart';
import '../../../../core/widgets/botaoPrincipal.dart';
import '../../../../core/widgets/botaoSecundario.dart';
import '../../../../core/widgets/botaoTerciario.dart';

class CadastrarTemaScreen extends StatefulWidget {
  const CadastrarTemaScreen({super.key});

  @override
  State<CadastrarTemaScreen> createState() => _CadastrarTemaScreenState();
}

class _CadastrarTemaScreenState extends State<CadastrarTemaScreen> {
  final TextEditingController _controller = TextEditingController();

  void _cadastrar() {
    final value = _controller.text.trim();
    if (value.isEmpty) return;

    if (CatalogoData.temas.any((e) => e.toLowerCase() == value.toLowerCase())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Este tema já existe!'),
          backgroundColor: AppColors.danger,
        ),
      );
    } else {
      setState(() {
        CatalogoData.temas.add(value);
        _controller.clear();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Tema "$value" cadastrado com sucesso!'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  void _confirmarExclusao(String item) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text(
          'Confirmar Exclusão',
          style: TextStyle(
            color: AppColors.titleText,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Deseja realmente excluir o tema "$item"?',
          style: const TextStyle(color: AppColors.textPrimary),
        ),
        actions: [
          BotaoTerciario(
            texto: 'Cancelar',
            cor: AppColors.textSecondary,
            onPressed: () => Navigator.pop(ctx),
          ),
          BotaoTerciario(
            texto: 'Excluir',
            cor: AppColors.danger,
            onPressed: () {
              Navigator.pop(ctx);
              setState(() {
                CatalogoData.temas.remove(item);
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Tema excluído!'),
                  backgroundColor: AppColors.danger,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
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
              'Cadastrar Tema',
              style: TextStyle(
                color: AppColors.titleText,
                fontSize: AppSizes.fontHeading,
                fontWeight: FontWeight.w800,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSizes.spacingXl),

            // Container do Formulário
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
                    'Tema',
                    style: TextStyle(
                      color: AppColors.titleText,
                      fontSize: AppSizes.fontBody,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: AppSizes.spacingSm),

                  TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Ex: Bullying',
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
                  const SizedBox(height: AppSizes.spacingLg),
                  const Divider(color: AppColors.divider),
                  const SizedBox(height: AppSizes.spacingLg),

                  // Botões baseados no Design da imagem
                  BotaoPrincipal(
                    texto: 'Cadastrar Tema',
                    icone: Icons.add_circle_outline,
                    onPressed: _cadastrar,
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

            const SizedBox(height: AppSizes.spacingXl),

            // Lista de itens cadastrados
            const Text(
              'Temas Cadastrados',
              style: TextStyle(
                color: AppColors.titleText,
                fontSize: AppSizes.fontTitle,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: AppSizes.spacingMd),

            ...CatalogoData.temas.map(
              (t) => Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: AppSizes.spacingSm),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.spacingMd,
                  vertical: AppSizes.spacingSm,
                ),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        t,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.delete_outline,
                        color: AppColors.danger,
                      ),
                      onPressed: () => _confirmarExclusao(t),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
