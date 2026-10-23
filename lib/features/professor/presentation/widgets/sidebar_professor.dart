import 'package:flutter/material.dart';

import '../../../../core/widgets/sidebar.dart';

class SidebarProfessor extends StatelessWidget {
  const SidebarProfessor({super.key});

  @override
  Widget build(BuildContext context) {
    return Sidebar(
      items: [
        SidebarItem(
          label: 'Catálogo Geral',
          icon: Icons.menu_book_outlined,
          onTap: () {
            // TODO: Navegação para catálogo
          },
        ),
      ],
    );
  }
}
