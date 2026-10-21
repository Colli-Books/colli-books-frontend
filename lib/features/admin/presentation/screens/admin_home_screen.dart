import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/theme/colors.dart';
import '../../../../core/theme/sizes.dart';
import '../../../../core/widgets/botaoPrincipal.dart';
import '../../../../core/widgets/botaoSecundario.dart';
import '../../../../core/widgets/botaoTerciario.dart';
import '../../../../core/widgets/campo_busca.dart';
import '../../../../core/widgets/nvbar.dart';
import '../../../../core/widgets/sidebar.dart';
import '../../../auth/presentation/screens/login_screen.dart';
import '../../../institucional/presentation/screens/politica_privacidade_screen.dart';
import '../../../institucional/presentation/screens/sobre_nos_screen.dart';
import '../../../institucional/presentation/screens/termos_uso_screen.dart';
import '../../../obras/presentation/screens/cadastrar_escolaridade_screen.dart';
import '../../../obras/presentation/screens/cadastrar_obra_screen.dart';
import '../../../obras/presentation/screens/cadastrar_tema_screen.dart';
import '../../../obras/presentation/screens/catalogo_data.dart';
import '../../../obras/presentation/screens/editar_obra_screen.dart';
import '../../../professor/presentation/screens/convidar_professor_screen.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  int _selectedIndex = 0;
  String _searchQuery = '';
  String _filterStatus = 'Todos';
  String _searchCatalogo = '';
  List<String> _selectedEscolaridades = [];
  List<String> _selectedTemas = [];

  final List<Map<String, dynamic>> _professores = [
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

  final List<Map<String, dynamic>> _catalogBooks = [
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
    return Scaffold(
      backgroundColor: AppColors.surface,
      drawer: _buildDrawer(context),
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        scrolledUnderElevation: 0,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: AppColors.titleText),
        shape: Border(bottom: BorderSide(color: AppColors.divider)),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.spa_outlined, color: AppColors.primary, size: 28),
            SizedBox(width: AppSizes.spacingSm),
            Text(
              'COLLI BOOKS',
              style: TextStyle(
                color: AppColors.titleText,
                fontWeight: FontWeight.w900,
                fontSize: AppSizes.fontSubTitle,
                letterSpacing: 1.0,
              ),
            ),
          ],
        ),
      ),
      body: _buildSelectedTab(),
      bottomNavigationBar: Navbar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
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
      ),
    );
  }

  Widget _buildSelectedTab() {
    switch (_selectedIndex) {
      case 1:
        return _buildProfessoresTab();
      case 2:
        return _buildCatalogoTab();
      case 3:
        return _buildPerfilTab();
      default:
        return _buildInicioTab();
    }
  }

  // --- TAB 0: INÍCIO ---
  Widget _buildInicioTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(AppSizes.spacingLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Visão Geral',
            style: TextStyle(
              color: AppColors.titleText,
              fontSize: AppSizes.fontTitle,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: AppSizes.spacingXs),
          Text(
            'Bem-vindo ao dashboard de administração.',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: AppSizes.fontBody,
            ),
          ),
          SizedBox(height: AppSizes.spacingXl),

          _buildSummaryCard(
            icon: Icons.menu_book_outlined,
            title: 'OBRAS NO CATÁLOGO',
            value: '${_catalogBooks.length}',
            iconBgColor: AppColors.inputBackground,
            iconColor: AppColors.primary,
            onTap: () => setState(() => _selectedIndex = 2),
          ),
          SizedBox(height: AppSizes.spacingMd),
          _buildSummaryCard(
            icon: Icons.people_alt_outlined,
            title: 'PROFESSORES ATIVOS',
            value:
                '${_professores.where((p) => p['status'] == 'Ativo').length}',
            iconBgColor: const Color(0xFFE5F3F3),
            iconColor: const Color(0xFF4A9E9E),
            onTap: () {
              setState(() {
                _selectedIndex = 1;
                _filterStatus = 'Ativo';
              });
            },
          ),
          SizedBox(height: AppSizes.spacingMd),
          _buildSummaryCard(
            icon: Icons.mail_outline,
            title: 'CONVITES PENDENTES',
            value:
                '${_professores.where((p) => p['status'] == 'Pendente').length}',
            iconBgColor: const Color(0xFFF8E7D8),
            iconColor: const Color(0xFFC47335),
            onTap: () {
              setState(() {
                _selectedIndex = 1;
                _filterStatus = 'Pendente';
              });
            },
          ),

          SizedBox(height: AppSizes.spacingXl),
          Text(
            'Ações Rápidas',
            style: TextStyle(
              color: AppColors.titleText,
              fontSize: AppSizes.fontSubTitle,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: AppSizes.spacingMd),

          BotaoPrincipal(
            texto: 'Convidar Professor',
            icone: Icons.person_add_alt_1_outlined,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ConvidarProfessorScreen()),
              );
            },
          ),
          SizedBox(height: AppSizes.spacingMd),
          BotaoPrincipal(
            texto: 'Cadastrar Nova Obra',
            icone: Icons.library_add_outlined,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => CadastrarObraScreen()),
              );
            },
          ),
        ],
      ),
    );
  }

  // --- TAB 1: PROFESSORES ---
  Widget _buildProfessoresTab() {
    final filteredProfessores = _professores.where((p) {
      final name = (p['nome'] ?? '').toString().toLowerCase();
      final school = (p['escola'] ?? '').toString().toLowerCase();
      final query = _searchQuery.toLowerCase();
      final matchesSearch = name.contains(query) || school.contains(query);
      final matchesStatus =
          _filterStatus == 'Todos' || p['status'] == _filterStatus;
      return matchesSearch && matchesStatus;
    }).toList();

    return SingleChildScrollView(
      padding: EdgeInsets.all(AppSizes.spacingLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Gestão de Professores',
            style: TextStyle(
              color: AppColors.titleText,
              fontSize: AppSizes.fontTitle,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: AppSizes.spacingXs),
          Text(
            'Gerencie acessos e visualize os educadores cadastrados.',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: AppSizes.fontBody,
            ),
          ),
          SizedBox(height: AppSizes.spacingLg),

          BotaoPrincipal(
            texto: 'Convidar Professor',
            icone: Icons.person_add_alt_1_outlined,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ConvidarProfessorScreen()),
              );
            },
          ),
          SizedBox(height: AppSizes.spacingLg),

          CampoBusca(
            hintText: 'Buscar por nome ou escola...',
            onChanged: (val) => setState(() => _searchQuery = val),
          ),
          SizedBox(height: AppSizes.spacingSm),

          Align(
            alignment: Alignment.centerLeft,
            child: PopupMenuButton<String>(
              onSelected: (result) => setState(() => _filterStatus = result),
              itemBuilder: (context) => const [
                PopupMenuItem(value: 'Todos', child: Text('Todos')),
                PopupMenuItem(value: 'Ativo', child: Text('Ativos')),
                PopupMenuItem(value: 'Pendente', child: Text('Pendentes')),
              ],
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSizes.spacingMd,
                  vertical: AppSizes.spacingSm,
                ),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  border: Border.all(color: AppColors.border),
                  borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.filter_list,
                      color: AppColors.titleText,
                      size: 20,
                    ),
                    SizedBox(width: AppSizes.spacingXs),
                    Text(
                      'Filtro: $_filterStatus',
                      style: TextStyle(
                        color: AppColors.titleText,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: AppSizes.spacingLg),

          Text(
            '${filteredProfessores.length} professor(es) encontrado(s)',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: AppSizes.fontSmall,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: AppSizes.spacingMd),

          ...filteredProfessores
              .map((prof) => _buildProfessorCard(prof))
              .toList(),
        ],
      ),
    );
  }

  Widget _buildProfessorCard(Map<String, dynamic> prof) {
    final isAtivo = prof['status'] == 'Ativo';
    final nome = (prof['nome'] ?? '').toString();
    final email = (prof['email'] ?? '').toString();
    final escola = (prof['escola'] ?? '').toString();
    final iniciais = (prof['iniciais'] ?? '').toString();
    final data = (prof['data'] ?? '').toString();
    final statusText = (prof['status'] ?? '').toString();

    return Container(
      margin: EdgeInsets.only(bottom: AppSizes.spacingMd),
      padding: EdgeInsets.all(AppSizes.spacingLg),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundColor: AppColors.inputBackground,
                radius: 24,
                child: Text(
                  iniciais,
                  style: TextStyle(
                    color: AppColors.titleText,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(width: AppSizes.spacingMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nome,
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: AppSizes.fontSubTitle,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    if (isAtivo) ...[
                      const SizedBox(height: 2),
                      Text(
                        email,
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: AppSizes.fontSmall,
                        ),
                      ),
                    ],
                    if (escola.isNotEmpty) ...[
                      SizedBox(height: AppSizes.spacingXs),
                      Row(
                        children: [
                          Icon(
                            Icons.school_outlined,
                            size: 14,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              escola,
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: AppSizes.fontSmall,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: isAtivo
                          ? const Color(0xFFE5F3F3)
                          : const Color(0xFFF8E7D8),
                      borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.circle,
                          size: 8,
                          color: isAtivo
                              ? const Color(0xFF4A9E9E)
                              : const Color(0xFFC47335),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          statusText,
                          style: TextStyle(
                            color: isAtivo
                                ? const Color(0xFF4A9E9E)
                                : const Color(0xFFC47335),
                            fontSize: AppSizes.fontSmall,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isAtivo) ...[
                    SizedBox(height: AppSizes.spacingSm),
                    BotaoTerciario(
                      icone: Icons.delete_outline,
                      cor: AppColors.danger,
                      onPressed: () => _confirmarExclusaoProfessor(prof),
                    ),
                  ],
                ],
              ),
            ],
          ),
          SizedBox(height: AppSizes.spacingMd),
          Divider(color: AppColors.divider, height: 1),
          SizedBox(height: AppSizes.spacingSm),
          Text(
            data,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: AppSizes.fontSmall,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // --- TAB 2: CATÁLOGO ---
  Widget _buildCatalogoTab() {
    final filteredCatalogo = _catalogBooks.where((b) {
      final title = (b['title'] as String).toLowerCase();
      final author = (b['author'] as String).toLowerCase();
      final query = _searchCatalogo.toLowerCase();
      final matchesSearch = title.contains(query) || author.contains(query);

      final bookEscolaridades = b['escolaridades'] as List<String>;
      final bookTemas = b['temas'] as List<String>;

      final matchesEscolaridade =
          _selectedEscolaridades.isEmpty ||
          _selectedEscolaridades.any((e) => bookEscolaridades.contains(e));
      final matchesTema =
          _selectedTemas.isEmpty ||
          _selectedTemas.any((t) => bookTemas.contains(t));

      return matchesSearch && matchesEscolaridade && matchesTema;
    }).toList();

    return SingleChildScrollView(
      padding: EdgeInsets.all(AppSizes.spacingLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Catálogo de Obras',
            style: TextStyle(
              color: AppColors.titleText,
              fontSize: AppSizes.fontTitle,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: AppSizes.spacingXs),
          Text(
            'Gerencie o acervo literário da plataforma.',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: AppSizes.fontBody,
            ),
          ),
          SizedBox(height: AppSizes.spacingLg),

          BotaoPrincipal(
            texto: 'Adicionar Nova Obra',
            icone: Icons.add,
            onPressed: () async {
              final newBook = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => CadastrarObraScreen()),
              );
              if (newBook != null) {
                setState(() {
                  _catalogBooks.add(newBook as Map<String, dynamic>);
                });
              }
            },
          ),
          SizedBox(height: AppSizes.spacingSm),
          BotaoPrincipal(
            texto: 'Adicionar Escolaridade',
            icone: Icons.school_outlined,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CadastrarEscolaridadeScreen(),
                ),
              );
            },
          ),
          SizedBox(height: AppSizes.spacingSm),
          BotaoPrincipal(
            texto: 'Adicionar Tema',
            icone: Icons.style_outlined,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => CadastrarTemaScreen()),
              );
            },
          ),
          SizedBox(height: AppSizes.spacingLg),

          CampoBusca(
            hintText: 'Buscar por título ou autor...',
            onChanged: (val) => setState(() => _searchCatalogo = val),
          ),
          SizedBox(height: AppSizes.spacingSm),

          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: AppSizes.spacingMd),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                    ),
                    side: BorderSide(color: AppColors.border),
                    backgroundColor: AppColors.cardBackground,
                  ),
                  icon: Icon(
                    Icons.filter_list,
                    size: 16,
                    color: AppColors.titleText,
                  ),
                  label: Text(
                    _selectedEscolaridades.isEmpty
                        ? 'Escolaridades'
                        : 'Escolaridade (${_selectedEscolaridades.length})',
                    style: TextStyle(
                      color: AppColors.titleText,
                      fontSize: AppSizes.fontSmall,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  onPressed: () {
                    _showMultiSelectDialog(
                      title: 'Filtrar por Escolaridade',
                      allItems: CatalogoData.escolaridades,
                      selectedItems: _selectedEscolaridades,
                      onConfirm: (results) {
                        setState(() => _selectedEscolaridades = results);
                      },
                    );
                  },
                ),
              ),
              SizedBox(width: AppSizes.spacingSm),
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: AppSizes.spacingMd),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                    ),
                    side: BorderSide(color: AppColors.border),
                    backgroundColor: AppColors.cardBackground,
                  ),
                  icon: Icon(
                    Icons.filter_list,
                    size: 16,
                    color: AppColors.titleText,
                  ),
                  label: Text(
                    _selectedTemas.isEmpty
                        ? 'Temas'
                        : 'Temas (${_selectedTemas.length})',
                    style: TextStyle(
                      color: AppColors.titleText,
                      fontSize: AppSizes.fontSmall,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  onPressed: () {
                    _showMultiSelectDialog(
                      title: 'Filtrar por Tema',
                      allItems: CatalogoData.temas,
                      selectedItems: _selectedTemas,
                      onConfirm: (results) {
                        setState(() => _selectedTemas = results);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: AppSizes.spacingLg),

          Text(
            '${filteredCatalogo.length} obra(s) encontrada(s)',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: AppSizes.fontSmall,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: AppSizes.spacingMd),

          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: filteredCatalogo.length,
            itemBuilder: (context, index) {
              final book = filteredCatalogo[index];
              return _buildBookCard(book);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBookCard(Map<String, dynamic> book) {
    final bookEscolaridades = book['escolaridades'] as List<String>;
    final bookTemas = book['temas'] as List<String>;

    return Container(
      margin: EdgeInsets.only(bottom: AppSizes.spacingMd),
      decoration: BoxDecoration(
        color: AppColors.inputBackground,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 100,
            height: 140,
            margin: EdgeInsets.all(AppSizes.spacingSm),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(AppSizes.radiusSm),
            ),
            child: Center(
              child: Icon(
                Icons.menu_book,
                size: 32,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(AppSizes.spacingSm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          book['title'] as String,
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: AppSizes.fontBody,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Row(
                        children: [
                          BotaoTerciario(
                            icone: Icons.edit_outlined,
                            cor: AppColors.titleText,
                            onPressed: () async {
                              final updatedBook = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      EditarObraScreen(bookData: book),
                                ),
                              );
                              if (updatedBook != null) {
                                setState(() {
                                  final idx = _catalogBooks.indexOf(book);
                                  if (idx != -1) {
                                    _catalogBooks[idx] =
                                        updatedBook as Map<String, dynamic>;
                                  }
                                });
                              }
                            },
                          ),
                          BotaoTerciario(
                            icone: Icons.delete_outline,
                            cor: AppColors.danger,
                            onPressed: () => _confirmarExclusaoObra(book),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Text(
                    book['author'] as String,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: AppSizes.fontSmall,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: AppSizes.spacingSm),
                  Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: bookEscolaridades
                        .map(
                          (e) => Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFD4E6F1),
                              borderRadius: BorderRadius.circular(
                                AppSizes.radiusSm,
                              ),
                            ),
                            child: Text(
                              e,
                              style: const TextStyle(
                                fontSize: 10,
                                color: Color(0xFF1F618D),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: bookTemas
                        .map(
                          (t) => Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFDEBD0),
                              borderRadius: BorderRadius.circular(
                                AppSizes.radiusSm,
                              ),
                            ),
                            child: Text(
                              t,
                              style: const TextStyle(
                                fontSize: 10,
                                color: Color(0xFFD35400),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- TAB 3: PERFIL ---
  Widget _buildPerfilTab() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppSizes.spacingLg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Admin Colli',
              style: TextStyle(
                color: AppColors.titleText,
                fontSize: AppSizes.fontTitle,
                fontWeight: FontWeight.w800,
              ),
            ),
            SizedBox(height: AppSizes.spacingXs),
            Text(
              'Administrador Master',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: AppSizes.fontBody,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'MATRIZ COLLI BOOKS',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: AppSizes.fontSmall,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.0,
              ),
            ),
            SizedBox(height: AppSizes.spacingXl),
            BotaoSecundario(
              texto: 'Sair da Conta',
              icone: Icons.exit_to_app,
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => LoginScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // --- COMPONENTES AUXILIARES DE UI ---
  Widget _buildSummaryCard({
    required IconData icon,
    required String title,
    required String value,
    required Color iconBgColor,
    required Color iconColor,
    VoidCallback? onTap,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(color: AppColors.border),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.all(AppSizes.spacingLg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: iconBgColor,
                        borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                      ),
                      child: Icon(icon, color: iconColor, size: 20),
                    ),
                    SizedBox(width: AppSizes.spacingMd),
                    Text(
                      title,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: AppSizes.fontSmall,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: AppSizes.spacingMd),
                Text(
                  value,
                  style: TextStyle(
                    color: AppColors.titleText,
                    fontSize: 36,
                    fontWeight: FontWeight.w800,
                    height: 1.0,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Sidebar(
      items: [
        SidebarItem(
          label: 'Editora',
          icon: Icons.library_books_outlined,
          onTap: () => _abrirLink('https://www.collibooks.com/editora/'),
        ),
        SidebarItem(
          label: 'PNLD',
          icon: Icons.flag_outlined,
          onTap: () => _abrirLink('https://www.collibooks.com/pnld-2/'),
        ),
        SidebarItem(
          label: 'Blog',
          icon: Icons.edit_note_outlined,
          onTap: () => _abrirLink('https://www.collibooks.com/category/blog/'),
        ),
        SidebarItem(
          label: 'Anima Kids',
          icon: Icons.star_outline,
          onTap: () => _abrirLink('https://www.collibooks.com/anima-kids/'),
        ),
        SidebarItem(
          label: 'Sobre Nós',
          icon: Icons.info_outline,
          onTap: () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => SobreNosScreen()),
            );
          },
        ),
      ],
      logoutItem: SidebarItem(
        label: 'Sair',
        icon: Icons.logout,
        onTap: () {
          Navigator.pop(context);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => LoginScreen()),
          );
        },
      ),
    );
  }

  Future<void> _abrirLink(String urlStr) async {
    final Uri url = Uri.parse(urlStr);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      debugPrint('Não foi possível abrir o link: $urlStr');
    }
  }

  void _confirmarExclusaoProfessor(Map<String, dynamic> prof) {
    final nome = (prof['nome'] ?? '').toString();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(
          'Excluir Professor',
          style: TextStyle(color: AppColors.titleText),
        ),
        content: Text('Tem certeza que deseja excluir o professor "$nome"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancelar',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              setState(() => _professores.remove(prof));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Professor excluído com sucesso!'),
                  backgroundColor: AppColors.danger,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            child: Text('Excluir', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _confirmarExclusaoObra(Map<String, dynamic> book) {
    final title = (book['title'] ?? '').toString();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(
          'Excluir Obra',
          style: TextStyle(color: AppColors.titleText),
        ),
        content: Text('Tem certeza que deseja excluir "$title"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancelar',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              setState(() => _catalogBooks.remove(book));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Obra excluída com sucesso!'),
                  backgroundColor: AppColors.danger,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            child: Text('Excluir', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showMultiSelectDialog({
    required String title,
    required List<String> allItems,
    required List<String> selectedItems,
    required Function(List<String>) onConfirm,
  }) {
    List<String> tempSelected = List.from(selectedItems);
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: Text(
                title,
                style: TextStyle(
                  color: AppColors.titleText,
                  fontWeight: FontWeight.bold,
                  fontSize: AppSizes.fontSubTitle,
                ),
              ),
              backgroundColor: AppColors.surface,
              content: SizedBox(
                width: double.maxFinite,
                child: ListView(
                  shrinkWrap: true,
                  children: allItems.map((item) {
                    return CheckboxListTile(
                      title: Text(
                        item,
                        style: TextStyle(
                          color: AppColors.titleText,
                          fontSize: AppSizes.fontBody,
                        ),
                      ),
                      activeColor: AppColors.primary,
                      value: tempSelected.contains(item),
                      onChanged: (bool? checked) {
                        setStateDialog(() {
                          if (checked == true) {
                            tempSelected.add(item);
                          } else {
                            tempSelected.remove(item);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Cancelar',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    onConfirm(tempSelected);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                  ),
                  child: Text('Aplicar', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
