import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/theme/sizes.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../../../core/widgets/error_banner.dart';
import '../../data/models/teacher_model.dart';
import '../../data/services/admin_api_service.dart';
import '../controllers/teachers_controller.dart';
import '../widgets/card_professor.dart';
import '../widgets/invite_details.dart';
import 'convidar_professor_screen.dart';

/// Opções do menu de filtro. Enum próprio: PopupMenuButton não chama
/// onSelected para valores null, então `null` ("todos") não serve como valor.
enum _Filter {
  todos('Todos', null),
  ativos('Ativos', TeacherStatus.active),
  pendentes('Pendentes', TeacherStatus.invitePending),
  inativos('Inativos', TeacherStatus.inactive);

  const _Filter(this.label, this.status);

  final String label;
  final TeacherStatus? status;

  static _Filter of(TeacherStatus? s) => _Filter.values.firstWhere(
    (f) => f.status == s,
    orElse: () => _Filter.todos,
  );
}

class GestaoProfessoresScreen extends StatefulWidget {
  /// 'Todos' | 'Ativo' | 'Pendente' | 'Inativo' (rótulos usados pela home).
  final String? initialFilterStatus;

  const GestaoProfessoresScreen({super.key, this.initialFilterStatus});

  @override
  State<GestaoProfessoresScreen> createState() =>
      _GestaoProfessoresScreenState();
}

class _GestaoProfessoresScreenState extends State<GestaoProfessoresScreen> {
  late final AdminApiService _service;
  late final TeachersController _controller;
  final TextEditingController _searchController = TextEditingController();

  int? _resendingId; // professor com reenvio de convite em andamento
  int? _deletingId; // professor com exclusão em andamento

  static TeacherStatus? _statusFromLabel(String? label) => switch (label) {
    'Ativo' => TeacherStatus.active,
    'Pendente' => TeacherStatus.invitePending,
    'Inativo' => TeacherStatus.inactive,
    _ => null,
  };

  @override
  void initState() {
    super.initState();
    _service = context.read<AdminApiService>();
    _controller = TeachersController(_service);
    final initial = _statusFromLabel(widget.initialFilterStatus);
    if (initial != null) _controller.setStatus(initial);
    _controller.load();
  }

  @override
  void dispose() {
    _controller.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // --- Ações ----------------------------------------------------------------

  Future<void> _convidar() async {
    await Navigator.push<Object?>(
      context,
      MaterialPageRoute<Object?>(
        builder: (_) => const ConvidarProfessorScreen(),
      ),
    );
    // Recarrega com qualquer resultado: o botão voltar do sistema devolve null.
    if (mounted) await _controller.load();
  }

  Future<void> _reenviarConvite(TeacherModel teacher) async {
    if (_resendingId != null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(
          'Gerar novo convite',
          style: TextStyle(
            color: Color(0xFF4A2525),
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Será gerado um novo convite para ${teacher.email}. '
          'O convite anterior deixará de funcionar.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Gerar',
              style: TextStyle(
                color: Color(0xFFA1A32D),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _resendingId = teacher.id);
    try {
      final invite = await _service.resendInvite(teacher.id);
      if (!mounted) return;
      await showInviteDialog(context, invite);
    } on ApiException catch (e) {
      if (!mounted) return;
      _showError(_resendMessage(e));
      // Lista desatualizada (o professor já ativou a conta, ou foi removido): sincroniza.
      if (e.code == 'ACCOUNT_ALREADY_ACTIVE' || e.code == 'NOT_FOUND') {
        await _controller.load();
      }
    } catch (e, st) {
      debugPrint('Falha inesperada ao reenviar convite: $e\n$st');
      if (!mounted) return;
      _showError('Ocorreu um erro inesperado. Tente novamente.');
    } finally {
      if (mounted) setState(() => _resendingId = null);
    }
  }

  String _resendMessage(ApiException e) => switch (e.code) {
    'ACCOUNT_ALREADY_ACTIVE' =>
      'Este professor já ativou a conta. Atualizando a lista.',
    'NOT_FOUND' => 'Professor não encontrado. Atualizando a lista.',
    'FORBIDDEN' => 'Você não tem permissão para esta ação.',
    'RATE_LIMITED' => 'Muitas tentativas. Aguarde um instante e tente de novo.',
    _ when e.isNetworkError =>
      '${e.message} Tentar de novo é seguro, mas invalida qualquer convite gerado antes.',
    _ => e.message,
  };

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFFC62828),
        duration: const Duration(seconds: 5),
      ),
    );
  }

