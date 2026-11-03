import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../features/institucional/presentation/screens/politica_privacidade_screen.dart';
import '../../features/institucional/presentation/screens/sobre_nos_screen.dart';
import '../../features/institucional/presentation/screens/termos_uso_screen.dart';
import '../theme/colors.dart';
import '../theme/sizes.dart';
import 'botaoTerciario.dart';

Future<void> abrirLink(String urlStr) async {
  final Uri url = Uri.parse(urlStr);
  if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
    debugPrint('Não foi possível abrir o link: $urlStr');
  }
}

class SidebarItem extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool isLink = false;

  const SidebarItem({
    super.key,
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.textPrimary),
      title: Text(
        label,
        style: TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w600,
          decoration: isLink ? TextDecoration.underline : null,
        ),
      ),
      onTap: onTap,
    );
  }
}

class Sidebar extends StatelessWidget {
  final List<SidebarItem> items;

  const Sidebar({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    final List<SidebarItem> itemsAdicionais = [
      SidebarItem(
        label: 'Editora',
        icon: Icons.library_books_outlined,
        onTap: () {
          Navigator.pop(context);
          abrirLink('https://www.collibooks.com/editora/');
        },
      ),
      SidebarItem(
        label: 'PNLD',
        icon: Icons.flag_outlined,
        onTap: () {
          Navigator.pop(context);
          abrirLink('https://www.collibooks.com/pnld-2/');
        },
      ),
      SidebarItem(
        label: 'Blog',
        icon: Icons.edit_note_outlined,
        onTap: () {
          Navigator.pop(context);
          abrirLink('https://www.collibooks.com/category/blog/');
        },
      ),
      SidebarItem(
        label: 'Anima Kids',
        icon: Icons.star_border,
        onTap: () {
          Navigator.pop(context);
          abrirLink('https://www.collibooks.com/anima-kids/');
        },
      ),
      SidebarItem(
        label: 'Sobre Nós',
        icon: Icons.info_outline,
        onTap: () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute<void>(
              builder: (context) => const SobreNosScreen(),
            ),
          );
        },
      ),
    ];

    final allItems = [...items, ...itemsAdicionais];

    return Drawer(
      backgroundColor: AppColors.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cabeçalho / Logo
          const Padding(
            padding: EdgeInsets.all(AppSizes.spacingLg),
            child: SafeArea(
              child: Text(
                'Menu Colli Books',
                style: TextStyle(
                  fontSize: AppSizes.fontTitle,
                  color: AppColors.titleText,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          const Divider(color: AppColors.divider, height: 1),

          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: AppSizes.spacingSm),
              itemCount: allItems.length,
              itemBuilder: (context, index) {
                final item = allItems[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.spacingSm,
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: BotaoTerciario(
                      texto: item.label,
                      icone: item.icon,
                      cor: AppColors.textPrimary,
                      isVertical: false,
                      onPressed: item.onTap,
                    ),
                  ),
                );
              },
            ),
          ),

          const Divider(color: AppColors.divider, height: 1),
          Padding(
            padding: const EdgeInsets.all(AppSizes.spacingLg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (context) => const TermosUsoScreen(),
                      ),
                    );
                  },
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    alignment: Alignment.centerLeft,
                  ),
                  child: Text(
                    'Termos de Uso',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (context) => const PoliticaPrivacidadeScreen(),
                      ),
                    );
                  },
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    alignment: Alignment.centerLeft,
                  ),
                  child: Text(
                    'Política de Privacidade',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: AppSizes.spacingMd),
                const Text(
                  'SIGA-NOS',
                  style: TextStyle(
                    color: AppColors.secondary,
                    fontSize: AppSizes.fontXSmall,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: AppSizes.spacingSm),
                _buildSocialItem(
                  icon: FontAwesomeIcons.instagram,
                  name: 'Instagram',
                  brandColor: const Color(0xFFE1306C),
                  onTap: () => abrirLink('https://www.instagram.com/collibooks/'),
                ),
                _buildSocialItem(
                  icon: FontAwesomeIcons.youtube,
                  name: 'YouTube',
                  brandColor: const Color(0xFFCD201F),
                  onTap: () => abrirLink('https://www.youtube.com/channel/UCFZuip1s5lKOJ_RuZwmpG9g'),
                ),
                _buildSocialItem(
                  icon: FontAwesomeIcons.facebook,
                  name: 'Facebook',
                  brandColor: const Color(0xFF1877F2),
                  onTap: () => abrirLink('https://www.facebook.com/collibooks/'),
                ),
                _buildSocialItem(
                  icon: FontAwesomeIcons.linkedin,
                  name: 'LinkedIn',
                  brandColor: const Color(0xFF0077B5),
                  onTap: () => abrirLink('https://www.linkedin.com/in/colli-books-editora-1090071a7/'),
                ),
              ],
            ),
          ),
        ],
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
                  fontWeight: FontWeight.w600,
                  fontSize: AppSizes.fontBody,
                ),
              ),
            ),
            Icon(
              Icons.open_in_new_rounded,
              size: 15,
              color: AppColors.secondary.withValues(alpha: 0.7),
            ),
          ],
        ),
      ),
    );
  }
}
