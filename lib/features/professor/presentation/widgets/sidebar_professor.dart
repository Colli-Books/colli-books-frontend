import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/theme/colors.dart';
import '../../../../core/theme/sizes.dart';
import '../../../auth/presentation/screens/login_screen.dart';
import '../../../institucional/presentation/screens/sobre_nos_screen.dart';
import '../../../institucional/presentation/screens/termos_uso_screen.dart';
import '../../../institucional/presentation/screens/politica_privacidade_screen.dart';

class SidebarProfessor extends StatelessWidget {
  final ValueChanged<int> onSelectTab;

  const SidebarProfessor({super.key, required this.onSelectTab});

  Future<void> _abrirLink(String urlStr) async {
    final Uri url = Uri.parse(urlStr);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      debugPrint('Não foi possível abrir o link: $urlStr');
    }
  }

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
                    icon: const Icon(Icons.library_books_outlined),
                    label: 'Editora',
                    onTap: () {
                      Navigator.pop(context);
                      _abrirLink('https://www.collibooks.com/editora/');
                    },
                  ),
                  _buildItem(
                    icon: const Icon(Icons.flag_outlined),
                    label: 'PNLD',
                    onTap: () {
                      Navigator.pop(context);
                      _abrirLink('https://www.collibooks.com/pnld-2/');
                    },
                  ),
                  _buildItem(
                    icon: const Icon(Icons.edit_note_outlined),
                    label: 'Blog',
                    onTap: () {
                      Navigator.pop(context);
                      _abrirLink('https://www.collibooks.com/category/blog/');
                    },
                  ),
                  _buildItem(
                    icon: const Icon(Icons.star_outline),
                    label: 'Anima Kids',
                    onTap: () {
                      Navigator.pop(context);
                      _abrirLink('https://www.collibooks.com/anima-kids/');
                    },
                  ),
                  _buildItem(
                    icon: const Icon(Icons.info_outline),
                    label: 'Sobre Nós',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute<void>(
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
                      MaterialPageRoute<void>(
                        builder: (_) => const TermosUsoScreen(),
                      ),
                    );
                  }),
                  const SizedBox(height: AppSizes.spacingSm),
                  _buildLink('Política de Privacidade', () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute<void>(
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
                      _buildSocial(
                        FontAwesomeIcons.facebook,
                        () => _abrirLink('https://www.facebook.com/collibooks/'),
                      ),
                      const SizedBox(width: AppSizes.spacingMd),
                      _buildSocial(
                        FontAwesomeIcons.instagram,
                        () => _abrirLink('https://www.instagram.com/collibooks/'),
                      ),
                      const SizedBox(width: AppSizes.spacingMd),
                      _buildSocial(
                        FontAwesomeIcons.youtube,
                        () => _abrirLink('https://www.youtube.com/channel/UCFZuip1s5lKOJ_RuZwmpG9g'),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSizes.spacingLg),
                  InkWell(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute<void>(
                          builder: (_) => const LoginScreen(),
                        ),
                      );
                    },
                    child: const Row(
                      children: [
                        Icon(Icons.logout, color: AppColors.danger, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Sair',
                          style: TextStyle(
                            color: AppColors.danger,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
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

  Widget _buildSocial(FaIconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: FaIcon(icon, size: 18, color: AppColors.primary),
      ),
    );
  }
}
