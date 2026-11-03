import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../institucional/presentation/screens/fale_conosco_screen.dart';
import 'meus_dados_screen.dart';

class PerfilProfessorScreen extends StatefulWidget {
  const PerfilProfessorScreen({super.key});

  @override
  State<PerfilProfessorScreen> createState() => _PerfilProfessorScreenState();
}

class _PerfilProfessorScreenState extends State<PerfilProfessorScreen> {
  bool _loggingOut = false;

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthController>().user;
    if (user == null) return const SizedBox.shrink(); // sessão acabando de cair

    final fullName = user.fullName?.trim() ?? '';
    final name = fullName.isNotEmpty ? fullName : user.email;
    final showEmail = name != user.email;
    final school = user.school?.trim() ?? '';

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            name,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF331212),
              fontSize: 26,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
          if (showEmail) ...[
            const SizedBox(height: 6),
            Text(
              user.email,
              style: const TextStyle(
                color: Color(0xFF8C7A70),
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
          if (school.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              school.toUpperCase(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF8D6E63),
                fontSize: 12.5,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.0,
              ),
            ),
          ],
          const SizedBox(height: 36),
          _optionCard(
            icon: Icons.badge_outlined,
            title: 'Minhas Informações',
            subtitle: 'Atualize suas informações pessoais.',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute<void>(builder: (_) => const MeusDadosScreen()),
            ),
          ),
          const SizedBox(height: 16),
          _optionCard(
            icon: Icons.headset_mic_outlined,
            title: 'Fale Conosco',
            subtitle: 'Sinta-se à vontade para nos enviar uma mensagem.',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute<void>(builder: (_) => const FaleConoscoScreen()),
            ),
          ),
          const SizedBox(height: 48),
          OutlinedButton.icon(
            key: const ValueKey('profile_logout'),
            onPressed: _loggingOut ? null : _confirmarLogout,
            icon: _loggingOut
                ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFD32F2F)),
            )
                : const Icon(Icons.logout_rounded, color: Color(0xFFD32F2F), size: 20),
            label: Text(
              _loggingOut ? 'Saindo...' : 'Sair',
              style: const TextStyle(
                color: Color(0xFFD32F2F),
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFFD32F2F), width: 1.5),
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            ),
          ),
          const SizedBox(height: 24),
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

    // Antes do await: assim que a sessão cai, o AuthGate descarta esta tela.
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
      if (mounted) setState(() => _loggingOut = false);
    }
  }

  Widget _optionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2DDD5), width: 1.2),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 3)),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF7F3EB),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: const Color(0xFFA1A32D), size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Color(0xFF4A2525),
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        subtitle,
                        style: const TextStyle(color: Color(0xFF7A6B63), fontSize: 13, height: 1.3),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.chevron_right_rounded, color: Color(0xFFBDB6AC), size: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}