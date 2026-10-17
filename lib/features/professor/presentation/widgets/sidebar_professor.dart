import 'package:flutter/material.dart';

import '../../../../core/widgets/sidebar.dart';

class SidebarProfessor extends StatelessWidget {
  const SidebarProfessor({super.key});

  @override
  Widget build(BuildContext context) {
    return Sidebar(
      // Passamos a lista de botões específicos do professor
      items: [
        SidebarItem(
          label: 'Catálogo Geral',
          icon: Icons.menu_book_outlined,
          onTap: () {
            // Navegação para catálogo
          },
        ),
        SidebarItem(
          label: 'Editora',
          icon: Icons.apartment_outlined,
          onTap: () {
            // Navegação para editora
          },
        ),
        SidebarItem(
          label: 'PNLD',
          icon: Icons.flag_outlined,
          onTap: () {
            // Navegação para PNLD
          },
        ),
        SidebarItem(
          label: 'Blog',
          icon: Icons.article_outlined,
          onTap: () {
            // Navegação para blog
          },
        ),
        SidebarItem(
          label: 'Anima Kids',
          icon: Icons.star_border,
          onTap: () {
            // Navegação para Anima Kids
          },
        ),
        SidebarItem(
          label: 'Sobre Nós',
          icon: Icons.info_outline,
          onTap: () {
            // Navegação para sobre nós
          },
        ),
      ],
      // Passamos o botão de deslogar (Obrigatório no molde que criamos)
      logoutItem: SidebarItem(
        label: 'Sair',
        icon: Icons.logout,
        onTap: () {
          // Lógica de deslogar e voltar para tela de Login
          Navigator.pushReplacementNamed(context, '/login');
        },
      ),
    );
  }
}
