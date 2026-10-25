import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/theme/colors.dart';
import '../../../../core/theme/sizes.dart';
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
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: AppSizes.spacingSm),
                  _buildSocialItem(
                    icon: FontAwesomeIcons.instagram,
                    name: 'Instagram',
                    brandColor: const Color(0xFFE1306C),
                    onTap: () => _abrirLink('https://www.instagram.com/collibooks/'),
                  ),
                  _buildSocialItem(
                    icon: FontAwesomeIcons.youtube,
                    name: 'YouTube',
                    brandColor: const Color(0xFFCD201F),
                    onTap: () => _abrirLink('https://www.youtube.com/channel/UCFZuip1s5lKOJ_RuZwmpG9g'),
                  ),
                  _buildSocialItem(
                    icon: FontAwesomeIcons.facebook,
                    name: 'Facebook',
                    brandColor: const Color(0xFF1877F2),
                    onTap: () => _abrirLink('https://www.facebook.com/collibooks/'),
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

  Widget _buildSocialItem({
    required FaIconData icon,
    required String name,
    required Color brandColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSizes.radiusSm),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 9.0, horizontal: 4.0),
        child: Row(
          children: [
            SizedBox(
              width: 24,
              child: Center(
                child: FaIcon(icon, color: brandColor, size: 20),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                name,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: AppSizes.fontBody,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Icon(
              Icons.open_in_new_rounded,
              size: 15,
              color: AppColors.textSecondary.withValues(alpha: 0.7),
            ),
          ],
        ),
      ),
    );
  }
}
