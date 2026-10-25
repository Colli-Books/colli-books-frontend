import 'package:flutter/material.dart';

import '../../../../core/theme/colors.dart';
import '../../../../core/theme/sizes.dart';
import '../../../../core/widgets/campo_busca.dart';
import '../widgets/filtro_chips.dart';
import '../widgets/navbar_professor.dart';
import '../widgets/obra_card.dart';
import '../widgets/sidebar_professor.dart';
import 'detalhes_obra_screen.dart';
import 'perfil_professor_screen.dart';
import 'selecao_professor_screen.dart';

class HomeProfessorScreen extends StatefulWidget {
  const HomeProfessorScreen({super.key});

  @override
  State<HomeProfessorScreen> createState() => _HomeProfessorScreenState();
}

class _HomeProfessorScreenState extends State<HomeProfessorScreen> {
  // Filtros de Escolaridade
  static const _escolaridades = [
    'Todos',
    'Educação Infantil',
    'Ensino Fundamental I',
    'Ensino Fundamental II',
    'Ensino Médio',
  ];

  // Filtros Temáticos / Tipos de Obra
  static const _tematicas = [
    'Bullying',
    'Imaginação',
    'Higiene',
    'Alimentação',
    'Matemática',
    'Ciências',
  ];

  int _selectedIndex = 0;
  String _selectedEscolaridade = 'Todos';
  String? _selectedTematica;
  String _searchQuery = '';

  // TODO(backend): Estes dados virão do banco de dados cadastrados pelo Administrador.
  final List<Map<String, dynamic>> _obras = [
    {
      'id': '1',
      'titulo': 'Aventuras na Matemática Vol. 1',
      'autores': 'Maria Silva, João Santos',
      'categoria': 'MATEMÁTICA • FUND. I',
      'tagEscolar': 'Ensino Fundamental I',
      'tagTematica': 'Matemática',
      'capa': null, // Aqui entrará a URL da imagem salva pelo admin
      'sinopse': 'Uma aventura mágica pelos números e formas geométricas.',
    },
    {
      'id': '2',
      'titulo': 'Caminhos da Leitura',
      'autores': 'Ana Oliveira',
      'categoria': 'PORTUGUÊS • FUND. I',
      'tagEscolar': 'Ensino Fundamental I',
      'tagTematica': 'Imaginação',
      'capa': null,
      'sinopse':
          'Descubra o prazer de viajar através das palavras e histórias.',
    },
    {
      'id': '3',
      'titulo': 'Descobrindo o Mundo',
      'autores': 'Carlos Mendes',
      'categoria': 'CIÊNCIAS • FUND. I',
      'tagEscolar': 'Ensino Fundamental I',
      'tagTematica': 'Ciências',
      'capa': null,
      'sinopse': 'Experimentos divertidos e descobertas sobre a natureza.',
    },
  ];

  // Obras salvas pelo professor na aba "Seleção".
  final List<Map<String, dynamic>> _selecionados = [];

  List<Map<String, dynamic>> get _obrasFiltradas {
    final busca = _searchQuery.toLowerCase();
    return _obras.where((obra) {
      final titulo = (obra['titulo'] ?? '').toString().toLowerCase();
      final autores = _autoresDe(obra).toLowerCase();
      final combinaBusca = titulo.contains(busca) || autores.contains(busca);

      final combinaEscolaridade =
          _selectedEscolaridade == 'Todos' ||
          obra['tagEscolar'] == _selectedEscolaridade;

      final combinaTematica =
          _selectedTematica == null || obra['tagTematica'] == _selectedTematica;

      return combinaBusca && combinaEscolaridade && combinaTematica;
    }).toList();
  }

  String _autoresDe(Map<String, dynamic> obra) =>
      (obra['autores'] ?? obra['autor'] ?? '').toString();

  void _abrirDetalhes(Map<String, dynamic> obra) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DetalhesObraScreen(
          obra: obra,
          isSalvo: _selecionados.any(
            (item) => item['titulo'] == obra['titulo'],
          ),
          onSalvarSelecao: (obraSelecionada) {
            setState(() {
              if (_selecionados.any(
                (item) => item['titulo'] == obraSelecionada['titulo'],
              )) {
                _selecionados.removeWhere(
                  (item) => item['titulo'] == obraSelecionada['titulo'],
                );
              } else {
                _selecionados.add(obraSelecionada);
              }
            });
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      drawer: SidebarProfessor(
        onSelectTab: (index) => setState(() => _selectedIndex = index),
      ),
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.titleText),
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.spa_outlined, color: AppColors.primary, size: 28),
            SizedBox(width: AppSizes.spacingSm),
            Text(
              'COLLI BOOKS',
              style: TextStyle(
                color: AppColors.titleText,
                fontWeight: FontWeight.w900,
                fontSize: AppSizes.fontTitle,
                letterSpacing: 1.0,
              ),
            ),
          ],
        ),
      ),
      body: _buildAbaAtual(),
      bottomNavigationBar: NavbarProfessor(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
      ),
    );
  }

  Widget _buildAbaAtual() {
    switch (_selectedIndex) {
      case 1:
        return SelecaoProfessorScreen(
          selecionados: _selecionados,
          onRemove: (obra) => setState(() => _selecionados.remove(obra)),
        );
      case 2:
        return const PerfilProfessorScreen();
      default:
        return _buildCatalogo();
    }
  }

  Widget _buildCatalogo() {
    final obras = _obrasFiltradas;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(AppSizes.spacingLg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CampoBusca(
                hintText: 'Pesquisar por título, autor, ISBN...',
                onChanged: (valor) => setState(() => _searchQuery = valor),
              ),
              const SizedBox(height: AppSizes.spacingMd),
              // Primeira linha de filtros: Escolaridade
              FiltroChips(
                opcoes: _escolaridades,
                selecionado: _selectedEscolaridade,
                onSelecionado: (cat) =>
                    setState(() => _selectedEscolaridade = cat),
              ),
              const SizedBox(height: AppSizes.spacingSm),
              // Segunda linha de filtros: Temáticas (Bullyng, Imaginação, etc)
              FiltroChips(
                opcoes: _tematicas,
                selecionado: _selectedTematica,
                onSelecionado: (tematica) => setState(() {
                  // Permite desmarcar se clicar no mesmo
                  if (_selectedTematica == tematica) {
                    _selectedTematica = null;
                  } else {
                    _selectedTematica = tematica;
                  }
                }),
              ),
            ],
          ),
        ),
        Expanded(
          child: obras.isEmpty
              ? const Center(
                  child: Text(
                    'Nenhuma obra encontrada.',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                )
              : GridView.builder(
                  padding: const EdgeInsets.fromLTRB(
                    AppSizes.spacingLg,
                    0,
                    AppSizes.spacingLg,
                    AppSizes.spacingLg,
                  ),
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 220,
                    crossAxisSpacing: AppSizes.spacingMd,
                    mainAxisSpacing: AppSizes.spacingMd,
                    childAspectRatio: 0.62,
                  ),
                  itemCount: obras.length,
                  itemBuilder: (context, index) {
                    final obra = obras[index];
                    return ObraCard(
                      titulo: obra['titulo']?.toString() ?? 'Sem título',
                      autores: _autoresDe(obra),
                      categoria:
                          obra['categoria']?.toString() ?? 'Sem categoria',
                      capa: obra['capa']?.toString(),
                      onTap: () => _abrirDetalhes(obra),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
