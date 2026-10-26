import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/widgets/fullscreen_image_viewer.dart';
import '../../../auth/presentation/screens/login_screen.dart';
import '../../../institucional/presentation/screens/politica_privacidade_screen.dart';
import '../../../institucional/presentation/screens/sobre_nos_screen.dart';
import '../../../institucional/presentation/screens/termos_uso_screen.dart';
import '../../../admin/data/catalogo_data.dart';
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
  final Set<String> _expandedThemes = {};

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

  Widget _buildBookImage(
    String? imagePath, {
    Uint8List? coverBytes,
    double? height,
    double? width,
    BoxFit fit = BoxFit.cover,
  }) {
    if (isPdfCover(imagePath, coverBytes)) {
      return buildPdfCoverThumbnail(
        width: width ?? 80,
        height: height ?? 110,
        compact: (width != null && width < 120),
      );
    }
    if (coverBytes != null && coverBytes.isNotEmpty) {
      return Image.memory(
        coverBytes,
        height: height,
        width: width,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => Container(
          height: height,
          width: width,
          color: const Color(0xFFEBE8E0),
          child: const Icon(Icons.menu_book, color: Color(0xFFA1A32D), size: 40),
        ),
      );
    }
    if (imagePath == null || imagePath.isEmpty) {
      return Container(
        height: height,
        width: width,
        color: const Color(0xFFEBE8E0),
        child: const Icon(Icons.menu_book, color: Color(0xFFA1A32D), size: 40),
      );
    }
    if (imagePath.startsWith('imagens/') || imagePath.startsWith('assets/')) {
      return Image.asset(
        imagePath,
        height: height,
        width: width,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => Container(
          height: height,
          width: width,
          color: const Color(0xFFEBE8E0),
          child: const Icon(Icons.menu_book, color: Color(0xFFA1A32D), size: 40),
        ),
      );
    }
    return Image.network(
      imagePath,
      height: height,
      width: width,
      fit: fit,
      errorBuilder: (context, error, stackTrace) => Container(
        height: height,
        width: width,
        color: const Color(0xFFEBE8E0),
        child: const Icon(Icons.menu_book, color: Color(0xFFA1A32D), size: 40),
      ),
    );
  }

  void _showBookDetails(Map<String, dynamic> book) {
    const primaryTextColor = Color(0xFF331212);
    const secondaryTextColor = Color(0xFF8C7A70);
    const accentColor = Color(0xFFA1A32D);

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final isSelected = _selecao.any((b) => b['title'] == book['title']);
            final bookEscolaridades =
                (book['escolaridades'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [];
            final bookTemas =
                (book['temas'] as List<dynamic>?)?.map((t) => t.toString()).toList() ?? [];
            final interdisciplinaridade = book['interdisciplinaridade'] as Map<String, dynamic>?;
            final disciplinas = (book['disciplinas'] as List<dynamic>?)?.map((d) => d.toString()).toList() ??
                ['Língua Portuguesa', 'Artes'];
            final storeUrl = book['storeUrl'] as String? ?? 'https://www.collibooksloja.com/';
            final paginas = book['paginas']?.toString() ?? '38';
            final edicao = book['edicao']?.toString() ?? '1ª';

            return Container(
              height: MediaQuery.of(context).size.height * 0.90,
              decoration: const BoxDecoration(
                color: Color(0xFFF9F5EC),
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                children: [
                  // Drag Handle
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
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 1. CAPA DA OBRA COM BORDA E SOMBRA SUAVE (Igual print 1)
                          Center(
                            child: GestureDetector(
                              onTap: () => abrirVisualizadorImagem(
                                context,
                                imagePath: book['image'] as String?,
                                coverBytes: book['coverBytes'] as Uint8List?,
                                title: book['title'] as String?,
                              ),
                              child: Stack(
                                alignment: Alignment.bottomCenter,
                                children: [
                                  Container(
                                    constraints: const BoxConstraints(maxHeight: 320, maxWidth: 280),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(alpha: 0.08),
                                          blurRadius: 16,
                                          offset: const Offset(0, 6),
                                        ),
                                      ],
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(16),
                                      child: _buildBookImage(
                                        book['image'] as String?,
                                        coverBytes: book['coverBytes'] as Uint8List?,
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 10,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withValues(alpha: 0.65),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.fullscreen_rounded, size: 14, color: Colors.white),
                                          SizedBox(width: 4),
                                          Text(
                                            'Toque para tela cheia',
                                            style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // 2. BOTÃO 1: COMPRAR NA LOJA (Olive green filled)
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () => _abrirLink(storeUrl),
                              icon: const Icon(Icons.shopping_cart_outlined, color: Colors.white, size: 20),
                              label: const Text(
                                'Comprar na Loja',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: accentColor,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),

                          // 3. BOTÃO 2: SALVAR / REMOVER DA SELEÇÃO (Outlined olive green)
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: () {
                                _toggleSelecao(book);
                                setModalState(() {});
                              },
                              icon: Icon(
                                isSelected ? Icons.bookmark_remove : Icons.bookmark_border,
                                color: isSelected ? const Color(0xFFC62828) : accentColor,
                                size: 20,
                              ),
                              label: Text(
                                isSelected ? 'Remover da Seleção' : 'Salvar na Seleção',
                                style: TextStyle(
                                  color: isSelected ? const Color(0xFFC62828) : accentColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(
                                  color: isSelected ? const Color(0xFFC62828) : accentColor,
                                  width: 1.5,
                                ),
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                            ),
                          ),
                          if (book['bookUrl'] != null && (book['bookUrl'] as String).isNotEmpty) ...[
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: () => _abrirLink(book['bookUrl'] as String),
                                icon: const Icon(Icons.picture_as_pdf_outlined, color: Colors.white, size: 20),
                                label: const Text(
                                  'Acessar Livro no Google Drive (PDF)',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF4A2525),
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                              ),
                            ),
                          ],
                          const SizedBox(height: 24),

                          // 4. ESCOLARIDADES E TEMAS (Idênticos aos cards da Seleção e Catálogo)
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              ...bookEscolaridades.map(
                                (e) => Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFD4E6F1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    e,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF1F618D),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              ...bookTemas.map(
                                (t) => Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFDEBD0),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    t,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFFD35400),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),

                          // 5. TÍTULO E AUTOR(A)
                          Text(
                            book['title'] as String,
                            style: const TextStyle(
                              color: accentColor,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Por ${book['author']}',
                            style: const TextStyle(
                              color: primaryTextColor,
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          if (book['ilustracoes'] != null) ...[
                            const SizedBox(height: 2),
                            Text(
                              'Ilustrações: ${book['ilustracoes']}',
                              style: const TextStyle(
                                color: secondaryTextColor,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                          const SizedBox(height: 16),
                          const Divider(color: Color(0xFFEBE8E0)),
                          const SizedBox(height: 16),

                          // 6. SINOPSE
                          const Text(
                            'Sinopse',
                            style: TextStyle(
                              color: primaryTextColor,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            book['sinopse'] as String? ?? 'Sem sinopse disponível para esta obra.',
                            style: const TextStyle(
                              color: Color(0xFF4A3B32),
                              fontSize: 15,
                              height: 1.55,
                            ),
                          ),
                          const SizedBox(height: 24),

                          // 7. CARD: MATERIAL PEDAGÓGICO (Com barra verde lateral - Print 2)
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: const Color(0xFFEBE8E0)),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.03),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: IntrinsicHeight(
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    Container(width: 6, color: accentColor),
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.all(16.0),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Row(
                                              children: [
                                                Icon(Icons.school_outlined, color: accentColor, size: 24),
                                                SizedBox(width: 10),
                                                Text(
                                                  'Material Pedagógico',
                                                  style: TextStyle(
                                                    color: primaryTextColor,
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 8),
                                            const Text(
                                              'Recursos exclusivos desenvolvidos para apoiar o planejamento do professor e enriquecer o trabalho em sala de aula.',
                                              style: TextStyle(
                                                color: secondaryTextColor,
                                                fontSize: 13,
                                                height: 1.4,
                                              ),
                                            ),
                                            const SizedBox(height: 16),
                                            SizedBox(
                                              width: double.infinity,
                                              child: ElevatedButton.icon(
                                                onPressed: () {
                                                  final url = (book['lpUrl'] as String?)?.isNotEmpty == true
                                                      ? book['lpUrl'] as String
                                                      : 'https://www.collibooks.com/editora/';
                                                  _abrirLink(url);
                                                },
                                                icon: const Icon(Icons.school, color: Colors.white, size: 20),
                                                label: const Text(
                                                  'Acessar Material Pedagógico da Obra',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: accentColor,
                                                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                                                  elevation: 0,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(12),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // 8. CARDS DE ESPECIFICAÇÕES: PÁGINAS, EDIÇÃO (Sem ISBN)
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: const Color(0xFFEBE8E0)),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'PÁGINAS',
                                        style: TextStyle(
                                          color: secondaryTextColor,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 0.8,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        paginas,
                                        style: const TextStyle(
                                          color: primaryTextColor,
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: const Color(0xFFEBE8E0)),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'EDIÇÃO',
                                        style: TextStyle(
                                          color: secondaryTextColor,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 0.8,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        edicao,
                                        style: const TextStyle(
                                          color: primaryTextColor,
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // 9. POSSIBILIDADES INTERDISCIPLINARES
                          const Text(
                            'POSSIBILIDADES INTERDISCIPLINARES',
                            style: TextStyle(
                              color: Color(0xFF6B5B53),
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.8,
                            ),
                          ),
                          const SizedBox(height: 12),
                          if (interdisciplinaridade != null && interdisciplinaridade.isNotEmpty) ...[
                            ...interdisciplinaridade.entries.map((entry) {
                              final disciplina = entry.key;
                              final topicos = (entry.value as List<dynamic>).map((e) => e.toString()).toList();
                              return Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: const Color(0xFFEBE8E0)),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          width: 8,
                                          height: 8,
                                          decoration: const BoxDecoration(
                                            color: accentColor,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          disciplina,
                                          style: const TextStyle(
                                            color: primaryTextColor,
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    ...topicos.map((topico) => Padding(
                                          padding: const EdgeInsets.only(left: 16, bottom: 4),
                                          child: Row(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              const Text(
                                                '• ',
                                                style: TextStyle(
                                                  color: accentColor,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14,
                                                ),
                                              ),
                                              Expanded(
                                                child: Text(
                                                  topico,
                                                  style: const TextStyle(
                                                    color: Color(0xFF554440),
                                                    fontSize: 13,
                                                    height: 1.35,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        )),
                                  ],
                                ),
                              );
                            }),
                          ] else ...[
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: disciplinas.map((d) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: const Color(0xFFD8D2C6)),
                                  ),
                                  child: Text(
                                    d,
                                    style: const TextStyle(
                                      color: primaryTextColor,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                          const SizedBox(height: 36),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
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
      final bookTemas = (book['temas'] as List<dynamic>?)?.map((t) => t.toString()).toList() ?? [];
      final matchesSearch = query.isEmpty ||
          title.contains(query) ||
          author.contains(query) ||
          isbn.contains(query) ||
          bookTemas.any((t) => t.toLowerCase().contains(query));

      final bookEsc = (book['escolaridades'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [];
      final matchesEsc = _selectedEscolaridades.isEmpty || _selectedEscolaridades.any((e) => bookEsc.contains(e));

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
              hintText: 'Buscar por título, autor ou tema...',
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
            GestureDetector(
              onTap: () => abrirVisualizadorImagem(
                context,
                imagePath: book['image'] as String?,
                coverBytes: book['coverBytes'] as Uint8List?,
                title: book['title'] as String?,
              ),
              child: Tooltip(
                message: 'Toque para ver a imagem em tela cheia',
                child: Stack(
                  children: [
                    Container(
                      width: 100,
                      height: 140,
                      margin: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: _buildBookImage(
                        book['image'] as String?,
                        coverBytes: book['coverBytes'] as Uint8List?,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      bottom: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.65),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Icon(Icons.fullscreen_rounded, size: 14, color: Colors.white),
                      ),
                    ),
                  ],
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
                    // BADGES DE TEMAS (LARANJAS COM SUPORTE A EXPANSÃO E TEMA PESQUISADO)
                    Builder(
                      builder: (context) {
                        final bookTitle = book['title'] as String;
                        final isThemesExpanded = _expandedThemes.contains(bookTitle);
                        final query = _searchQuery.trim().toLowerCase();

                        // Identifica se há tema pesquisado ou filtrado que não esteja entre os 4 primeiros
                        final matchedExtraTemas = bookTemas.skip(4).where((t) {
                          final matchQuery = query.isNotEmpty && t.toLowerCase().contains(query);
                          final matchFilter = _selectedTemas.any((st) => st.toLowerCase() == t.toLowerCase());
                          return matchQuery || matchFilter;
                        }).toList();

                        final List<String> displayedTemas;
                        if (isThemesExpanded) {
                          displayedTemas = bookTemas;
                        } else {
                          displayedTemas = [
                            ...bookTemas.take(4),
                            ...matchedExtraTemas,
                          ];
                        }
                        final remainingCount = bookTemas.length - displayedTemas.length;

                        return Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: [
                            ...displayedTemas.map(
                              (t) => Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(color: const Color(0xFFFDEBD0), borderRadius: BorderRadius.circular(8)),
                                child: Text(t, style: const TextStyle(fontSize: 10, color: Color(0xFFD35400), fontWeight: FontWeight.bold)),
                              ),
                            ),
                            if (remainingCount > 0 && !isThemesExpanded)
                              InkWell(
                                onTap: () {
                                  setState(() {
                                    _expandedThemes.add(bookTitle);
                                  });
                                },
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFCE4D6),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: const Color(0xFFE59866), width: 0.8),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        '+$remainingCount',
                                        style: const TextStyle(fontSize: 10, color: Color(0xFFBA4A00), fontWeight: FontWeight.w800),
                                      ),
                                      const SizedBox(width: 2),
                                      const Icon(Icons.add, size: 12, color: Color(0xFFBA4A00)),
                                    ],
                                  ),
                                ),
                              ),
                            if (isThemesExpanded && bookTemas.length > 4)
                              InkWell(
                                onTap: () {
                                  setState(() {
                                    _expandedThemes.remove(bookTitle);
                                  });
                                },
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFCE4D6),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: const Color(0xFFE59866), width: 0.8),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'Ver menos',
                                        style: TextStyle(fontSize: 10, color: Color(0xFFBA4A00), fontWeight: FontWeight.bold),
                                      ),
                                      SizedBox(width: 2),
                                      Icon(Icons.remove, size: 12, color: Color(0xFFBA4A00)),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        );
                      },
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
              onPressed: () => _confirmarLogout(context),
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
                const SizedBox(height: 16),
                const Text(
                  'SIGA-NOS',
                  style: TextStyle(
                    color: Color(0xFF8D6E63),
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 8),
                _buildSocialItem(
                  icon: FontAwesomeIcons.instagram,
                  name: 'Instagram',
                  brandColor: const Color(0xFFE1306C),
                  onTap: () => _abrirLink('https://www.instagram.com/collibooks/'),
                ),
                _buildSocialItem(
                  icon: FontAwesomeIcons.youtube,
                  name: 'YouTube',
                  brandColor: const Color(0xFFCD201F),
                  onTap: () => _abrirLink('https://www.youtube.com/channel/UCFZuip1s5lKOJ_RuZwmpG9g'),
                ),
                _buildSocialItem(
                  icon: FontAwesomeIcons.facebook,
                  name: 'Facebook',
                  brandColor: const Color(0xFF1877F2),
                  onTap: () => _abrirLink('https://www.facebook.com/collibooks/'),
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

  Widget _buildSocialItem({
    required FaIconData icon,
    required String name,
    required Color brandColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 9.0, horizontal: 4.0),
        child: Row(
          children: [
            SizedBox(
              width: 24,
              child: Center(
                child: FaIcon(icon, color: brandColor, size: 20),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                name,
                style: const TextStyle(
                  color: Color(0xFF4A2525),
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ),
            const Icon(
              Icons.open_in_new_rounded,
              size: 15,
              color: Color(0xFF8D6E63),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmarLogout(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFFF9F5EC),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.logout_rounded, color: Color(0xFFE56B6F)),
            SizedBox(width: 10),
            Text('Encerrar Sessão', style: TextStyle(color: Color(0xFF4A2525), fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
        content: const Text(
          'Tem certeza que deseja sair da sua conta?',
          style: TextStyle(color: Color(0xFF6B6B6B), fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar', style: TextStyle(color: Color(0xFF8C7A70), fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute<void>(builder: (context) => const LoginScreen()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE56B6F),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Sair', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
