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
            texto: 'Sair',
            icone: Icons.logout,
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => LoginScreen()),
              );
            },
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
}
