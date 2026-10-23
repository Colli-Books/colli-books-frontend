import 'package:flutter/material.dart';

import '../../../../core/widgets/sidebar.dart';
import '../screens/admin_home_screen.dart';

class SidebarAdmin extends StatelessWidget {
  const SidebarAdmin({super.key});

  @override
  Widget build(BuildContext context) {
    return Sidebar(
      items: [
        SidebarItem(
          label: 'Visão Geral',
          icon: Icons.menu_book_outlined,
          onTap: () {
            AdminHomeScreen();
          },
        ),
        SidebarItem(
          label: 'Catálogo Geral',
          icon: Icons.menu_book_outlined,
          onTap: () {
            // TODO: Navegação para catálogo geral do professor
          },
        ),
      ],
    );
  }
}
