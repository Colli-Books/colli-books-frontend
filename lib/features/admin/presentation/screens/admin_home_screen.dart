import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'login_screen.dart';
import 'convidar_professor_screen.dart';
import 'termos_uso_screen.dart';
import 'politica_privacidade_screen.dart';
import 'cadastrar_obra_screen.dart';
import 'cadastrar_escolaridade_screen.dart';
import 'cadastrar_tema_screen.dart';
import 'catalogo_data.dart';
import 'editar_obra_screen.dart';
import 'sobre_nos_screen.dart';

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

  List<Map<String, dynamic>> professores = [
    {'nome': 'Ana Beatriz Silva', 'email': 'ana.beatriz@email.com', 'escola': 'Escola Estadual Machado de Assis', 'status': 'Ativo', 'data': 'Entrou em 12/03/2023', 'iniciais': 'AB'},
    {'nome': 'carlos@email.com', 'email': 'carlos@email.com', 'escola': '', 'status': 'Pendente', 'data': 'Convite enviado em 12/03/2023', 'iniciais': 'C'},
    {'nome': 'Marcos Nogueira', 'email': 'marcos.n@email.com', 'escola': 'Colégio Santa Maria', 'status': 'Ativo', 'data': 'Entrou em 10/02/2023', 'iniciais': 'MN'},
  ];

  List<Map<String, dynamic>> catalogBooks = [
    {'title': 'O Mistério da Floresta', 'author': 'Ana Silva', 'escolaridades': ['Ensino Fundamental I', 'Ensino Fundamental II'], 'temas': ['Aventura', 'Mistério'], 'image': 'https://via.placeholder.com/150'},
    {'title': 'O Pequeno Príncipe', 'author': 'Antoine de S.', 'escolaridades': ['Ensino Fundamental II'], 'temas': ['Ficção Científica'], 'image': 'https://via.placeholder.com/150'},
    {'title': 'Aventuras no Espaço', 'author': 'Marcos', 'escolaridades': ['Ensino Fundamental I'], 'temas': ['Ficção Científica', 'Aventura'], 'image': 'https://via.placeholder.com/150'},
    {'title': 'Histórias de Ninar', 'author': 'Clarice', 'escolaridades': ['Educação Infantil'], 'temas': ['Mistério', 'Inclusão'], 'image': 'https://via.placeholder.com/150'},
  ];

  @override
  Widget build(BuildContext context) {
    const backgroundColor = Color(0xFFF9F5EC);
    const primaryTextColor = Color(0xFF331212);
    const secondaryTextColor = Color(0xFF8C7A70);
    const accentColor = Color(0xFFA1A32D);
    const cardColor = Colors.white;

    return Scaffold(
      backgroundColor: backgroundColor,
      drawer: _buildDrawer(backgroundColor, primaryTextColor, secondaryTextColor, accentColor),
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: primaryTextColor),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Placeholder for Logo, you can replace with Image.asset later
            Icon(Icons.spa_outlined, color: accentColor, size: 28),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'COLLI',
                  style: TextStyle(
                    color: primaryTextColor,
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                    height: 1.0,
                    letterSpacing: 1.0,
                  ),
                ),
                const Text(
                  'BOOKS',
                  style: TextStyle(
                    color: primaryTextColor,
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
          ? _buildPerfil(primaryTextColor, secondaryTextColor)
          : _selectedIndex == 2
              ? _buildCatalogo(primaryTextColor, secondaryTextColor, accentColor)
              : _selectedIndex == 1
                  ? _buildProfessores(primaryTextColor, secondaryTextColor, accentColor)
                  : SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Visão Geral',
              style: TextStyle(
                color: primaryTextColor,
                fontSize: 24,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Bem-vindo ao dashboard de administração.',
              style: TextStyle(
                color: secondaryTextColor,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 32),

            // SUMMARY CARDS
            _buildSummaryCard(
              icon: Icons.menu_book_outlined,
              title: 'OBRAS NO CATÁLOGO',
              value: '${catalogBooks.length}',
              iconBgColor: const Color(0xFFF0EEDB),
              iconColor: accentColor,
              onTap: () {
                setState(() {
                  _selectedIndex = 2;
                });
              },
            ),
            const SizedBox(height: 16),
            _buildSummaryCard(
              icon: Icons.people_alt_outlined,
              title: 'PROFESSORES ATIVOS',
              value: '${professores.where((p) => p['status'] == 'Ativo').length}',
              iconBgColor: const Color(0xFFE5F3F3), // Light teal/blueish
              iconColor: const Color(0xFF4A9E9E), // Teal
              onTap: () {
                setState(() {
                  _selectedIndex = 1;
                  _filterStatus = 'Ativo';
                });
              },
            ),
            const SizedBox(height: 16),
            _buildSummaryCard(
              icon: Icons.mail_outline,
              title: 'CONVITES PENDENTES',
              value: '${professores.where((p) => p['status'] == 'Pendente').length}',
              iconBgColor: const Color(0xFFF8E7D8), // Light orange
              iconColor: const Color(0xFFC47335), // Orange
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
                color: primaryTextColor,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 24),

            // ACTION CARDS
            _buildActionCard(
              icon: Icons.person_add_alt_1_outlined,
              title: 'Convidar Professor',
              description: 'Envie um convite de acesso para novos educadores se juntarem à plataforma.',
              iconBgColor: accentColor,
              iconColor: Colors.white,
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const ConvidarProfessorScreen()));
              },
            ),
            const SizedBox(height: 16),
            _buildActionCard(
              icon: Icons.library_add_outlined,
              title: 'Cadastrar Nova Obra',
              description: 'Adicione um novo livro, artigo ou recurso educacional ao catálogo geral.',
              iconBgColor: const Color(0xFF5E3232), // Dark Brown/Reddish
              iconColor: Colors.white,
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const CadastrarObraScreen()));
              },
            ),
            
            const SizedBox(height: 32),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFFF6F1E3),
        selectedItemColor: accentColor,
        unselectedItemColor: primaryTextColor,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
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

  Widget _buildPerfil(Color primaryText, Color secondaryText) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Admin Colli',
            style: TextStyle(color: primaryText, fontSize: 24, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(
            'Administrador Master',
            style: TextStyle(color: secondaryText, fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 4),
          Text(
            'MATRIZ COLLI BOOKS',
            style: TextStyle(color: secondaryText, fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 1.0),
          ),
          const SizedBox(height: 48),
          OutlinedButton.icon(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
            icon: const Icon(Icons.exit_to_app, color: Color(0xFFC62828)),
            label: const Text(
              'Sair',
              style: TextStyle(color: Color(0xFFC62828), fontWeight: FontWeight.bold),
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFFC62828)),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfessores(Color primaryText, Color secondaryText, Color accentColor) {
    final filteredProfessores = professores.where((p) {
      final name = p['nome']!.toLowerCase();
      final school = p['escola']!.toLowerCase();
      final query = _searchQuery.toLowerCase();
      final matchesSearch = name.contains(query) || school.contains(query);
      final matchesStatus = _filterStatus == 'Todos' || p['status'] == _filterStatus;
      return matchesSearch && matchesStatus;
    }).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Gestão de Professores', style: TextStyle(color: primaryText, fontSize: 24, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          Text('Gerencie acessos e visualize os educadores cadastrados.', style: TextStyle(color: secondaryText, fontSize: 14)),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const ConvidarProfessorScreen()));
              },
              icon: const Icon(Icons.person_add_alt_1_outlined, color: Colors.white),
              label: const Text('Convidar Professor', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: accentColor,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFEBE8E0))),
            child: Column(
              children: [
                TextField(
                  onChanged: (value) => setState(() => _searchQuery = value),
                  decoration: InputDecoration(
                    hintText: 'Buscar por nome ou escola...',
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFEBE8E0))),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  ),
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerLeft,
                  child: PopupMenuButton<String>(
                    onSelected: (String result) {
                      setState(() {
                        _filterStatus = result;
                      });
                    },
                    itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                      const PopupMenuItem<String>(value: 'Todos', child: Text('Todos')),
                      const PopupMenuItem<String>(value: 'Ativo', child: Text('Ativos')),
                      const PopupMenuItem<String>(value: 'Pendente', child: Text('Pendentes')),
                    ],
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFFEBE8E0)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.filter_list, color: Color(0xFF4A2525), size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Filtro: $_filterStatus',
                            style: const TextStyle(color: Color(0xFF4A2525), fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            '${filteredProfessores.length} professor(es) encontrado(s)',
            style: TextStyle(color: secondaryText, fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ...filteredProfessores.map((prof) => _buildProfessorCard(prof, primaryText, secondaryText)).toList(),
        ],
      ),
    );
  }

  Widget _buildProfessorCard(Map<String, dynamic> prof, Color primaryText, Color secondaryText) {
    final isAtivo = prof['status'] == 'Ativo';
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFEBE8E0))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(backgroundColor: const Color(0xFFF3EFE4), radius: 24, child: Text(prof['iniciais']!, style: const TextStyle(color: Color(0xFF4A2525), fontWeight: FontWeight.bold))),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(prof['nome']!, style: TextStyle(color: primaryText, fontSize: 18, fontWeight: FontWeight.w800)),
                    if (isAtivo) ...[
                      const SizedBox(height: 2),
                      Text(prof['email']!, style: const TextStyle(color: Color(0xFF6B6B6B), fontSize: 13)),
                    ],
                    if (prof['escola']!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.school_outlined, size: 14, color: Color(0xFF6B6B6B)),
                          const SizedBox(width: 4),
                          Expanded(child: Text(prof['escola']!, style: const TextStyle(color: Color(0xFF6B6B6B), fontSize: 12))),
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
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(color: isAtivo ? const Color(0xFFE5F3F3) : const Color(0xFFF8E7D8), borderRadius: BorderRadius.circular(16)),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.circle, size: 8, color: isAtivo ? const Color(0xFF4A9E9E) : const Color(0xFFC47335)),
                        const SizedBox(width: 4),
                        Text(prof['status']!, style: TextStyle(color: isAtivo ? const Color(0xFF4A9E9E) : const Color(0xFFC47335), fontSize: 12, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  if (isAtivo) ...[
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Excluir Professor', style: TextStyle(color: Color(0xFF4A2525))),
                            content: Text('Tem certeza que deseja excluir o professor "${prof['nome']}"?'),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar', style: TextStyle(color: Colors.grey))),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  setState(() {
                                    professores.remove(prof);
                                  });
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Professor excluído com sucesso!'), backgroundColor: Colors.red));
                                },
                                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE56B6F)),
                                child: const Text('Excluir', style: TextStyle(color: Colors.white)),
                              ),
                            ],
                          ),
                        );
                      },
                      child: const Padding(
                        padding: EdgeInsets.all(4.0),
                        child: Icon(Icons.delete_outline, size: 20, color: Color(0xFFE56B6F)),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: Color(0xFFEBE8E0), height: 1),
          const SizedBox(height: 16),
          Text(prof['data']!, style: TextStyle(color: primaryText, fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildCatalogo(Color primaryText, Color secondaryText, Color accentColor) {
    final filteredCatalogo = catalogBooks.where((b) {
      final title = (b['title'] as String).toLowerCase();
      final author = (b['author'] as String).toLowerCase();
      final query = _searchCatalogo.toLowerCase();
      final matchesSearch = title.contains(query) || author.contains(query);
      
      final bookEscolaridades = b['escolaridades'] as List<String>;
      final bookTemas = b['temas'] as List<String>;

      final matchesEscolaridade = _selectedEscolaridades.isEmpty || _selectedEscolaridades.any((e) => bookEscolaridades.contains(e));
      final matchesTema = _selectedTemas.isEmpty || _selectedTemas.any((t) => bookTemas.contains(t));
      
      return matchesSearch && matchesEscolaridade && matchesTema;
    }).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Catálogo de Obras', style: TextStyle(color: primaryText, fontSize: 24, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          Text('Gerencie o acervo literário da plataforma.', style: TextStyle(color: secondaryText, fontSize: 14)),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () async {
                final newBook = await Navigator.push(context, MaterialPageRoute(builder: (context) => const CadastrarObraScreen()));
                if (newBook != null) {
                  setState(() {
                    catalogBooks.add(newBook as Map<String, dynamic>);
                  });
                }
              },
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text('Adicionar Nova Obra', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: accentColor,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const CadastrarEscolaridadeScreen()));
              },
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text('Adicionar Escolaridade', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: accentColor,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const CadastrarTemaScreen()));
              },
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text('Adicionar Tema', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: accentColor,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              ),
            ),
          ),
          const SizedBox(height: 24),
          TextField(
            decoration: InputDecoration(
              hintText: 'Buscar por título ou autor...',
              prefixIcon: const Icon(Icons.search, color: Colors.grey),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFEBE8E0))),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFEBE8E0))),
              contentPadding: const EdgeInsets.symmetric(vertical: 16),
            ),
            onChanged: (val) => setState(() => _searchCatalogo = val),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    side: const BorderSide(color: Color(0xFFEBE8E0)),
                    backgroundColor: Colors.white,
                  ),
                  icon: const Icon(Icons.filter_list, size: 16, color: Color(0xFF4A2525)),
                  label: Text(
                    _selectedEscolaridades.isEmpty ? 'Escolaridades' : 'Escolaridade (${_selectedEscolaridades.length})',
                    style: const TextStyle(color: Color(0xFF4A2525), fontSize: 12, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                  onPressed: () {
                    _showMultiSelectDialog(
                      title: 'Filtrar por Escolaridade',
                      allItems: CatalogoData.escolaridades,
                      selectedItems: _selectedEscolaridades,
                      onConfirm: (results) {
                        setState(() {
                          _selectedEscolaridades = results;
                        });
                      },
                    );
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    side: const BorderSide(color: Color(0xFFEBE8E0)),
                    backgroundColor: Colors.white,
                  ),
                  icon: const Icon(Icons.filter_list, size: 16, color: Color(0xFF4A2525)),
                  label: Text(
                    _selectedTemas.isEmpty ? 'Temas' : 'Temas (${_selectedTemas.length})',
                    style: const TextStyle(color: Color(0xFF4A2525), fontSize: 12, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                  onPressed: () {
                    _showMultiSelectDialog(
                      title: 'Filtrar por Tema',
                      allItems: CatalogoData.temas,
                      selectedItems: _selectedTemas,
                      onConfirm: (results) {
                        setState(() {
                          _selectedTemas = results;
                        });
                      },
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            '${filteredCatalogo.length} obra(s) encontrada(s)',
            style: TextStyle(color: secondaryText, fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: filteredCatalogo.length,
            itemBuilder: (context, index) {
              final book = filteredCatalogo[index];
              final bookEscolaridades = book['escolaridades'] as List<String>;
              final bookTemas = book['temas'] as List<String>;
              
              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3EFE4),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFEBE8E0)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 100,
                      height: 140,
                      margin: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Center(child: Icon(Icons.menu_book, size: 32, color: Colors.grey)),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(book['title'] as String, style: TextStyle(color: primaryText, fontWeight: FontWeight.bold, fontSize: 16), maxLines: 2, overflow: TextOverflow.ellipsis),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFFEBE8E0))),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      InkWell(
                                        onTap: () async {
                                          final updatedBook = await Navigator.push(context, MaterialPageRoute(builder: (context) => EditarObraScreen(bookData: book)));
                                          if (updatedBook != null) {
                                            setState(() {
                                              final index = catalogBooks.indexOf(book);
                                              if (index != -1) {
                                                catalogBooks[index] = updatedBook as Map<String, dynamic>;
                                              }
                                            });
                                          }
                                        }, 
                                        child: const Padding(padding: EdgeInsets.all(4.0), child: Icon(Icons.edit, size: 16, color: Color(0xFF4A2525)))
                                      ),
                                      const SizedBox(width: 4),
                                      InkWell(
                                        onTap: () {
                                          showDialog(
                                            context: context,
                                            builder: (context) => AlertDialog(
                                              title: const Text('Excluir Obra', style: TextStyle(color: Color(0xFF4A2525))),
                                              content: Text('Tem certeza que deseja excluir "${book['title']}"?'),
                                              actions: [
                                                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar', style: TextStyle(color: Colors.grey))),
                                                ElevatedButton(
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                    setState(() {
                                                      catalogBooks.remove(book);
                                                    });
                                                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Obra excluída com sucesso!'), backgroundColor: Colors.red));
                                                  },
                                                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE56B6F)),
                                                  child: const Text('Excluir', style: TextStyle(color: Colors.white)),
                                                ),
                                              ],
                                            ),
                                          );
                                        }, 
                                        child: const Padding(padding: EdgeInsets.all(4.0), child: Icon(Icons.delete_outline, size: 16, color: Color(0xFFE56B6F)))
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(book['author'] as String, style: TextStyle(color: secondaryText, fontSize: 14, fontWeight: FontWeight.w500), maxLines: 1, overflow: TextOverflow.ellipsis),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 6,
                              runSpacing: 6,
                              children: bookEscolaridades.map((e) => Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(color: const Color(0xFFD4E6F1), borderRadius: BorderRadius.circular(8)),
                                child: Text(e, style: const TextStyle(fontSize: 10, color: Color(0xFF1F618D), fontWeight: FontWeight.bold)),
                              )).toList(),
                            ),
                            const SizedBox(height: 6),
                            Wrap(
                              spacing: 6,
                              runSpacing: 6,
                              children: bookTemas.map((t) => Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(color: const Color(0xFFFDEBD0), borderRadius: BorderRadius.circular(8)),
                                child: Text(t, style: const TextStyle(fontSize: 10, color: Color(0xFFD35400), fontWeight: FontWeight.bold)),
                              )).toList(),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

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
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
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
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 16),
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF4D4D4D),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFF4A2525), // Dark reddish brown
              fontSize: 40,
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

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String description,
    required Color iconBgColor,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
            child: Column(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: iconBgColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: iconColor, size: 32),
                ),
                const SizedBox(height: 24),
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF4A2525),
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  description,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFF6B6B6B),
                    fontSize: 14,
                    height: 1.4,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _abrirLink(String urlStr) async {
    final Uri url = Uri.parse(urlStr);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      debugPrint('Não foi possível abrir o link: $urlStr');
    }
  }

  Widget _buildDrawer(Color bgColor, Color primaryText, Color secondaryText, Color accentColor) {
    return Drawer(
      backgroundColor: bgColor,
      child: Column(
        children: [
          const SizedBox(height: 60),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [

                _buildDrawerItem(Icons.library_books_outlined, 'Editora', primaryText, isLink: true, onTap: () => _abrirLink('https://www.collibooks.com/editora/')),
                _buildDrawerItem(Icons.flag_outlined, 'PNLD', primaryText, isLink: true, onTap: () => _abrirLink('https://www.collibooks.com/pnld-2/')),
                _buildDrawerItem(Icons.edit_note_outlined, 'Blog', primaryText, isLink: true, onTap: () => _abrirLink('https://www.collibooks.com/category/blog/')),
                _buildDrawerItem(Icons.star_outline, 'Anima Kids', primaryText, isLink: true, onTap: () => _abrirLink('https://www.collibooks.com/anima-kids/')),
                _buildDrawerItem(Icons.info_outline, 'Sobre Nós', primaryText, onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const SobreNosScreen()));
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
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const TermosUsoScreen()));
                  },
                  style: TextButton.styleFrom(padding: EdgeInsets.zero, alignment: Alignment.centerLeft),
                  child: Text('Termos de Uso', style: TextStyle(color: primaryText, fontWeight: FontWeight.w600)),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const PoliticaPrivacidadeScreen()));
                  },
                  style: TextButton.styleFrom(padding: EdgeInsets.zero, alignment: Alignment.centerLeft),
                  child: Text('Política de Privacidade', style: TextStyle(color: primaryText, fontWeight: FontWeight.w600)),
                ),
                const SizedBox(height: 16),
                Text('SIGA-NOS', style: TextStyle(color: secondaryText, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1.0)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildSocialIcon(Icons.facebook, accentColor, () => _abrirLink('https://www.facebook.com/collibooks/')),
                    const SizedBox(width: 12),
                    _buildSocialIcon(Icons.camera_alt_outlined, accentColor, () => _abrirLink('https://www.instagram.com/collibooks/')),
                    const SizedBox(width: 12),
                    _buildSocialIcon(Icons.play_circle_outline, accentColor, () => _abrirLink('https://www.youtube.com/channel/UCFZuip1s5lKOJ_RuZwmpG9g')),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, Color textColor, {bool isLink = false, VoidCallback? onTap}) {
    return ListTile(
      leading: Icon(icon, color: textColor),
      title: Text(
        title,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.w600,
          decoration: isLink ? TextDecoration.underline : null,
        ),
      ),
      onTap: onTap,
    );
  }

  Widget _buildSocialIcon(IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Icon(icon, color: color, size: 24),
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
              title: Text(title, style: const TextStyle(color: Color(0xFF4A2525), fontWeight: FontWeight.bold, fontSize: 18)),
              backgroundColor: const Color(0xFFF9F5EC),
              content: SizedBox(
                width: double.maxFinite,
                child: ListView(
                  shrinkWrap: true,
                  children: allItems.map((item) {
                    return CheckboxListTile(
                      title: Text(item, style: const TextStyle(color: Color(0xFF4A2525))),
                      activeColor: const Color(0xFFA1A32D),
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
                  child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  onPressed: () {
                    onConfirm(tempSelected);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFA1A32D)),
                  child: const Text('Aplicar', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
