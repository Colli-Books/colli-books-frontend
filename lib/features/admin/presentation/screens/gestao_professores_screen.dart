import 'package:flutter/material.dart';

import '../../../../core/theme/colors.dart';
import '../../../../core/theme/sizes.dart';
import '../widgets/card_professor.dart';
import 'convidar_professor_screen.dart';

class GestaoProfessoresScreen extends StatefulWidget {
  final String? initialFilterStatus;

  const GestaoProfessoresScreen({super.key, this.initialFilterStatus});

  @override
  State<GestaoProfessoresScreen> createState() => _GestaoProfessoresScreenState();
}

class _GestaoProfessoresScreenState extends State<GestaoProfessoresScreen> {
  late String _filterStatus;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _filterStatus = widget.initialFilterStatus ?? 'Todos';
  }

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

  @override
  Widget build(BuildContext context) {
    final filteredProfessores = professores.where((p) {
      final name = (p['nome'] as String? ?? '').toLowerCase();
      final school = (p['escola'] as String? ?? '').toLowerCase();
      final query = _searchQuery.toLowerCase();
      final matchesSearch = name.contains(query) || school.contains(query);
      final matchesStatus = _filterStatus == 'Todos' || p['status'] == _filterStatus;
      return matchesSearch && matchesStatus;
    }).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSizes.spacingLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Gestão de Professores',
            style: TextStyle(
              color: AppColors.titleText,
              fontSize: AppSizes.fontHeading,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: AppSizes.spacingSm),
          const Text(
            'Gerencie acessos e visualize os educadores cadastrados.',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: AppSizes.fontSmall,
            ),
          ),
          const SizedBox(height: AppSizes.spacingLg),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (context) => const ConvidarProfessorScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.person_add_alt_1_outlined, color: Colors.white),
              label: const Text(
                'Convidar Professor',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: AppSizes.spacingMd),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSizes.spacingLg),
          Container(
            padding: const EdgeInsets.all(AppSizes.spacingMd),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                TextField(
                  onChanged: (value) => setState(() => _searchQuery = value),
                  decoration: InputDecoration(
                    hintText: 'Buscar por nome ou escola...',
                    prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                const SizedBox(height: AppSizes.spacingSm),
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
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSizes.spacingMd,
                        vertical: AppSizes.spacingSm,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.border),
                        borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.filter_list,
                            color: AppColors.textPrimary,
                            size: 20,
                          ),
                          const SizedBox(width: AppSizes.spacingSm),
                          Text(
                            'Filtro: $_filterStatus',
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSizes.spacingLg),
          Text(
            '${filteredProfessores.length} professor(es) encontrado(s)',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: AppSizes.fontSmall,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSizes.spacingMd),
          ...filteredProfessores.map(
            (prof) => CardProfessor(
              prof: prof,
              onDelete: () {
                setState(() {
                  professores.remove(prof);
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}
