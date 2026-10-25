import 'dart:typed_data';
import 'package:flutter/material.dart';

import '../../../../core/theme/colors.dart';
import '../../../../core/theme/sizes.dart';
import '../../../../core/widgets/dialog.dart';
import '../../data/catalogo_data.dart';
import 'cadastrar_escolaridade_screen.dart';
import 'cadastrar_obra_screen.dart';
import 'cadastrar_tema_screen.dart';
import 'editar_obra_screen.dart';

class CatalogoObrasAdminScreen extends StatefulWidget {
  const CatalogoObrasAdminScreen({super.key});

  @override
  State<CatalogoObrasAdminScreen> createState() => _CatalogoObrasAdminScreenState();
}

class _CatalogoObrasAdminScreenState extends State<CatalogoObrasAdminScreen> {
  String _searchCatalog = '';
  List<Map<String, dynamic>> catalogBooks = List<Map<String, dynamic>>.from(CatalogoData.livros);
  List<String> _selectedEscolaridades = [];
  List<String> _selectedTemas = [];
  final Set<String> _expandedThemes = {};

  Widget _buildBookCover(String? imagePath, {Uint8List? coverBytes}) {
    if (coverBytes != null && coverBytes.isNotEmpty) {
      return Image.memory(
        coverBytes,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const Center(child: Icon(Icons.menu_book, size: 32, color: Colors.grey)),
      );
    }
    if (imagePath == null || imagePath.isEmpty) {
      return const Center(child: Icon(Icons.menu_book, size: 32, color: Colors.grey));
    }
    if (imagePath.startsWith('imagens/') || imagePath.startsWith('assets/')) {
      return Image.asset(
        imagePath,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const Center(child: Icon(Icons.menu_book, size: 32, color: Colors.grey)),
      );
    }
    return Image.network(
      imagePath,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => const Center(child: Icon(Icons.menu_book, size: 32, color: Colors.grey)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredCatalogo = catalogBooks.where((b) {
      final title = (b['title'] as String).toLowerCase();
      final author = (b['author'] as String).toLowerCase();
      final isbn = (b['isbn'] as String? ?? '').toLowerCase();
      final query = _searchCatalog.trim().toLowerCase();
      final bookEscolaridades = b['escolaridades'] as List<String>;
      final bookTemas = b['temas'] as List<String>;

      final matchesSearch = query.isEmpty ||
          title.contains(query) ||
          author.contains(query) ||
          isbn.contains(query) ||
          bookTemas.any((t) => t.toLowerCase().contains(query));

      final matchesEscolaridade = _selectedEscolaridades.isEmpty || _selectedEscolaridades.any((e) => bookEscolaridades.contains(e));
      final matchesTema = _selectedTemas.isEmpty || _selectedTemas.any((t) => bookTemas.contains(t));

      return matchesSearch && matchesEscolaridade && matchesTema;
    }).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.spacingLg, vertical: AppSizes.spacingLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Catálogo de Obras', style: TextStyle(color: AppColors.textPrimary, fontSize: AppSizes.spacingLg, fontWeight: FontWeight.w800)),
          const SizedBox(height: AppSizes.spacingSm),
          Text('Gerencie o acervo literário da plataforma.', style: TextStyle(color: AppColors.textSecondary, fontSize: AppSizes.fontBody)),
          const SizedBox(height: AppSizes.spacingLg),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () async {
                final newBook = await Navigator.push<dynamic>(context, MaterialPageRoute<dynamic>(builder: (context) => const CadastrarObraScreen()));
                if (newBook != null) {
                  setState(() {
                    catalogBooks.add(newBook as Map<String, dynamic>);
                  });
                }
              },
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text('Adicionar Nova Obra', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.spacingLg)),
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push<void>(context, MaterialPageRoute<void>(builder: (context) => const CadastrarEscolaridadeScreen()));
              },
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text('Adicionar Escolaridade', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.spacingLg)),
              ),
            ),
          ),
          const SizedBox(height: AppSizes.spacingMd),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push<void>(context, MaterialPageRoute<void>(builder: (context) => const CadastrarTemaScreen()));
              },
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text('Adicionar Tema', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.spacingLg)),
              ),
            ),
          ),
          const SizedBox(height: AppSizes.spacingLg),
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
            onChanged: (val) => setState(() => _searchCatalog = val),
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
                    showMultiSelectDialog(
                      context: context,
                      title: 'Filtrar por Escolaridade',
                      allItems: CatalogoData.escolaridades, // TODO: Substituir com dados reais
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
                    showMultiSelectDialog(
                      context: context,
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
          const SizedBox(height: AppSizes.spacingLg),
          Text(
            '${filteredCatalogo.length} obra(s) encontrada(s)',
            style: TextStyle(color: AppColors.textSecondary, fontSize: AppSizes.fontBody, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: AppSizes.spacingMd),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: filteredCatalogo.length,
            itemBuilder: (context, index) {
              final book = filteredCatalogo[index];
              final bookEscolaridades = book['escolaridades'] as List<String>;
              final bookTemas = book['temas'] as List<String>;

              return Container(
                margin: const EdgeInsets.only(bottom: AppSizes.spacingMd),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3EFE4),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 100,
                      height: 140,
                      margin: const EdgeInsets.all(8),
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: _buildBookCover(
                        book['image']?.toString(),
                        coverBytes: book['coverBytes'] as Uint8List?,
                      ),
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
                                  child: Text(book['title'] as String, style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 16), maxLines: 2, overflow: TextOverflow.ellipsis),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFFEBE8E0))),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      InkWell(
                                          onTap: () async {
                                            final updatedBook = await Navigator.push<dynamic>(context, MaterialPageRoute<dynamic>(builder: (context) => EditarObraScreen(bookData: book)));
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
                                      DeleteIconButton(itemTitle: 'Excluir Obra', onConfirm: () => setState(() => catalogBooks.remove(book)))
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(book['author'] as String, style: TextStyle(color: AppColors.textSecondary, fontSize: 14, fontWeight: FontWeight.w500), maxLines: 1, overflow: TextOverflow.ellipsis),
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
                            Builder(
                              builder: (context) {
                                final bookTitle = book['title'] as String;
                                final isThemesExpanded = _expandedThemes.contains(bookTitle);
                                final query = _searchCatalog.trim().toLowerCase();

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
                                    ...displayedTemas.map((t) => Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(color: const Color(0xFFFDEBD0), borderRadius: BorderRadius.circular(8)),
                                      child: Text(t, style: const TextStyle(fontSize: 10, color: Color(0xFFD35400), fontWeight: FontWeight.bold)),
                                    )),
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
              );
            },
          ),
        ],
      ),
    );
  }
}


