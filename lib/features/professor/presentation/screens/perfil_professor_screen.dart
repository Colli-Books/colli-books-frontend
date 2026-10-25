import 'package:flutter/material.dart';

import '../../../../core/theme/colors.dart';
import '../../../../core/theme/sizes.dart';
import '../../../../core/widgets/botaoSecundario.dart';
import '../../../auth/presentation/screens/login_screen.dart';

class PerfilProfessorScreen extends StatelessWidget {
  final String nome;
  final String email;
  final String escola;

  const PerfilProfessorScreen({
    super.key,
    this.nome = 'Ana Silva',
    this.email = 'email@email.com',
    this.escola = 'ESCOLA PRIMAVERA',
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(AppSizes.spacingLg),
      child: Column(
        children: [
          SizedBox(height: AppSizes.spacingLg),

          // --- cabeçalho DO PROFESSOR ---
          Text(
            nome,
            style: TextStyle(
              color: AppColors.titleText,
              fontSize: AppSizes.fontHeading,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: AppSizes.spacingXs),
          Text(
            email,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: AppSizes.fontBody,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            escola.toUpperCase(),
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: AppSizes.fontSmall,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.0,
            ),
          ),

          SizedBox(height: AppSizes.spacingXl),

          // --- CARD 1: MINHAS INFORMAÇÕES ---
          _buildOptionCard(
            icon: Icons.badge_outlined,
            title: 'Minhas Informações',
            subtitle: 'Atualize suas informações pessoais.',
            onTap: () {
              // Ação futura para editar dados do perfil
            },
          ),

          SizedBox(height: AppSizes.spacingMd),

          // --- CARD 2: FALE CONOSCO ---
          _buildOptionCard(
            icon: Icons.headset_mic_outlined,
            title: 'Fale Conosco',
            subtitle: 'Sinta-se à vontade para nos enviar uma mensagem.',
            onTap: () {
              // Ação futura para suporte/contato
            },
          ),

          SizedBox(height: AppSizes.spacingXl * 1.5),

          // --- BOTÃO DE SAIR ---
          BotaoSecundario(
            texto: 'Sair da Conta',
            icone: Icons.logout,
            onPressed: () => _confirmarLogout(context),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(color: AppColors.border),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.all(AppSizes.spacingLg),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.inputBackground,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: AppColors.primary, size: 24),
                ),
                SizedBox(width: AppSizes.spacingMd),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: AppSizes.fontTitle,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(height: AppSizes.spacingXs),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: AppSizes.fontSmall,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _confirmarLogout(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFFF9F5EC),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.logout_rounded, color: Color(0xFFE56B6F)),
            SizedBox(width: 10),
            Text('Encerrar Sessão', style: TextStyle(color: Color(0xFF4A2525), fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
        content: const Text(
          'Tem certeza que deseja sair da sua conta?',
          style: TextStyle(color: Color(0xFF6B6B6B), fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar', style: TextStyle(color: Color(0xFF8C7A70), fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute<void>(builder: (context) => const LoginScreen()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE56B6F),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Sair', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
