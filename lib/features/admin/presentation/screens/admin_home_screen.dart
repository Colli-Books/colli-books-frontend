import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/colors.dart';
import '../../../../core/widgets/card.dart';
import '../../../../core/widgets/icon.dart';
import '../../../../core/widgets/text.dart';
import '../../data/services/admin_api_service.dart';
import '../controllers/overview_controller.dart';
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

  // Vive só enquanto a tela existe: nada de dados de admin em memória após o logout.
  late final OverviewController _overview;

  @override
  void initState() {
    super.initState();
    _overview = OverviewController(context.read<AdminApiService>())..load();
  }

  @override
  void dispose() {
    _overview.dispose();
    super.dispose();
  }

  /// Abre uma tela de ação e, ao voltar (com qualquer resultado), recarrega
  /// os contadores: convidar professor e cadastrar obra mudam os números.
  Future<void> _abrir(Widget screen) async {
    await Navigator.push<Object?>(
      context,
      MaterialPageRoute<Object?>(builder: (_) => screen),
    );
    if (mounted) await _overview.load();
  }

  void _irParaProfessores(String filtro) {
    setState(() {
      _selectedIndex = 1;
      _filterStatus = filtro;
    });
  }

  /// '…' enquanto carrega pela primeira vez; '—' se falhou sem ter dado nenhum.
  String _fmt(int? n) => n?.toString() ?? (_overview.isLoading ? '…' : '—');

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
          errorBuilder: (_, _, _) => const Text(
            'Colli Books',
            style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF4A2525), fontSize: 18),
          ),
        ),
      ),
      body: _buildBody(),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFFF6F1E3),
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textPrimary,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
        currentIndex: _selectedIndex,
        onTap: (index) {
          final previous = _selectedIndex;
          setState(() {
            // Pela barra, "Professores" abre sem filtro (antes herdava o último
            // filtro escolhido num card).
            if (index == 1) _filterStatus = 'Todos';
            _selectedIndex = index;
          });
          // Voltando para o início, atualiza os números (outras abas podem tê-los mudado).
          if (index == 0 && previous != 0) _overview.load();
        },
        items: const [
          BottomNavigationBarItem(
            icon: Padding(padding: EdgeInsets.only(bottom: 4.0), child: Icon(Icons.home)),
            label: 'Início',
          ),
          BottomNavigationBarItem(
            icon: Padding(padding: EdgeInsets.only(bottom: 4.0), child: Icon(Icons.school_outlined)),
            label: 'Professores',
          ),
          BottomNavigationBarItem(
            icon: Padding(padding: EdgeInsets.only(bottom: 4.0), child: Icon(Icons.menu_book_outlined)),
            label: 'Catálogo',
          ),
          BottomNavigationBarItem(
            icon: Padding(padding: EdgeInsets.only(bottom: 4.0), child: Icon(Icons.person_outline)),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }

  Widget _buildBody() => switch (_selectedIndex) {
    3 => const PerfilAdminScreen(),
    2 => const CatalogoObrasAdminScreen(),
    1 => GestaoProfessoresScreen(initialFilterStatus: _filterStatus),
    _ => _buildOverview(),
  };

  Widget _buildOverview() {
    return RefreshIndicator(
      onRefresh: _overview.load,
      child: SingleChildScrollView(
        // Necessário para o pull-to-refresh funcionar mesmo com pouco conteúdo.
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
        child: ListenableBuilder(
          listenable: _overview,
          builder: (context, _) {
            final data = _overview.data;
            final error = _overview.error;

            return Column(
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
                const SizedBox(height: 24),

                if (error != null) ...[
                  _OverviewError(message: error.message, onRetry: _overview.load),
                  const SizedBox(height: 16),
                ],

                // SUMMARY CARDS
                SummaryCard(
                  key: const ValueKey('summary_books'),
                  iconContainer: const SummaryCardIcon(
                    icon: Icons.menu_book_outlined,
                    iconBgColor: AppColors.surface,
                    iconColor: AppColors.primary,
                  ),
                  titleText: const TitleText(title: 'OBRAS NO CATÁLOGO'),
                  valueText: SummaryValueText(value: _fmt(data?.booksCount)),
                  onTap: () => setState(() => _selectedIndex = 2),
                ),
                const SizedBox(height: 16),
                SummaryCard(
                  key: const ValueKey('summary_teachers'),
                  iconContainer: const SummaryCardIcon(
                    icon: Icons.people_alt_outlined,
                    iconBgColor: AppColors.surface,
                    iconColor: AppColors.activeBadgeText,
                  ),
                  // A API devolve o TOTAL de professores (teachers_count), não só os ativos.
                  titleText: const TitleText(title: 'PROFESSORES'),
                  valueText: SummaryValueText(value: _fmt(data?.teachersCount)),
                  onTap: () => _irParaProfessores('Todos'),
                ),
                const SizedBox(height: 16),
                SummaryCard(
                  key: const ValueKey('summary_invites'),
                  iconContainer: const SummaryCardIcon(
                    icon: Icons.mail_outline,
                    iconBgColor: AppColors.surface,
                    iconColor: AppColors.pendingBadgeText,
                  ),
                  titleText: const TitleText(title: 'CONVITES PENDENTES'),
                  valueText: SummaryValueText(value: _fmt(data?.pendingInvitesCount)),
                  onTap: () => _irParaProfessores('Pendente'),
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
                  onTap: () => _abrir(const ConvidarProfessorScreen()),
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
                  onTap: () => _abrir(const CadastrarObraScreen()),
                ),

                const SizedBox(height: 32),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _OverviewError extends StatelessWidget {
  const _OverviewError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFDECEA),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFF5C2C0)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Color(0xFFC62828), size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: Color(0xFF7F1D1D), fontSize: 13, height: 1.3),
            ),
          ),
          TextButton(onPressed: onRetry, child: const Text('Tentar de novo')),
        ],
      ),
    );
  }
}