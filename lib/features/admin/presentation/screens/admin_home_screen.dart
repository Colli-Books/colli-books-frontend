import 'package:flutter/material.dart';

import '../../../../core/theme/colors.dart';
import '../../../../core/widgets/card.dart';
import '../../../../core/widgets/icon.dart';
import '../../../../core/widgets/text.dart';
import '../widgets/sidebar_admin.dart';
import 'cadastrar_obra_screen.dart';
import 'catalogo_obras_admin_screen.dart';
import 'convidar_professor_screen.dart';
import 'gestao_professores_screen.dart';
import 'perfil_admin.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  int _selectedIndex = 0;

  List<Map<String, dynamic>> professores = [
    {
      'nome': 'Ana Beatriz Silva',
      'email': 'ana.beatriz@email.com',
      'escola': 'Escola Estadual Machado de Assis',
      'status': 'Ativo',
      'data': 'Entrou em 12/03/2023',
      'iniciais': 'AB',
    },
    {
      'nome': 'carlos@email.com',
      'email': 'carlos@email.com',
      'escola': '',
      'status': 'Pendente',
      'data': 'Convite enviado em 12/03/2023',
      'iniciais': 'C',
    },
    {
      'nome': 'Marcos Nogueira',
      'email': 'marcos.n@email.com',
      'escola': 'Colégio Santa Maria',
      'status': 'Ativo',
      'data': 'Entrou em 10/02/2023',
      'iniciais': 'MN',
    },
  ];

  List<Map<String, dynamic>> catalogBooks = [
    {
      'title': 'O Mistério da Floresta',
      'author': 'Ana Silva',
      'escolaridades': ['Ensino Fundamental I', 'Ensino Fundamental II'],
      'temas': ['Aventura', 'Mistério'],
      'image': 'https://via.placeholder.com/150',
    },
    {
      'title': 'O Pequeno Príncipe',
      'author': 'Antoine de S.',
      'escolaridades': ['Ensino Fundamental II'],
      'temas': ['Ficção Científica'],
      'image': 'https://via.placeholder.com/150',
    },
    {
      'title': 'Aventuras no Espaço',
      'author': 'Marcos',
      'escolaridades': ['Ensino Fundamental I'],
      'temas': ['Ficção Científica', 'Aventura'],
      'image': 'https://via.placeholder.com/150',
    },
    {
      'title': 'Histórias de Ninar',
      'author': 'Clarice',
      'escolaridades': ['Educação Infantil'],
      'temas': ['Mistério', 'Inclusão'],
      'image': 'https://via.placeholder.com/150',
    },
  ];

  @override
  Widget build(BuildContext context) {
    String _filterStatus = 'Todos';

    return Scaffold(
      backgroundColor: AppColors.surface,
      drawer: SidebarAdmin(),
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Placeholder for Logo, you can replace with Image.asset later
            Icon(Icons.spa_outlined, color: AppColors.primary, size: 28),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'COLLI',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                    height: 1.0,
                    letterSpacing: 1.0,
                  ),
                ),
                const Text(
                  'BOOKS',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                    height: 1.0,
                    letterSpacing: 1.0,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      body: _selectedIndex == 3
          ? PerfilAdminScreen()
          : _selectedIndex == 2
          ? CatalogoObrasAdminScreen()
          : _selectedIndex == 1
          ? GestaoProfessoresScreen()
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 24.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Visão Geral',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Bem-vindo ao dashboard de administração.',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // SUMMARY CARDS
                  SummaryCard(
                    iconContainer: SummaryCardIcon(
                      icon: Icons.menu_book_outlined,
                      iconBgColor: AppColors.surface,
                      iconColor: AppColors.primary,
                    ),
                    titleText: TitleText(title: 'OBRAS NO CATÁLOGO'),
                    valueText: SummaryValueText(
                      value: '${catalogBooks.length}',
                    ),
                    onTap: () {
                      setState(() {
                        _selectedIndex = 2;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  SummaryCard(
                    iconContainer: SummaryCardIcon(
                      icon: Icons.people_alt_outlined,
                      iconBgColor: AppColors.surface,
                      iconColor: AppColors.activeBadgeText,
                    ),
                    titleText: TitleText(title: 'PROFESSORES ATIVOS'),
                    valueText: SummaryValueText(
                      value:
                          '${professores.where((p) => p['status'] == 'Ativo').length}',
                    ),
                    // Teal
                    onTap: () {
                      setState(() {
                        _selectedIndex = 1;
                        _filterStatus = 'Ativo';
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  SummaryCard(
                    iconContainer: SummaryCardIcon(
                      icon: Icons.mail_outline,
                      iconBgColor: AppColors.surface,
                      iconColor: AppColors.pendingBadgeText,
                    ),
                    titleText: TitleText(title: 'CONVITES PENDENTES'),
                    valueText: SummaryValueText(
                      value:
                          '${professores.where((p) => p['status'] == 'Pendente').length}',
                    ),
                    onTap: () {
                      setState(() {
                        _selectedIndex = 1;
                        _filterStatus = 'Pendente';
                      });
                    },
                  ),

                  const SizedBox(height: 48),

                  const Text(
                    'Ações Rápidas',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ACTION CARDS
                  ActionCard(
                    iconContainer: ActionCardIcon(
                      icon: Icons.person_add_alt_1_outlined,
                      iconBgColor: AppColors.primary,
                      iconColor: Colors.white,
                    ),
                    titleText: TitleText(title: 'Convidar Professor'),
                    descriptionText: ActionCardDescriptionText(
                      description: 'Envie um convite de acesso para novos educadores se juntarem à plataforma.',
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ConvidarProfessorScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  ActionCard(
                    iconContainer: ActionCardIcon(
                      icon: Icons.library_add_outlined,
                      iconBgColor: AppColors.titleText,
                      iconColor: Colors.white,
                    ),
                    titleText: TitleText(title: 'Cadastrar Nova Obra'),
                    descriptionText: ActionCardDescriptionText(
                      description: 'Adicione um novo livro, artigo ou recurso educacional ao catálogo geral.',
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CadastrarObraScreen(),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFFF6F1E3),
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textPrimary,
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Padding(
              padding: EdgeInsets.only(bottom: 4.0),
              child: Icon(Icons.home),
            ),
            label: 'Início',
          ),
          BottomNavigationBarItem(
            icon: Padding(
              padding: EdgeInsets.only(bottom: 4.0),
              child: Icon(Icons.school_outlined),
            ),
            label: 'Professores',
          ),
          BottomNavigationBarItem(
            icon: Padding(
              padding: EdgeInsets.only(bottom: 4.0),
              child: Icon(Icons.menu_book_outlined),
            ),
            label: 'Catálogo',
          ),
          BottomNavigationBarItem(
            icon: Padding(
              padding: EdgeInsets.only(bottom: 4.0),
              child: Icon(Icons.person_outline),
            ),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}
