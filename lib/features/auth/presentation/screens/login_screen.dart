import 'package:flutter/material.dart';

import '../../../../core/theme/colors.dart';
import '../../../../core/theme/sizes.dart';
import '../../../../core/widgets/botaoPrincipal.dart';
// Imports corrigidos para navegar entre as "features"
import '../../../admin/presentation/screens/admin_home_screen.dart';
import '../../../institucional/presentation/screens/fale_conosco_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;

  void _fazerLogin() {
    final email = _emailController.text.trim();
    final senha = _passwordController.text;

    // Lógica provisória de autenticação
    if (email == 'admin' && senha == '123') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const AdminHomeScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Credenciais incorretas! Tente admin / 123'),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          AppColors.surface, // Usamos o nosso bege claro do sistema
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.spacingLg),
            child: Container(
              width: 400, // Largura máxima do card de login mantida
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // PARTE SUPERIOR DO CARD (Logo e Título)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      vertical: 40,
                      horizontal: AppSizes.spacingLg,
                    ),
                    decoration: const BoxDecoration(
                      color: AppColors
                          .inputBackground, // Bege de destaque para o topo
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(AppSizes.radiusLg),
                      ),
                      border: Border(
                        bottom: BorderSide(color: AppColors.border, width: 1),
                      ),
                    ),
                    child: Column(
                      children: [
                        // Logo da Editora
                        Image.asset(
                          'imagens/Logo-Colli-Booksteste.webp',
                          height: 64,
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(height: AppSizes.spacingXl),
                        const Text(
                          'Bem-vindo ao Portal Colli\nBooks',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.titleText,
                            fontSize: AppSizes.fontHeading,
                            fontWeight: FontWeight.w700,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // PARTE INFERIOR DO CARD (Formulário)
                  Padding(
                    padding: const EdgeInsets.all(AppSizes.spacingXl),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Campo de E-mail
                        const Text(
                          'E-mail',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: AppSizes.fontBody,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: AppSizes.spacingSm),
                        TextField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            hintText: 'seu@email.com',
                            prefixIcon: const Icon(
                              Icons.email_outlined,
                              color: AppColors.textSecondary,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                AppSizes.radiusSm,
                              ),
                              borderSide: const BorderSide(
                                color: AppColors.divider,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                AppSizes.radiusSm,
                              ),
                              borderSide: const BorderSide(
                                color: AppColors.divider,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                AppSizes.radiusSm,
                              ),
                              borderSide: const BorderSide(
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSizes.spacingLg),

                        // Campo de Senha
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Senha',
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: AppSizes.fontBody,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            TextButton(
                              onPressed: () {},
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: const Text(
                                'Esqueci minha senha',
                                style: TextStyle(
                                  color: AppColors.activeBadgeText, // Aproveitámos a cor Cyan do sistema
                                  fontSize: AppSizes.fontSmall,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSizes.spacingSm),
                        TextField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            hintText: '••••••••',
                            prefixIcon: const Icon(
                              Icons.lock_outline,
                              color: AppColors.textSecondary,
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: AppColors.textSecondary,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                AppSizes.radiusSm,
                              ),
                              borderSide: const BorderSide(
                                color: AppColors.divider,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                AppSizes.radiusSm,
                              ),
                              borderSide: const BorderSide(
                                color: AppColors.divider,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                AppSizes.radiusSm,
                              ),
                              borderSide: const BorderSide(
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSizes.spacingXl),

                        // Botão Entrar (Substituído pelo nosso componente)
                        BotaoPrincipal(
                          texto: 'Entrar',
                          icone: Icons.login,
                          onPressed: _fazerLogin,
                        ),
                      ],
                    ),
                  ),

                  // RODAPÉ DO CARD
                  const Divider(height: 1, color: AppColors.divider),
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const FaleConoscoScreen(),
                        ),
                      );
                    },
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(AppSizes.radiusLg),
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSizes.spacingLg,
                        horizontal: AppSizes.spacingXl,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.info_outline,
                            size: 18,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: AppSizes.spacingSm),
                          const Expanded(
                            child: Text(
                              'Acesso exclusivo mediante convite\ninstitucional. Clique para Fale Conosco',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: AppSizes.fontSmall,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
