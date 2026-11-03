import 'package:flutter/material.dart';

import '../widgets/navbar_professor.dart';
import '../widgets/sidebar_professor.dart';
import 'catalogo_professor_view.dart';
import 'perfil_professor_screen.dart';
import 'selecao_professor_screen.dart';

/// Casco da área do professor: barra, drawer, abas e navegação inferior.
/// Nome, e-mail e escola vêm do AuthController (não há mais parâmetro de e-mail).
class ProfessorHomeScreen extends StatefulWidget {
  const ProfessorHomeScreen({super.key});

  @override
  State<ProfessorHomeScreen> createState() => _ProfessorHomeScreenState();
}

class _ProfessorHomeScreenState extends State<ProfessorHomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    const backgroundColor = Color(0xFFF9F5EC);
    const primaryTextColor = Color(0xFF331212);

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: backgroundColor,
      drawer: const SidebarProfessor(),
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: primaryTextColor, size: 28),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        title: Image.asset(
          'imagens/Logo-Colli-Booksteste.webp',
          height: 38,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) => const Text(
            'Colli Books',
            style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF4A2525), fontSize: 18),
          ),
        ),
      ),
      // IndexedStack mantém a busca e a rolagem do catálogo ao trocar de aba.
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          const CatalogoProfessorView(),
          SelecaoProfessorScreen(
            active: _selectedIndex == 1,
            onExplorar: () => setState(() => _selectedIndex = 0),
          ),
          const PerfilProfessorScreen(),
        ],
      ),
      bottomNavigationBar: NavbarProfessor(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
      ),
    );
  }
}