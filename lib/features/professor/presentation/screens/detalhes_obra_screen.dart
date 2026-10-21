import 'package:flutter/material.dart';

import '../../../../core/theme/colors.dart';
import '../../../../core/theme/sizes.dart';

class DetalhesObraScreen extends StatefulWidget {
  final Map<String, dynamic> obra;
  final Function(Map<String, dynamic>)? onSalvarSelecao;
  final bool isSalvo;

  const DetalhesObraScreen({
    super.key,
    required this.obra,
    this.onSalvarSelecao,
    this.isSalvo = false,
  });

  @override
  State<DetalhesObraScreen> createState() => _DetalhesObraScreenState();
}

class _DetalhesObraScreenState extends State<DetalhesObraScreen> {
  late bool _salvo;

  @override
  void initState() {
    super.initState();
    _salvo = widget.isSalvo;
  }

  @override
  Widget build(BuildContext context) {
    final titulo =
        widget.obra['titulo']?.toString() ?? 'O Mistério da Floresta';
    final autores =
        widget.obra['autores']?.toString() ??
        widget.obra['autor']?.toString() ??
        'Ana Colli & Pedro Costa';
    final sinopse =
        widget.obra['sinopse']?.toString() ??
        'Uma aventura mágica que leva os pequenos leitores ao coração de uma floresta encantada...';
    final paginas = widget.obra['paginas']?.toString() ?? '48';
    final edicao = widget.obra['edicao']?.toString() ?? '1ª';
    final isbn = widget.obra['isbn']?.toString() ?? '978-85-12345-67-8';

    // Tratamento seguro para tags
    final rawTags = widget.obra['tags'];
    final List<String> tags = rawTags is List
        ? rawTags.map((e) => e.toString()).toList()
        : ['INFANTIL', 'AVENTURA'];

    // Tratamento seguro para disciplinas
    final rawDisciplinas = widget.obra['disciplinas'];
    final List<String> disciplinas = rawDisciplinas is List
        ? rawDisciplinas.map((e) => e.toString()).toList()
        : ['Língua Portuguesa', 'Ciências', 'Educação Ambiental'];

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.titleText),
        title: const Text(
          'Detalhe da Obra',
          style: TextStyle(
            color: AppColors.titleText,
            fontWeight: FontWeight.bold,
            fontSize: AppSizes.fontTitle,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- TOPO: CAPA COM FUNDO ESTÉTICO ---
            Stack(
              alignment: Alignment.center,
              children: [
                // Fundo borrado/gradiente simulado
                Container(
                  height: 320,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.brown.shade100.withOpacity(0.4),
                  ),
                  child:
                      (widget.obra['capa'] != null &&
                          widget.obra['capa'].toString().isNotEmpty)
                      ? Image.network(
                          widget.obra['capa'].toString(),
                          fit: BoxFit.cover,
                        )
                      : Container(color: const Color(0xFFE8E0D5)),
                ),
                // Camada de desfoque/escuro suave para destaque
                Container(
                  height: 320,
                  width: double.infinity,
                  color: Colors.black.withOpacity(0.15),
                ),
                // Capa do livro em destaque
                Container(
                  height: 270,
                  width: 190,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child:
                        (widget.obra['capa'] != null &&
                            widget.obra['capa'].toString().isNotEmpty)
                        ? Image.network(
                            widget.obra['capa'].toString(),
                            fit: BoxFit.cover,
                          )
                        : Container(
                            color: Colors.grey.shade300,
                            child: const Center(
                              child: Icon(
                                Icons.menu_book,
                                size: 64,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(AppSizes.spacingLg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- BOTÕES DE AÇÃO PRINCIPAIS ---
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppSizes.radiusSm,
                          ),
                        ),
                      ),
                      icon: const Icon(Icons.shopping_cart_outlined),
                      label: const Text(
                        'Comprar na Loja',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      onPressed: () {},
                    ),
                  ),
                  const SizedBox(height: AppSizes.spacingSm),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: const BorderSide(color: AppColors.primary),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppSizes.radiusSm,
                          ),
                        ),
                      ),
                      icon: Icon(
                        _salvo ? Icons.bookmark : Icons.bookmark_border,
                      ),
                      label: Text(
                        _salvo ? 'Salvo na Seleção' : 'Salvar na Seleção',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      onPressed: () {
                        setState(() {
                          _salvo = !_salvo;
                        });
                        if (widget.onSalvarSelecao != null) {
                          widget.onSalvarSelecao!(widget.obra);
                        }
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              _salvo
                                  ? 'Obra adicionada à sua seleção!'
                                  : 'Obra removida da seleção.',
                            ),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: AppSizes.spacingLg),

                  // --- TAGS / GÊNERO ---
                  Wrap(
                    spacing: 8,
                    children: tags.map((tag) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0E5D8),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          tag,
                          style: const TextStyle(
                            color: AppColors.titleText,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: AppSizes.spacingMd),

                  // --- TÍTULO E AUTOR ---
                  Text(
                    titulo,
                    style: const TextStyle(
                      color: AppColors.titleText,
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Por $autores',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppSizes.spacingXl),

                  // --- SINOPSE ---
                  const Text(
                    'Sinopse',
                    style: TextStyle(
                      color: AppColors.titleText,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    sinopse,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 15,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: AppSizes.spacingXl),

                  // --- MATERIAL PEDAGÓGICO ---
                  Container(
                    padding: const EdgeInsets.all(AppSizes.spacingMd),
                    decoration: BoxDecoration(
                      color: AppColors.cardBackground,
                      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(
                              Icons.school_outlined,
                              color: AppColors.primary,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Material Pedagógico',
                              style: TextStyle(
                                color: AppColors.titleText,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Recursos exclusivos desenvolvidos para apoiar o professor na sala de aula.',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: AppSizes.spacingMd),
                        _buildDownloadItem('Guia de Leitura', 'PDF • 2.4 MB'),
                        const SizedBox(height: 8),
                        _buildDownloadItem(
                          'Atividades Complementares',
                          'PDF • 1.8 MB',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSizes.spacingLg),

                  // --- ESPECIFICAÇÕES ---
                  Row(
                    children: [
                      Expanded(child: _buildInfoBox('PÁGINAS', paginas)),
                      const SizedBox(width: AppSizes.spacingMd),
                      Expanded(child: _buildInfoBox('EDIÇÃO', edicao)),
                    ],
                  ),
                  const SizedBox(height: AppSizes.spacingMd),
                  _buildInfoBox('ISBN', isbn, isFullWidth: true),
                  const SizedBox(height: AppSizes.spacingXl),

                  // --- DISCIPLINAS ATENDIDAS ---
                  const Text(
                    'DISCIPLINAS ATENDIDAS',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: AppSizes.spacingSm),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: disciplinas.map((disc) {
                      return Chip(
                        backgroundColor: AppColors.cardBackground,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: const BorderSide(color: AppColors.border),
                        ),
                        label: Text(
                          disc,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDownloadItem(String titulo, String subtitulo) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F2EB),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment
            .spaceBetween, // Corrigido de .between para .spaceBetween
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                titulo,
                style: const TextStyle(
                  color: AppColors.titleText,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitulo,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const Icon(Icons.download, color: AppColors.primary),
        ],
      ),
    );
  }

  Widget _buildInfoBox(String label, String valor, {bool isFullWidth = false}) {
    return Container(
      width: isFullWidth ? double.infinity : null,
      padding: const EdgeInsets.all(AppSizes.spacingMd),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            valor,
            style: const TextStyle(
              color: AppColors.titleText,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
