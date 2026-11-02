import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../core/utils/external_links.dart';
import '../../../institucional/presentation/screens/politica_privacidade_screen.dart';
import '../../../institucional/presentation/screens/sobre_nos_screen.dart';
import '../../../institucional/presentation/screens/termos_uso_screen.dart';

const _primaryText = Color(0xFF331212);

class SidebarProfessor extends StatelessWidget {
  const SidebarProfessor({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFFF9F5EC),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 60),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _item(Icons.library_books_outlined, 'Editora',
                    isLink: true, onTap: () => openExternalLink(context, 'https://www.collibooks.com/editora/')),
                _item(Icons.flag_outlined, 'PNLD',
                    isLink: true, onTap: () => openExternalLink(context, 'https://www.collibooks.com/pnld-2/')),
                _item(Icons.edit_note_outlined, 'Blog',
                    isLink: true, onTap: () => openExternalLink(context, 'https://www.collibooks.com/category/blog/')),
                _item(Icons.star_outline, 'Anima Kids',
                    isLink: true, onTap: () => openExternalLink(context, 'https://www.collibooks.com/anima-kids/')),
                _item(Icons.info_outline, 'Sobre Nós', onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute<void>(builder: (_) => const SobreNosScreen()),
                  );
                }),
              ],
            ),
          ),
          const Divider(color: Color(0xFFEBE8E0), thickness: 1),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute<void>(builder: (_) => const TermosUsoScreen()),
                  ),
                  style: TextButton.styleFrom(padding: EdgeInsets.zero, alignment: Alignment.centerLeft),
                  child: const Text('Termos de Uso',
                      style: TextStyle(color: _primaryText, fontWeight: FontWeight.w600)),
                ),
                TextButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute<void>(builder: (_) => const PoliticaPrivacidadeScreen()),
                  ),
                  style: TextButton.styleFrom(padding: EdgeInsets.zero, alignment: Alignment.centerLeft),
                  child: const Text('Política de Privacidade',
                      style: TextStyle(color: _primaryText, fontWeight: FontWeight.w600)),
                ),
                const SizedBox(height: 16),
                const Text(
                  'SIGA-NOS',
                  style: TextStyle(
                    color: Color(0xFF8D6E63),
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 8),
                _social(context, FontAwesomeIcons.instagram, 'Instagram', const Color(0xFFE1306C),
                    'https://www.instagram.com/collibooks/'),
                _social(context, FontAwesomeIcons.youtube, 'YouTube', const Color(0xFFCD201F),
                    'https://www.youtube.com/channel/UCFZuip1s5lKOJ_RuZwmpG9g'),
                _social(context, FontAwesomeIcons.facebook, 'Facebook', const Color(0xFF1877F2),
                    'https://www.facebook.com/collibooks/'),
                _social(context, FontAwesomeIcons.linkedin, 'LinkedIn', const Color(0xFF0077B5),
                    'https://www.linkedin.com/in/colli-books-editora-1090071a7/'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _item(IconData icon, String title, {bool isLink = false, VoidCallback? onTap}) {
    return ListTile(
      leading: Icon(icon, color: _primaryText),
      title: Text(
        title,
        style: TextStyle(
          color: _primaryText,
          fontWeight: FontWeight.w600,
          decoration: isLink ? TextDecoration.underline : null,
        ),
      ),
      onTap: onTap,
    );
  }

  Widget _social(BuildContext context, FaIconData icon, String name, Color color, String url) {
    return InkWell(
      onTap: () => openExternalLink(context, url),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 9.0, horizontal: 4.0),
        child: Row(
          children: [
            SizedBox(width: 24, child: Center(child: FaIcon(icon, color: color, size: 20))),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                name,
                style: const TextStyle(
                  color: Color(0xFF4A2525),
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ),
            const Icon(Icons.open_in_new_rounded, size: 15, color: Color(0xFF8D6E63)),
          ],
        ),
      ),
    );
  }
}