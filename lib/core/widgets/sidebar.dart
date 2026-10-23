import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/institucional/presentation/screens/politica_privacidade_screen.dart';
import '../../features/institucional/presentation/screens/sobre_nos_screen.dart';
import '../../features/institucional/presentation/screens/termos_uso_screen.dart';
import '../theme/colors.dart';
import '../theme/sizes.dart';
import 'botaoTerciario.dart';
import 'icon.dart';

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
    final Iterable<SidebarItem> itemsAdicionais = [
      SidebarItem(
        label: 'Editora',
        icon: Icons.library_books_outlined,
        onTap: () {
          abrirLink('https://www.collibooks.com/editora/');
        },
      ),
      SidebarItem(
        label: 'PNLD',
        icon: Icons.flag_outlined,
        onTap: () {
          abrirLink('https://www.collibooks.com/pnld-2/');
        },
      ),
      SidebarItem(
        label: 'Blog',
        icon: Icons.edit_note_outlined,
        onTap: () {
          abrirLink('https://www.collibooks.com/category/blog/');
        },
      ),
      SidebarItem(
        label: 'Anima Kids',
        icon: Icons.star_border,
        onTap: () {
          abrirLink('https://www.collibooks.com/anima-kids/');
        },
      ),
      SidebarItem(
        label: 'Sobre Nós',
        icon: Icons.info_outline,
        onTap: () {
          SobreNosScreen();
        },
      ),
    ];

    items.addAll(itemsAdicionais);

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
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
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
                      MaterialPageRoute(
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
                      MaterialPageRoute(
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
                Text(
                  'SIGA-NOS',
                  style: TextStyle(
                    color: AppColors.secondary,
                    fontSize: AppSizes.fontXSmall,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: AppSizes.spacingXMd),
                Row(
                  children: [
                    SocialIcon(
                      icon: Icons.facebook,
                      color: AppColors.primary,
                      onTap: () =>
                          abrirLink('https://www.facebook.com/collibooks/'),
                    ),
                    const SizedBox(width: AppSizes.spacingXMd),
                    SocialIcon(
                      icon: Icons.camera_alt_outlined,
                      color: AppColors.primary,
                      onTap: () =>
                          abrirLink('https://www.instagram.com/collibooks/'),
                    ),
                    const SizedBox(width: AppSizes.spacingXMd),
                    SocialIcon(
                      icon: Icons.play_circle_outline,
                      color: AppColors.primary,
                      onTap: () => abrirLink(
                        'https://www.youtube.com/channel/UCFZuip1s5lKOJ_RuZwmpG9g',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Rodapé
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.spacingMd),
              child: BotaoTerciario(
                texto: 'Sair',
                icone: Icons.logout,
                cor: AppColors.danger,
                isVertical: false,
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
