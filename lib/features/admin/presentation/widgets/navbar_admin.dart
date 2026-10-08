import 'package:flutter/material.dart';
import '../../../../core/widgets/nvbar.dart';

class NavbarAdmin extends StatelessWidget{
  final int currentIndex;
  final ValueChanged<int> onTap;
  
  const NavbarAdmin ({
    super.key,
    required this.currentIndex,
    required this.onTap,
 });

  @override
  Widget build(BuildContext context) {
    return Navbar(
      currentIndex: currentIndex,
      onTap: onTap,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home),
          label: 'Início',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.school_outlined),
          activeIcon: Icon(Icons.school),
          label: 'Professores',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.menu_book_outlined),
          activeIcon: Icon(Icons.menu_book),
          label: 'Catálogo',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          activeIcon: Icon(Icons.person),
          label: 'Perfil',
        ),
      ],
    );
  }
}