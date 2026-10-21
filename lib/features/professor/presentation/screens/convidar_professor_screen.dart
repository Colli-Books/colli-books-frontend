import 'package:flutter/material.dart';

import '../../../../core/theme/colors.dart';
import '../../../../core/theme/sizes.dart';
import '../../../../core/widgets/botaoPrincipal.dart';
import '../../../../core/widgets/botaoTerciario.dart';

class ConvidarProfessorScreen extends StatefulWidget {
  const ConvidarProfessorScreen({super.key});

  @override
  State<ConvidarProfessorScreen> createState() =>
      _ConvidarProfessorScreenState();
}

class _ConvidarProfessorScreenState extends State<ConvidarProfessorScreen> {
  final TextEditingController _emailController = TextEditingController();

  void _enviarConvite() {
    final email = _emailController.text.trim();

    if (email.isNotEmpty && email.contains('@')) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: AppColors.surface,
          title: const Text(
            'Confirmar Envio',
            style: TextStyle(
              color: AppColors.titleText,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'Deseja realmente enviar um convite para $email?',
            style: const TextStyle(color: AppColors.textPrimary),
          ),
          actions: [
            BotaoTerciario(
              texto: 'Não',
              cor: AppColors.danger,
              onPressed: () => Navigator.pop(context),
            ),
            BotaoTerciario(
              texto: 'Sim',
              cor: AppColors.primary,
              onPressed: () {
                Navigator.pop(context); // Fecha o dialog
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Convite enviado com sucesso para $email'),
                    backgroundColor: AppColors.primary,
                  ),
                );
                Navigator.pop(context); // Fecha a tela de convidar
              },
            ),
          ],
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, insira um e-mail válido.'),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
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
        // Substituímos o TextButton gigante pelo nosso BotaoTerciario
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
              'Convidar Professor',
              style: TextStyle(
                color: AppColors.titleText,
                fontSize: AppSizes.fontTitle,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: AppSizes.spacingMd),
            const Text(
              'Envie um convite para que o educador possa acessar a plataforma.',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: AppSizes.fontBody,
                height: 1.4,
              ),
            ),
            const SizedBox(height: AppSizes.spacingXl),

            Container(
              padding: const EdgeInsets.all(AppSizes.spacingLg),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                border: Border.all(color: AppColors.divider),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'E-mail Institucional',
                    style: TextStyle(
                      color: AppColors.titleText,
                      fontSize: AppSizes.fontSmall,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: AppSizes.spacingSm),

                  // O TextField ainda está manual, aqui é bom a gente transformar isso utilziando ai sr julio o widgets que tá criando
                  // num "InputPersonalizado" depois, mas já aplicamos as cores do sistema.
                  TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      hintText: 'Ex: maria.silva@escola.edu.br',
                      filled: true,
                      fillColor: Colors.white,
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
                  const SizedBox(height: AppSizes.spacingXl),

                  // Substituímos o ElevatedButton gigante pelo nosso BotaoPrincipal
                  BotaoPrincipal(
                    texto: 'Enviar Convite',
                    icone: Icons.send_outlined,
                    onPressed: _enviarConvite,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
