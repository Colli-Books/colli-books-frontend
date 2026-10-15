import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/colors.dart';
import '../../../auth/presentation/screens/login_screen.dart';
import '../../../institucional/presentation/screens/politica_privacidade_screen.dart';
import '../../../institucional/presentation/screens/sobre_nos_screen.dart';
import '../../../institucional/presentation/screens/termos_uso_screen.dart';
import '../../../obras/presentation/screens/catalogo_data.dart';
import '../widgets/navbar_professor.dart';

class ProfessorHomeScreen extends StatefulWidget {
  final String professorEmail;

  const ProfessorHomeScreen({
    super.key,
    this.professorEmail = 'professor@escola.edu.br',
  });

  @override
  State<ProfessorHomeScreen> createState() => _ProfessorHomeScreenState();
}

class _ProfessorHomeScreenState extends State<ProfessorHomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _selectedIndex = 0;
  String _searchQuery = '';
  List<String> _selectedEscolaridades = [];
  List<String> _selectedTemas = [];

  // Lista de livros selecionados/favoritados pelo educador
  final List<Map<String, dynamic>> _selecao = [];

  Future<void> _abrirLink(String urlStr) async {
    final Uri url = Uri.parse(urlStr);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      debugPrint('Não foi possível abrir o link: $urlStr');
    }
  }

  void _toggleSelecao(Map<String, dynamic> book) {
    setState(() {
      final exists = _selecao.any((b) => b['title'] == book['title']);
      if (exists) {
        _selecao.removeWhere((b) => b['title'] == book['title']);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('"${book['title']}" removido da sua Seleção.'),
            duration: const Duration(seconds: 2),
            backgroundColor: const Color(0xFFC62828),
          ),
        );
      } else {
        _selecao.add(book);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('"${book['title']}" adicionado à sua Seleção!'),
            duration: const Duration(seconds: 2),
            backgroundColor: const Color(0xFFA1A32D),
          ),
        );
      }
    });
  }

  void _showMultiSelectDialog({
    required String title,
    required List<String> allItems,
    required List<String> selectedItems,
    required void Function(List<String>) onConfirm,
  }) {
    final tempSelected = List<String>.from(selectedItems);
    showDialog<void>(
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

  void _showBookDetails(Map<String, dynamic> book) {
    final isSelected = _selecao.any((b) => b['title'] == book['title']);
    const primaryTextColor = Color(0xFF331212);
    const secondaryTextColor = Color(0xFF8C7A70);
    const accentColor = Color(0xFFA1A32D);

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.85,
          decoration: const BoxDecoration(
            color: Color(0xFFF9F5EC),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 48,
                height: 5,
                decoration: BoxDecoration(
                  color: const Color(0xFFD6D6D6),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            book['image'] as String? ?? '',
                            height: 200,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(
                              height: 200,
                              width: 140,
                              color: const Color(0xFFEBE8E0),
                              child: const Icon(Icons.menu_book, color: accentColor, size: 48),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        book['title'] as String,
                        style: const TextStyle(
                          color: primaryTextColor,
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Autor(a): ${book['author']}',
                        style: const TextStyle(color: secondaryTextColor, fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 16),
                      const Divider(color: Color(0xFFEBE8E0)),
                      const SizedBox(height: 16),
                      const Text(
                        'Sinopse da Obra',
                        style: TextStyle(color: primaryTextColor, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        book['sinopse'] as String? ?? 'Sem sinopse disponível para esta obra.',
                        style: const TextStyle(color: secondaryTextColor, fontSize: 14, height: 1.5),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Classificação e Temas',
                        style: TextStyle(color: primaryTextColor, fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          ...((book['escolaridades'] as List<dynamic>?) ?? []).map((e) => Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(color: const Color(0xFFD4E6F1), borderRadius: BorderRadius.circular(8)),
                                child: Text(e.toString(), style: const TextStyle(fontSize: 12, color: Color(0xFF1F618D), fontWeight: FontWeight.bold)),
                              )),
                          ...((book['temas'] as List<dynamic>?) ?? []).map((t) => Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(color: const Color(0xFFFDEBD0), borderRadius: BorderRadius.circular(8)),
                                child: Text(t.toString(), style: const TextStyle(fontSize: 12, color: Color(0xFFD35400), fontWeight: FontWeight.bold)),
                              )),
                        ],
                      ),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            _toggleSelecao(book);
                          },
                          icon: Icon(isSelected ? Icons.bookmark_remove : Icons.bookmark_add, color: Colors.white),
                          label: Text(
                            isSelected ? 'Remover da Minha Seleção' : 'Adicionar à Minha Seleção',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isSelected ? const Color(0xFFC62828) : accentColor,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    const backgroundColor = Color(0xFFF9F5EC);
    const primaryTextColor = Color(0xFF331212);
    const secondaryTextColor = Color(0xFF8C7A70);

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: backgroundColor,
      drawer: _buildDrawer(backgroundColor, primaryTextColor, secondaryTextColor),
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: primaryTextColor, size: 28),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              'assets/logo.png',
              height: 36,
              errorBuilder: (context, error, stackTrace) => const Icon(
                Icons.spa,
                color: Color(0xFFA1A32D),
                size: 32,
              ),
            ),
            const SizedBox(width: 8),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'COLLI',
                      style: TextStyle(
                        color: primaryTextColor,
                        fontWeight: FontWeight.w900,
                        fontSize: 15,
                        letterSpacing: 1.0,
                        height: 1.0,
                      ),
                    ),
                    SizedBox(width: 3),
                    Text(
                      'BOOKS',
                      style: TextStyle(
                        color: primaryTextColor,
                        fontWeight: FontWeight.w900,
                        fontSize: 15,
                        letterSpacing: 1.0,
                        height: 1.0,
                      ),
                    ),
                  ],
                ),
                Text(
                  'e d i t o r a',
                  style: TextStyle(
                    color: Color(0xFFA1A32D),
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                    height: 1.1,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle_outlined, color: primaryTextColor, size: 30),
            onPressed: () {
              setState(() {
                _selectedIndex = 2; // Ir para a aba de Perfil
              });
            },
          ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _buildColliBooksHome(primaryTextColor, secondaryTextColor),
          _buildSelecao(primaryTextColor, secondaryTextColor),
          _buildPerfil(primaryTextColor, secondaryTextColor),
        ],
      ),
      bottomNavigationBar: NavbarProfessor(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }

  Widget _buildColliBooksHome(Color primaryText, Color secondaryText) {
    const accentColor = Color(0xFFA1A32D);

    final filtered = CatalogoData.livros.where((Map<String, dynamic> book) {
      final title = (book['title'] as String).toLowerCase();
      final author = (book['author'] as String).toLowerCase();
      final isbn = (book['isbn'] as String? ?? '').toLowerCase();
      final query = _searchQuery.toLowerCase();
      final matchesSearch = query.isEmpty || title.contains(query) || author.contains(query) || isbn.contains(query);

      final bookEsc = (book['escolaridades'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [];
      final matchesEsc = _selectedEscolaridades.isEmpty || _selectedEscolaridades.any((e) => bookEsc.contains(e));

      final bookTemas = (book['temas'] as List<dynamic>?)?.map((t) => t.toString()).toList() ?? [];
      final matchesTema = _selectedTemas.isEmpty || _selectedTemas.any((t) => bookTemas.contains(t));

      return matchesSearch && matchesEsc && matchesTema;
    }).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // BARRA DE PESQUISA (IGUAL AO ADMIN)
          TextField(
            onChanged: (val) {
              setState(() {
                _searchQuery = val;
              });
            },
            decoration: InputDecoration(
              hintText: 'Buscar por título ou autor...',
              hintStyle: TextStyle(color: secondaryText, fontSize: 14),
              prefixIcon: Icon(Icons.search, color: secondaryText),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFEBE8E0))),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFEBE8E0))),
              focusedBorder: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12)), borderSide: BorderSide(color: accentColor)),
            ),
          ),
          const SizedBox(height: 16),

          // BOTÕES DE FILTROS LADO A LADO (IGUAL AO ADMIN)
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
                    _selectedEscolaridades.isEmpty ? 'Escolaridades' : 'Escolaridades (${_selectedEscolaridades.length})',
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

          // CONTADOR DE LIVROS ENCONTRADOS
          Text(
            '${filtered.length} obra(s) encontrada(s)',
            style: TextStyle(color: secondaryText, fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // LISTA DE LIVROS (VISUALMENTE IDÊNTICO AO ADMIN, COM BOTÃO DE FAVORITO)
          if (filtered.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 48),
                child: Column(
                  children: [
                    Icon(Icons.search_off, size: 48, color: secondaryText),
                    const SizedBox(height: 12),
                    Text(
                      'Nenhuma obra encontrada para esta pesquisa.',
                      style: TextStyle(color: secondaryText, fontSize: 14),
                    ),
                  ],
                ),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                final book = filtered[index];
                return _buildBookCard(book, primaryText, secondaryText);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildBookCard(Map<String, dynamic> book, Color primaryText, Color secondaryText) {
    const accentColor = Color(0xFFA1A32D);
    final bookEscolaridades = (book['escolaridades'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [];
    final bookTemas = (book['temas'] as List<dynamic>?)?.map((t) => t.toString()).toList() ?? [];
    final isBookmarked = _selecao.any((b) => b['title'] == book['title']);

    return GestureDetector(
      onTap: () => _showBookDetails(book),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFF3EFE4),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFEBE8E0)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // CAPA DA OBRA
            Container(
              width: 100,
              height: 140,
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(8),
              ),
              clipBehavior: Clip.antiAlias,
              child: Image.network(
                book['image'] as String? ?? '',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const Center(
                  child: Icon(Icons.menu_book, size: 32, color: Colors.grey),
                ),
              ),
            ),
            // INFORMAÇÕES
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
                          child: Text(
                            book['title'] as String,
                            style: TextStyle(color: primaryText, fontWeight: FontWeight.bold, fontSize: 16),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        // BOTÃO DE ADICIONAR/REMOVER DA SELEÇÃO (NO LUGAR DE EDITAR/EXCLUIR)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFFEBE8E0)),
                          ),
                          child: InkWell(
                            onTap: () => _toggleSelecao(book),
                            child: Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: Icon(
                                isBookmarked ? Icons.bookmark : Icons.bookmark_outline,
                                size: 18,
                                color: isBookmarked ? accentColor : const Color(0xFF4A2525),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      book['author'] as String,
                      style: TextStyle(color: secondaryText, fontSize: 14, fontWeight: FontWeight.w500),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 12),
                    // BADGES DE ESCOLARIDADE (AZUIS)
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: bookEscolaridades
                          .map((e) => Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(color: const Color(0xFFD4E6F1), borderRadius: BorderRadius.circular(8)),
                                child: Text(e, style: const TextStyle(fontSize: 10, color: Color(0xFF1F618D), fontWeight: FontWeight.bold)),
                              ))
                          .toList(),
                    ),
                    const SizedBox(height: 6),
                    // BADGES DE TEMAS (LARANJAS)
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: bookTemas
                          .map((t) => Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(color: const Color(0xFFFDEBD0), borderRadius: BorderRadius.circular(8)),
                                child: Text(t, style: const TextStyle(fontSize: 10, color: Color(0xFFD35400), fontWeight: FontWeight.bold)),
                              ))
                          .toList(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelecao(Color primaryText, Color secondaryText) {
    const accentColor = Color(0xFFA1A32D);

    if (_selecao.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(
                  color: Color(0xFFEBE8E0),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.bookmark_outline, size: 56, color: accentColor),
              ),
              const SizedBox(height: 20),
              Text(
                'Sua Seleção está vazia',
                style: TextStyle(color: primaryText, fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Navegue pelo acervo de ColliBooks e salve as obras que deseja utilizar em seus projetos pedagógicos.',
                textAlign: TextAlign.center,
                style: TextStyle(color: secondaryText, fontSize: 14, height: 1.4),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => setState(() => _selectedIndex = 0),
                style: ElevatedButton.styleFrom(
                  backgroundColor: accentColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: const Text('Explorar Obras', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Minha Seleção (${_selecao.length})',
            style: TextStyle(color: primaryText, fontSize: 22, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          Text(
            'Livros selecionados para suas turmas e planos de aula.',
            style: TextStyle(color: secondaryText, fontSize: 14),
          ),
          const SizedBox(height: 20),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _selecao.length,
            itemBuilder: (context, index) {
              final book = _selecao[index];
              return _buildBookCard(book, primaryText, secondaryText);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPerfil(Color primaryText, Color secondaryText) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircleAvatar(
              radius: 46,
              backgroundColor: Color(0xFFE5DDD0),
              child: Icon(Icons.school, color: AppColors.secondary, size: 52),
            ),
            const SizedBox(height: 16),
            Text(
              widget.professorEmail,
              style: TextStyle(color: primaryText, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'Escola Estadual Machado de Assis',
              style: TextStyle(color: secondaryText, fontSize: 14, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F4F5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Educador Ativo',
                style: TextStyle(color: Color(0xFF1D8E9E), fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 36),
            OutlinedButton.icon(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute<void>(builder: (context) => const LoginScreen()),
                );
              },
              icon: const Icon(Icons.exit_to_app, color: Color(0xFFC62828)),
              label: const Text(
                'Sair da Conta',
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
      ),
    );
  }

  Widget _buildDrawer(Color backgroundColor, Color primaryText, Color secondaryText) {
    return Drawer(
      backgroundColor: backgroundColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
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
                  Navigator.push(context, MaterialPageRoute<void>(builder: (context) => const SobreNosScreen()));
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
                    Navigator.push(context, MaterialPageRoute<void>(builder: (context) => const TermosUsoScreen()));
                  },
                  style: TextButton.styleFrom(padding: EdgeInsets.zero, alignment: Alignment.centerLeft),
                  child: Text('Termos de Uso', style: TextStyle(color: primaryText, fontWeight: FontWeight.w600)),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute<void>(builder: (context) => const PoliticaPrivacidadeScreen()));
                  },
                  style: TextButton.styleFrom(padding: EdgeInsets.zero, alignment: Alignment.centerLeft),
                  child: Text('Política de Privacidade', style: TextStyle(color: primaryText, fontWeight: FontWeight.w600)),
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
}