  Future<void> _excluirProfessor(TeacherModel teacher) async {
    if (_deletingId != null) return;
    final pending = teacher.status == TeacherStatus.invitePending;

    final ok = await confirmDestructive(
      context,
      title: 'Excluir professor',
      message: pending
          ? 'Excluir o convite pendente de ${teacher.email}? O código e o link enviados '
                'deixam de funcionar. Esta ação não pode ser desfeita.'
          : 'Excluir ${teacher.displayName} (${teacher.email})? A conta, a Minha Seleção '
                'e o acesso dele serão apagados. Esta ação não pode ser desfeita.',
    );
    if (!ok || !mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    setState(() => _deletingId = teacher.id);
    try {
      await _service.deleteTeacher(teacher.id);
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Professor excluído.'),
          backgroundColor: Color(0xFFA1A32D),
        ),
      );
    } on ApiException catch (e) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(deleteErrorMessage(e)),
          backgroundColor: const Color(0xFFC62828),
          duration: const Duration(seconds: 5),
        ),
      );
    } catch (e, st) {
      debugPrint('Falha inesperada ao excluir professor: $e\n$st');
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Ocorreu um erro inesperado. Tente novamente.'),
          backgroundColor: Color(0xFFC62828),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _deletingId = null);
        _controller.load(); // sempre recarrega
      }
    }
  }

  // --- UI -------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _controller.load,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
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
                onPressed: _convidar,
                icon: const Icon(
                  Icons.person_add_alt_1_outlined,
                  color: Colors.white,
                ),
                label: const Text(
                  'Convidar Professor',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(
                    vertical: AppSizes.spacingMd,
                  ),
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
                  // Fora de qualquer ListenableBuilder: digitar não reconstrói o campo.
                  TextField(
                    key: const ValueKey('teachers_search'),
                    controller: _searchController,
                    onChanged: _controller.setQuery,
                    // debounce de 400 ms no controller
                    decoration: InputDecoration(
                      hintText: 'Buscar por nome ou e-mail...',
                      prefixIcon: const Icon(
                        Icons.search,
                        color: AppColors.textSecondary,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  const SizedBox(height: AppSizes.spacingSm),
                  _buildFilter(),
                ],
              ),
            ),
            const SizedBox(height: AppSizes.spacingLg),
            ListenableBuilder(
              listenable: _controller,
              builder: (context, _) => _buildResults(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilter() {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        final current = _Filter.of(_controller.status);
        return Align(
          alignment: Alignment.centerLeft,
          child: PopupMenuButton<_Filter>(
            onSelected: (f) => _controller.setStatus(f.status),
            itemBuilder: (context) => [
              for (final f in _Filter.values)
                PopupMenuItem<_Filter>(
                  value: f,
                  child: Text('${f.label} (${_controller.countOf(f.status)})'),
                ),
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
                    'Filtro: ${current.label}',
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildResults() {
    final error = _controller.error;
    if (error != null) {
      return ErrorBanner(message: error.message, onRetry: _controller.load);
    }

    final items = _controller.items;
    if (_controller.isLoading && items.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(32),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    // Lista vazia sem erro é um estado vazio, não uma falha.
    if (_controller.isEmpty) {
      final filtered =
          _controller.status != null ||
          _searchController.text.trim().isNotEmpty;
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Text(
            filtered
                ? 'Nenhum professor encontrado com esses filtros.'
                : 'Nenhum professor cadastrado ainda.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: AppSizes.fontSmall,
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_controller.isLoading) const LinearProgressIndicator(minHeight: 2),
        // atualizando
        const SizedBox(height: AppSizes.spacingSm),
        Text(
          '${items.length} professor(es) encontrado(s)',
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: AppSizes.fontSmall,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppSizes.spacingMd),
        for (final teacher in items)
          CardProfessor(
            key: ValueKey(teacher.id),
            teacher: teacher,
            resending: _resendingId == teacher.id,
            onResendInvite: () => _reenviarConvite(teacher),
            deleting: _deletingId == teacher.id,
            onDelete: () => _excluirProfessor(teacher),
          ),
      ],
    );
  }
}
