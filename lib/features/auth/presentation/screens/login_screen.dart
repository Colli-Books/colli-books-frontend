import 'package:flutter/material.dart';
import '../../../../core/utils/validators.dart';
import '../../data/services/auth_api_service.dart';
import '../../../admin/presentation/screens/admin_home_screen.dart';
import '../../../institucional/presentation/screens/fale_conosco_screen.dart';
import '../../../professor/presentation/screens/professor_home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _forgotEmailController = TextEditingController();
  final TextEditingController _resetTokenController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();

  final AuthApiService _authService = AuthApiService();

  int _currentTab = 0; // 0 = Entrar, 1 = Esqueci a Senha
  bool _obscurePassword = true;
  bool _obscureNewPassword = true;
  bool _isLoading = false;
  String? _recoveryFeedback;
  String? _forgotEmailError;
  bool _showTokenFields = false;

  void _fazerLogin() async {
    final email = _emailController.text.trim();
    final senha = _passwordController.text;

    if (email.isEmpty || senha.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, preencha o e-mail e a senha.'),
          backgroundColor: Color(0xFFC62828),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    // Tentativa com backend API
    try {
      final response = await _authService.login(email: email, password: senha);
      if (!mounted) return;
      setState(() => _isLoading = false);

      final user = response['user'] as Map<String, dynamic>?;
      final role = user?['role']?.toString().toLowerCase();

      if (role == 'admin') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute<void>(builder: (context) => const AdminHomeScreen()),
        );
        return;
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute<void>(
            builder: (context) => ProfessorHomeScreen(
              professorEmail: user?['email']?.toString() ?? email,
            ),
          ),
        );
        return;
      }
    } catch (_) {
      // Fallback local caso o backend ainda não esteja em execução
      if (!mounted) return;
      setState(() => _isLoading = false);

      if (email == 'admin' && senha == '123') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute<void>(builder: (context) => const AdminHomeScreen()),
        );
      } else if ((email.toLowerCase() == 'professor' || email.contains('@')) && senha.isNotEmpty) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute<void>(
            builder: (context) => ProfessorHomeScreen(
              professorEmail: email.contains('@') ? email : 'professor@escola.edu.br',
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Credenciais incorretas! Tente admin / 123 ou professor / 123'),
            backgroundColor: Color(0xFFC62828),
          ),
        );
      }
    }
  }

  void _enviarRecuperacaoSenha() async {
    final email = _forgotEmailController.text.trim();
    final validationError = FormValidators.validateEmail(email);

    if (validationError != null) {
      setState(() {
        _forgotEmailError = validationError;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(validationError),
          backgroundColor: const Color(0xFFC62828),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _recoveryFeedback = null;
      _forgotEmailError = null;
    });

    try {
      final msg = await _authService.forgotPassword(email);
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _recoveryFeedback = msg;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _recoveryFeedback = 'Se houver uma conta com este e-mail, enviaremos um link de redefinição.';
      });
    }
  }

  void _confirmarRedefinicaoSenha() async {
    final token = _resetTokenController.text.trim();
    final newPassword = _newPasswordController.text;

    if (token.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Informe o código/token recebido por e-mail.'),
          backgroundColor: Color(0xFFC62828),
        ),
      );
      return;
    }

    final passwordError = FormValidators.validatePassword(newPassword);
    if (passwordError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(passwordError),
          backgroundColor: const Color(0xFFC62828),
        ),
      );
      return;
    }

    if (newPassword.length < 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('A nova senha deve ter no mínimo 8 caracteres.'),
          backgroundColor: Color(0xFFC62828),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _authService.resetPassword(token: token, newPassword: newPassword);
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _currentTab = 0; // Volta para login
        _showTokenFields = false;
        _recoveryFeedback = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Senha redefinida com sucesso! Você já pode entrar com sua nova senha.'),
          backgroundColor: Color(0xFFA1A32D),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: const Color(0xFFC62828),
        ),
      );
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _forgotEmailController.dispose();
    _resetTokenController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const backgroundColor = Color(0xFFF3EFE4);
    const cardTopColor = Color(0xFFF8F5EE);
    const cardBottomColor = Colors.white;
    const primaryTextColor = Color(0xFF331212);
    const labelColor = Color(0xFF1D1C13);
    const buttonColor = Color(0xFFA1A32D);
    const linkColor = Color(0xFF1D8E9E);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Container(
              width: 420,
              decoration: BoxDecoration(
                color: cardBottomColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
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
                    padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 24),
                    decoration: const BoxDecoration(
                      color: cardTopColor,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                      border: Border(
                        bottom: BorderSide(color: Color(0xFFEBE8E0), width: 1),
                      ),
                    ),
                    child: Column(
                      children: [
                        Image.asset(
                          'imagens/Logo-Colli-Booksteste.webp',
                          height: 60,
                          fit: BoxFit.contain,
                          errorBuilder: (_, _, _) => const Text(
                            'Colli Books',
                            style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF4A2525), fontSize: 24),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          _currentTab == 0
                              ? 'Bem-vindo ao Portal Colli\nBooks'
                              : 'Recuperação de Senha',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: primaryTextColor,
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // SELETOR DE ABAS: [ ENTRAR | ESQUECI A SENHA ]
                  Container(
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: Color(0xFFEBE8E0), width: 1),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                _currentTab = 0;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: _currentTab == 0 ? buttonColor : Colors.transparent,
                                    width: 3,
                                  ),
                                ),
                              ),
                              child: Text(
                                'Entrar',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: _currentTab == 0 ? primaryTextColor : Colors.grey,
                                  fontWeight: _currentTab == 0 ? FontWeight.bold : FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                _currentTab = 1;
                                if (_forgotEmailController.text.isEmpty && _emailController.text.isNotEmpty) {
                                  _forgotEmailController.text = _emailController.text;
                                }
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: _currentTab == 1 ? buttonColor : Colors.transparent,
                                    width: 3,
                                  ),
                                ),
                              ),
                              child: Text(
                                'Esqueci a Senha',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: _currentTab == 1 ? primaryTextColor : Colors.grey,
                                  fontWeight: _currentTab == 1 ? FontWeight.bold : FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // CORPO: ABA 0 (LOGIN) OU ABA 1 (ESQUECI A SENHA)
                  Padding(
                    padding: const EdgeInsets.all(28.0),
                    child: _currentTab == 0
                        // ABA 0: FORMULÁRIO DE ENTRAR
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
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
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(color: buttonColor),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),

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
                                    onPressed: () {
                                      setState(() {
                                        _currentTab = 1;
                                        if (_forgotEmailController.text.isEmpty && _emailController.text.isNotEmpty) {
                                          _forgotEmailController.text = _emailController.text;
                                        }
                                      });
                                    },
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
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(color: buttonColor),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 28),

                              SizedBox(
                                width: double.infinity,
                                height: 50,
                                child: ElevatedButton.icon(
                                  onPressed: _isLoading ? null : _fazerLogin,
                                  icon: _isLoading
                                      ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                        )
                                      : const Icon(Icons.login, color: Colors.white),
                                  label: Text(
                                    _isLoading ? 'Entrando...' : 'Entrar',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: buttonColor,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    elevation: 0,
                                  ),
                                ),
                              ),
                            ],
                          )
                        // ABA 1: FORMULÁRIO DE ESQUECI A SENHA
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Informe seu e-mail cadastrado. Enviaremos um link seguro para você redefinir sua senha de acesso.',
                                style: TextStyle(
                                  color: Color(0xFF6B7280),
                                  fontSize: 13,
                                  height: 1.4,
                                ),
                              ),
                              const SizedBox(height: 18),

                              const Text(
                                'E-mail cadastrado',
                                style: TextStyle(
                                  color: labelColor,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextField(
                                controller: _forgotEmailController,
                                keyboardType: TextInputType.emailAddress,
                                onChanged: (val) {
                                  if (_forgotEmailError != null) {
                                    setState(() => _forgotEmailError = null);
                                  }
                                },
                                decoration: InputDecoration(
                                  hintText: 'seu@email.com',
                                  errorText: _forgotEmailError,
                                  prefixIcon: const Icon(Icons.mark_email_read_outlined, color: Colors.grey),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(color: buttonColor),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),

                              SizedBox(
                                width: double.infinity,
                                height: 50,
                                child: ElevatedButton.icon(
                                  onPressed: _isLoading ? null : _enviarRecuperacaoSenha,
                                  icon: _isLoading
                                      ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                        )
                                      : const Icon(Icons.send_rounded, color: Colors.white),
                                  label: Text(
                                    _isLoading ? 'Enviando...' : 'Enviar Link de Recuperação',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: buttonColor,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    elevation: 0,
                                  ),
                                ),
                              ),

                              if (_recoveryFeedback != null) ...[
                                const SizedBox(height: 18),
                                Container(
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE8F5E9),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: const Color(0xFFA5D6A7)),
                                  ),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Icon(Icons.check_circle_outline, color: Color(0xFF2E7D32), size: 20),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          _recoveryFeedback!,
                                          style: const TextStyle(
                                            color: Color(0xFF1B5E20),
                                            fontSize: 12.5,
                                            height: 1.35,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],

                              const SizedBox(height: 20),
                              const Divider(color: Color(0xFFEBE8E0)),
                              const SizedBox(height: 12),

                              // Alternar formulário para inserir código de token
                              InkWell(
                                onTap: () {
                                  setState(() {
                                    _showTokenFields = !_showTokenFields;
                                  });
                                },
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      _showTokenFields
                                          ? 'Ocultar redefinição com código'
                                          : 'Já possui o código/token? Redefinir senha',
                                      style: const TextStyle(
                                        color: linkColor,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 12.5,
                                      ),
                                    ),
                                    Icon(
                                      _showTokenFields ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                                      size: 18,
                                      color: linkColor,
                                    ),
                                  ],
                                ),
                              ),

                              if (_showTokenFields) ...[
                                const SizedBox(height: 16),
                                const Text(
                                  'Código / Token do e-mail',
                                  style: TextStyle(
                                    color: labelColor,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                TextField(
                                  controller: _resetTokenController,
                                  decoration: InputDecoration(
                                    hintText: 'Cole o código ou token aqui',
                                    prefixIcon: const Icon(Icons.vpn_key_outlined, color: Colors.grey, size: 20),
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                const Text(
                                  'Nova Senha (mínimo 8 caracteres)',
                                  style: TextStyle(
                                    color: labelColor,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                TextField(
                                  controller: _newPasswordController,
                                  obscureText: _obscureNewPassword,
                                  decoration: InputDecoration(
                                    hintText: 'Digite a nova senha',
                                    prefixIcon: const Icon(Icons.lock_reset, color: Colors.grey, size: 20),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscureNewPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                        color: Colors.grey,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _obscureNewPassword = !_obscureNewPassword;
                                        });
                                      },
                                    ),
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                SizedBox(
                                  width: double.infinity,
                                  height: 48,
                                  child: ElevatedButton(
                                    onPressed: _isLoading ? null : _confirmarRedefinicaoSenha,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF4A2525),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    ),
                                    child: const Text(
                                      'Confirmar Nova Senha',
                                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                              ],

                              const SizedBox(height: 16),
                              Center(
                                child: TextButton.icon(
                                  onPressed: () {
                                    setState(() => _currentTab = 0);
                                  },
                                  icon: const Icon(Icons.arrow_back, size: 16, color: primaryTextColor),
                                  label: const Text(
                                    'Voltar para o Login',
                                    style: TextStyle(color: primaryTextColor, fontWeight: FontWeight.bold),
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
                        MaterialPageRoute<void>(builder: (context) => const FaleConoscoScreen()),
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
