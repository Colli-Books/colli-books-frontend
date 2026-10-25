import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../core/theme/colors.dart';
import '../../../../core/theme/sizes.dart';
import '../../../institucional/presentation/screens/sobre_nos_screen.dart';
import '../../../institucional/presentation/screens/termos_uso_screen.dart';
import '../../../institucional/presentation/screens/politica_privacidade_screen.dart';

class SidebarProfessor extends StatelessWidget {
  final ValueChanged<int> onSelectTab;

  const SidebarProfessor({super.key, required this.onSelectTab});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.surface,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- ITENS DE NAVEGAÇÃO PRINCIPAL ---
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  vertical: AppSizes.spacingMd,
                ),
                children: [
                  _buildItem(
                    icon: const Icon(Icons.menu_book_outlined),
                    label: 'Catálogo Geral',
                    onTap: () {
                      onSelectTab(0);
                      Navigator.pop(context);
                    },
                  ),
                  _buildItem(
                    icon: const Icon(Icons.article_outlined),
                    label: 'Editora',
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                  _buildItem(
                    icon: const Text('🇧🇷', style: TextStyle(fontSize: 18)),
                    label: 'PNLD',
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                  _buildItem(
                    icon: const Icon(Icons.edit_note),
                    label: 'Blog',
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                  _buildItem(
                    icon: const Icon(Icons.star_outline),
                    label: 'Anima Kids',
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                  _buildItem(
                    icon: const Icon(Icons.info_outline),
                    label: 'Sobre Nós',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const SobreNosScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            const Divider(color: AppColors.divider, height: 1),

            // --- RODAPÉ: TERMOS, PRIVACIDADE E REDES SOCIAIS ---
            Padding(
              padding: const EdgeInsets.all(AppSizes.spacingLg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLink('Termos de Uso', () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const TermosUsoScreen(),
                      ),
                    );
                  }),
                  const SizedBox(height: AppSizes.spacingSm),
                  _buildLink('Política de Privacidade', () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const PoliticaPrivacidadeScreen(),
                      ),
                    );
                  }),
                  const SizedBox(height: AppSizes.spacingLg),
                  const Text(
                    'SIGA-NOS',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: AppSizes.spacingSm),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      _buildSocial(FontAwesomeIcons.facebook),
                      const SizedBox(width: AppSizes.spacingMd),
                      _buildSocial(FontAwesomeIcons.instagram),
                      const SizedBox(width: AppSizes.spacingMd),
                      _buildSocial(FontAwesomeIcons.xTwitter),
                      const SizedBox(width: AppSizes.spacingMd),
                      _buildSocial(FontAwesomeIcons.youtube),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItem({
    required Widget icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: IconTheme(
        data: const IconThemeData(color: AppColors.textPrimary, size: 22),
        child: icon,
      ),
      title: Text(
        label,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: AppSizes.fontBody,
          fontWeight: FontWeight.w600,
        ),
      ),
      horizontalTitleGap: AppSizes.spacingSm,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSizes.spacingLg,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusSm),
      ),
      onTap: onTap,
    );
  }

  Widget _buildLink(String texto, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Text(
        texto,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: AppSizes.fontSmall,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildSocial(FaIconData icon) {
    return InkWell(
      onTap: () {
        // Reservado para ligar links externos futuramente
      },
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: FaIcon(icon, size: 18, color: AppColors.primary),
      ),
    );
  }
}
