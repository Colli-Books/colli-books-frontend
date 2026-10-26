import 'package:flutter/material.dart';

import '../../../auth/presentation/screens/login_screen.dart';
import 'meus_dados_screen.dart';
import 'fale_conosco_screen.dart';

class PerfilProfessorScreen extends StatefulWidget {
  final String nome;
  final String email;
  final String escola;

  const PerfilProfessorScreen({
    super.key,
    this.nome = 'Ana Silva',
    this.email = 'email@email.com',
    this.escola = 'ESCOLA PRIMAVERA',
  });

  @override
  State<PerfilProfessorScreen> createState() => _PerfilProfessorScreenState();
}

class _PerfilProfessorScreenState extends State<PerfilProfessorScreen> {
  late String _nome;
  late String _email;
  late String _escola;

  static const Color _bgColor = Color(0xFFF9F5EC);
  static const Color _primaryTextColor = Color(0xFF4A2525);
  static const Color _secondaryTextColor = Color(0xFF7A6B63);
  static const Color _borderColor = Color(0xFFE2DDD5);

  @override
  void initState() {
    super.initState();
    _nome = widget.nome;
    _email = widget.email;
    _escola = widget.escola;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _bgColor,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // --- Cabeçalho do Professor ---
            Text(
              _nome,
              style: const TextStyle(
                color: _primaryTextColor,
                fontSize: 26,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              _email,
              style: const TextStyle(
                color: _secondaryTextColor,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              _escola.toUpperCase(),
              style: const TextStyle(
                color: Color(0xFF8D6E63),
                fontSize: 12.5,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 36),

            // --- CARD 1: MINHAS INFORMAÇÕES ---
            _buildOptionCard(
              icon: Icons.badge_outlined,
              title: 'Minhas Informações',
              subtitle: 'Atualize suas informações pessoais.',
              onTap: () async {
                final messenger = ScaffoldMessenger.of(context);
                final result = await Navigator.push<Map<String, String>>(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MeusDadosScreen(
                      nome: _nome,
                      email: _email,
                      escola: _escola,
                    ),
                  ),
                );
                if (result != null) {
                  setState(() {
                    _nome = result['nome'] ?? _nome;
                    _email = result['email'] ?? _email;
                    _escola = result['escola'] ?? _escola;
                  });
                  if (!mounted) return;
                  messenger.showSnackBar(
                    const SnackBar(
                      content: Text('Informações atualizadas com sucesso!'),
                      duration: Duration(seconds: 2),
                      backgroundColor: Color(0xFFA1A32D),
                    ),
                  );
                }
              },
            ),
            const SizedBox(height: 16),

            // --- CARD 2: FALE CONOSCO ---
            _buildOptionCard(
              icon: Icons.headset_mic_outlined,
              title: 'Fale Conosco',
              subtitle: 'Sinta-se à vontade para nos enviar uma mensagem.',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (context) => const FaleConoscoScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 48),

            // --- BOTÃO DE SAIR ---
            OutlinedButton.icon(
              onPressed: () => _confirmarLogout(context),
              icon: const Icon(Icons.logout_rounded, color: Color(0xFFD32F2F), size: 20),
              label: const Text(
                'Sair',
                style: TextStyle(
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
      ),
    );
  }

  Widget _buildOptionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _borderColor, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
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
                          color: _primaryTextColor,
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          color: _secondaryTextColor,
                          fontSize: 13,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: Color(0xFFBDB6AC),
                  size: 24,
                ),
              ],
            ),
          ),
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
