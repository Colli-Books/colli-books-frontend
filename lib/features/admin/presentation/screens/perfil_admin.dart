import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/colors.dart';
import '../../../../core/theme/sizes.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';

class PerfilAdminScreen extends StatefulWidget {
  const PerfilAdminScreen({super.key});

  @override
  State<PerfilAdminScreen> createState() => _PerfilAdminScreenState();
}

class _PerfilAdminScreenState extends State<PerfilAdminScreen> {
  bool _loggingOut = false;

  @override
  Widget build(BuildContext context) {
    // Dados do usuário logado, vindos do login / GET /auth/me.
    final user = context.watch<AuthController>().user;

    final fullName = user?.fullName?.trim() ?? '';
    final name = fullName.isNotEmpty ? fullName : (user?.email ?? '');
    final showEmail = user != null && name != user.email;
    final school = user?.school?.trim() ?? '';

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            name,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: AppSizes.fontHeading,
              fontWeight: FontWeight.w800,
            ),
          ),
          if (showEmail) ...[
            const SizedBox(height: 8),
            Text(
              user.email,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: AppSizes.fontTitle,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
          if (school.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              school.toUpperCase(),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: AppSizes.fontSmall,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.0,
              ),
            ),
          ],
          const SizedBox(height: AppSizes.spacingXXl),
          OutlinedButton.icon(
            key: const ValueKey('profile_logout'),
            onPressed: _loggingOut ? null : _confirmarLogout,
            icon: _loggingOut
                ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.danger),
            )
                : const Icon(Icons.exit_to_app, color: AppColors.danger),
            label: Text(
              _loggingOut ? 'Saindo...' : 'Sair da Conta',
              style: const TextStyle(
                color: AppColors.danger,
                fontWeight: FontWeight.bold,
              ),
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.danger),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.spacingXl,
                vertical: AppSizes.spacingXMd,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusXl),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmarLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFFF9F5EC),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.logout_rounded, color: Color(0xFFE56B6F)),
            SizedBox(width: 10),
            Text(
              'Encerrar Sessão',
              style: TextStyle(color: Color(0xFF4A2525), fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),
        content: const Text(
          'Tem certeza que deseja sair da sua conta?',
          style: TextStyle(color: Color(0xFF6B6B6B), fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: Color(0xFF8C7A70), fontWeight: FontWeight.bold),
            ),
          ),
          ElevatedButton(
            key: const ValueKey('logout_confirm'),
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE56B6F),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Sair', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    await _logout();
  }

  Future<void> _logout() async {
    // Pega o controller antes do await: assim que a sessão cai, o AuthGate
    // descarta esta tela e o context deixa de ser seguro.
    final auth = context.read<AuthController>();
    setState(() => _loggingOut = true);
    try {
      // Revoga o refresh token no servidor e limpa o armazenamento local, mesmo
      // offline. O AuthGate troca para o login; nada de Navigator aqui.
      await auth.logout();
    } catch (e, st) {
      debugPrint('Falha inesperada no logout: $e\n$st');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Não foi possível encerrar a sessão. Tente novamente.'),
          backgroundColor: Color(0xFFC62828),
        ),
      );
    } finally {
      // Em caso de sucesso, a tela já foi descartada (mounted == false).
      if (mounted) setState(() => _loggingOut = false);
    }
  }
}