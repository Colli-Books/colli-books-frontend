import 'package:flutter/material.dart';

import '../../../../core/theme/colors.dart';
import '../../../../core/widgets/card.dart';
import '../../../../core/widgets/icon.dart';
import '../../../../core/widgets/text.dart';
import '../../data/catalogo_data.dart';
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
  String _filterStatus = 'Todos';

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

  List<Map<String, dynamic>> catalogBooks = List<Map<String, dynamic>>.from(CatalogoData.livros);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      drawer: const SidebarAdmin(),
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        title: Image.asset(
          'imagens/Logo-Colli-Booksteste.webp',
          height: 38,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => const Text(
            'Colli Books',
            style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF4A2525), fontSize: 18),
          ),
        ),
      ),
      body: _selectedIndex == 3
          ? const PerfilAdminScreen()
          : _selectedIndex == 2
              ? const CatalogoObrasAdminScreen()
              : _selectedIndex == 1
                  ? GestaoProfessoresScreen(initialFilterStatus: _filterStatus)
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
                            iconContainer: const SummaryCardIcon(
                              icon: Icons.menu_book_outlined,
                              iconBgColor: AppColors.surface,
                              iconColor: AppColors.primary,
                            ),
                            titleText: const TitleText(title: 'OBRAS NO CATÁLOGO'),
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
                            iconContainer: const SummaryCardIcon(
                              icon: Icons.people_alt_outlined,
                              iconBgColor: AppColors.surface,
                              iconColor: AppColors.activeBadgeText,
                            ),
                            titleText: const TitleText(title: 'PROFESSORES ATIVOS'),
                            valueText: SummaryValueText(
                              value:
                                  '${professores.where((p) => p['status'] == 'Ativo').length}',
                            ),
                            onTap: () {
                              setState(() {
                                _selectedIndex = 1;
                                _filterStatus = 'Ativo';
                              });
                            },
                          ),
                          const SizedBox(height: 16),
                          SummaryCard(
                            iconContainer: const SummaryCardIcon(
                              icon: Icons.mail_outline,
                              iconBgColor: AppColors.surface,
                              iconColor: AppColors.pendingBadgeText,
                            ),
                            titleText: const TitleText(title: 'CONVITES PENDENTES'),
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
                            iconContainer: const ActionCardIcon(
                              icon: Icons.person_add_alt_1_outlined,
                              iconBgColor: AppColors.primary,
                              iconColor: Colors.white,
                            ),
                            titleText: const TitleText(title: 'Convidar Professor'),
                            descriptionText: const ActionCardDescriptionText(
                              description:
                                  'Envie um convite de acesso para novos educadores se juntarem à plataforma.',
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute<void>(
                                  builder: (context) => const ConvidarProfessorScreen(),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 16),
                          ActionCard(
                            iconContainer: const ActionCardIcon(
                              icon: Icons.library_add_outlined,
                              iconBgColor: AppColors.titleText,
                              iconColor: Colors.white,
                            ),
                            titleText: const TitleText(title: 'Cadastrar Nova Obra'),
                            descriptionText: const ActionCardDescriptionText(
                              description:
                                  'Adicione um novo livro, artigo ou recurso educacional ao catálogo geral.',
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute<void>(
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
