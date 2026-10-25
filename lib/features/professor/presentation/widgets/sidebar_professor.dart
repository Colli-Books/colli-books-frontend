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
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: AppSizes.spacingSm),
                  _buildSocialCard(
                    icon: FontAwesomeIcons.instagram,
                    name: 'Instagram',
                    handle: '@collibooks',
                    brandColor: const Color(0xFFE1306C),
                    onTap: () => _abrirLink('https://www.instagram.com/collibooks/'),
                  ),
                  _buildSocialCard(
                    icon: FontAwesomeIcons.youtube,
                    name: 'YouTube',
                    handle: 'Colli Books',
                    brandColor: const Color(0xFFCD201F),
                    onTap: () => _abrirLink('https://www.youtube.com/channel/UCFZuip1s5lKOJ_RuZwmpG9g'),
                  ),
                  _buildSocialCard(
                    icon: FontAwesomeIcons.facebook,
                    name: 'Facebook',
                    handle: 'collibooks',
                    brandColor: const Color(0xFF1877F2),
                    onTap: () => _abrirLink('https://www.facebook.com/collibooks/'),
                  ),
                  const SizedBox(height: AppSizes.spacingMd),
                  const Divider(color: Color(0xFFEBE8E0), height: 1),
                  const SizedBox(height: AppSizes.spacingSm),
                  InkWell(
                    onTap: () => _confirmarLogout(context),
                    borderRadius: BorderRadius.circular(8),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        children: [
                          Icon(Icons.logout_rounded, color: AppColors.danger, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Sair da Conta',
                            style: TextStyle(
                              color: AppColors.danger,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
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

  Widget _buildSocialCard({
    required FaIconData icon,
    required String name,
    required String handle,
    required Color brandColor,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E0D5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: brandColor.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: FaIcon(icon, color: brandColor, size: 16),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          color: Color(0xFF4A2525),
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        handle,
                        style: const TextStyle(
                          color: Color(0xFF8C7A70),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.open_in_new_rounded,
                  size: 14,
                  color: Color(0xFFBCAAA4),
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
