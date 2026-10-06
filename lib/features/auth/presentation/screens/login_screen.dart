import 'package:flutter/material.dart';
import 'fale_conosco_screen.dart';
import 'admin_home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;

  void _fazerLogin() {
    final email = _emailController.text.trim();
    final senha = _passwordController.text;

    if (email == 'admin' && senha == '123') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const AdminHomeScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Credenciais incorretas! Tente admin / 123'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Cores extraídas do design
    const backgroundColor = Color(0xFFF3EFE4); // Fundo bege claro
    const cardTopColor = Color(0xFFF8F5EE); // Bege um pouco mais claro pro topo do card
    const cardBottomColor = Colors.white;
    const primaryTextColor = Color(0xFF331212); // Marrom escuro do título
    const labelColor = Color(0xFF1D1C13); // Cor das labels E-mail e Senha
    const buttonColor = Color(0xFFA1A32D); // Verde/Amarelo do botão
    const linkColor = Color(0xFF1D8E9E); // Azul do "Esqueci minha senha"

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Container(
              width: 400, // Largura máxima do card
              decoration: BoxDecoration(
                color: cardBottomColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // PARTE SUPERIOR DO CARD (Logo e Título)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
                    decoration: const BoxDecoration(
                      color: cardTopColor,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                      border: Border(
                        bottom: BorderSide(color: Color(0xFFEBE8E0), width: 1),
                      ),
                    ),
                    child: Column(
                      children: [
                        // Logo da Editora
                        Image.asset(
                          'imagens/Logo-Colli-Booksteste.webp',
                          height: 64,
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(height: 32),
                        const Text(
                          'Bem-vindo ao Portal Colli\nBooks',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: primaryTextColor,
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // PARTE INFERIOR DO CARD (Formulário)
                  Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Campo de E-mail
                        const Text(
                          'E-mail',
                          style: TextStyle(
                            color: labelColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            hintText: 'seu@email.com',
                            prefixIcon: const Icon(Icons.email_outlined, color: Colors.grey),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: buttonColor),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Campo de Senha
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Senha',
                              style: TextStyle(
                                color: labelColor,
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            TextButton(
                              onPressed: () {},
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: const Text(
                                'Esqueci minha senha',
                                style: TextStyle(
                                  color: linkColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            hintText: '••••••••',
                            prefixIcon: const Icon(Icons.lock_outline, color: Colors.grey),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                color: Colors.grey,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: buttonColor),
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Botão Entrar
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton.icon(
                            onPressed: _fazerLogin,
                            icon: const Icon(Icons.login, color: Colors.white),
                            label: const Text(
                              'Entrar',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: buttonColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              elevation: 0,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // RODAPÉ DO CARD
                  const Divider(height: 1, color: Color(0xFFE0E0E0)),
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const FaleConoscoScreen()),
                      );
                    },
                    borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 32),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Icon(Icons.info_outline, size: 18, color: Color(0xFF6B7280)),
                          const SizedBox(width: 8),
                          const Expanded(
                            child: Text(
                              'Acesso exclusivo mediante convite\ninstitucional. Clique para Fale Conosco',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Color(0xFF6B7280),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
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
      ),
    );
  }
}
