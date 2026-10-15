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
  int _selectedIndex = 0;
  String _searchCatalogo = '';
  final List<String> _selectedEscolaridades = [];
  final List<String> _selectedTemas = [];

  Future<void> _abrirLink(String urlStr) async {
    final Uri url = Uri.parse(urlStr);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      debugPrint('Não foi possível abrir o link: $urlStr');
    }
  }

  @override
  Widget build(BuildContext context) {
    const backgroundColor = Color(0xFFF9F5EC);
    const primaryTextColor = Color(0xFF331212);
    const secondaryTextColor = Color(0xFF8C7A70);
    const accentColor = Color(0xFFA1A32D);

    return Scaffold(
      backgroundColor: backgroundColor,
      drawer: _buildDrawer(backgroundColor, primaryTextColor, secondaryTextColor),
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: primaryTextColor),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/logo.png',
              height: 32,
              errorBuilder: (context, error, stackTrace) => const Icon(Icons.menu_book, color: accentColor, size: 28),
            ),
            const SizedBox(width: 8),
            const Text(
              'COLLI BOOKS',
              style: TextStyle(
                color: primaryTextColor,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.5,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _buildInicio(primaryTextColor, secondaryTextColor, accentColor),
          _buildCatalogo(primaryTextColor, secondaryTextColor, accentColor),
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

  Widget _buildInicio(Color primaryText, Color secondaryText, Color accentColor) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 24,
                backgroundColor: Color(0xFFE5DDD0),
                child: Icon(Icons.school, color: AppColors.secondary, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Área do Educador',
                      style: TextStyle(
                        color: secondaryText,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Olá, Professor(a)',
                      style: TextStyle(
                        color: primaryText,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFEBE8E0)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: accentColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.auto_stories, color: accentColor, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Acervo Literário Disponível',
                            style: TextStyle(color: primaryText, fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '${CatalogoData.livros.length} obras para suas atividades pedagógicas',
                            style: TextStyle(color: secondaryText, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _selectedIndex = 1;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accentColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text(
                      'Explorar Catálogo',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'Destaques Pedagógicos',
            style: TextStyle(color: primaryText, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ...CatalogoData.livros.take(3).map((Map<String, dynamic> book) {
            final image = book['image'] as String? ?? '';
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFEBE8E0)),
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: image.isNotEmpty
                        ? Image.network(
                            image,
                            width: 50,
                            height: 70,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(
                              width: 50,
                              height: 70,
                              color: const Color(0xFFF0EBE1),
                              child: const Icon(Icons.book, color: Color(0xFF8C7A70)),
                            ),
                          )
                        : Container(
                            width: 50,
                            height: 70,
                            color: const Color(0xFFF0EBE1),
                            child: const Icon(Icons.book, color: Color(0xFF8C7A70)),
                          ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          book['title'] as String,
                          style: TextStyle(color: primaryText, fontWeight: FontWeight.bold, fontSize: 15),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          book['author'] as String,
                          style: TextStyle(color: secondaryText, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildCatalogo(Color primaryText, Color secondaryText, Color accentColor) {
    final filtered = CatalogoData.livros.where((Map<String, dynamic> book) {
      final title = (book['title'] as String).toLowerCase();
      final author = (book['author'] as String).toLowerCase();
      final query = _searchCatalogo.toLowerCase();
      final matchesSearch = title.contains(query) || author.contains(query);

      final bookEsc = (book['escolaridades'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [];
      final matchesEsc = _selectedEscolaridades.isEmpty || _selectedEscolaridades.any((e) => bookEsc.contains(e));

      final bookTemas = (book['temas'] as List<dynamic>?)?.map((t) => t.toString()).toList() ?? [];
      final matchesTemas = _selectedTemas.isEmpty || _selectedTemas.any((t) => bookTemas.contains(t));

      return matchesSearch && matchesEsc && matchesTemas;
    }).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Catálogo de Obras', style: TextStyle(color: primaryText, fontSize: 24, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          Text('Consulte o acervo para planejar suas aulas e leituras.', style: TextStyle(color: secondaryText, fontSize: 14)),
          const SizedBox(height: 24),
          TextField(
            onChanged: (val) => setState(() => _searchCatalogo = val),
            decoration: InputDecoration(
              hintText: 'Buscar por título ou autor...',
              hintStyle: TextStyle(color: secondaryText, fontSize: 14),
              prefixIcon: Icon(Icons.search, color: secondaryText),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFEBE8E0))),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFEBE8E0))),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: accentColor)),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '${filtered.length} obra(s) encontrada(s)',
            style: TextStyle(color: secondaryText, fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ...filtered.map((Map<String, dynamic> book) {
            final image = book['image'] as String? ?? '';
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFEBE8E0)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: image.isNotEmpty
                        ? Image.network(
                            image,
                            width: 60,
                            height: 85,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(
                              width: 60,
                              height: 85,
                              color: const Color(0xFFF0EBE1),
                              child: const Icon(Icons.book, color: Color(0xFF8C7A70)),
                            ),
                          )
                        : Container(
                            width: 60,
                            height: 85,
                            color: const Color(0xFFF0EBE1),
                            child: const Icon(Icons.book, color: Color(0xFF8C7A70)),
                          ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          book['title'] as String,
                          style: TextStyle(color: primaryText, fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          book['author'] as String,
                          style: TextStyle(color: secondaryText, fontSize: 13),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 4,
                          runSpacing: 4,
                          children: ((book['escolaridades'] as List<dynamic>?) ?? []).map((e) {
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF3EFE4),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(e.toString(), style: const TextStyle(fontSize: 10, color: Color(0xFF4A2525), fontWeight: FontWeight.bold)),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildPerfil(Color primaryText, Color secondaryText) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircleAvatar(
            radius: 40,
            backgroundColor: Color(0xFFE5DDD0),
            child: Icon(Icons.school, color: AppColors.secondary, size: 48),
          ),
          const SizedBox(height: 16),
          Text(
            widget.professorEmail,
            style: TextStyle(color: primaryText, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            'Perfil de Educador',
            style: TextStyle(color: secondaryText, fontSize: 13, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 40),
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
