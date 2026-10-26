import 'package:flutter/material.dart';
import '../../../../core/network/api_exception.dart';
import '../../data/services/professor_api_service.dart';

class MeusDadosScreen extends StatefulWidget {
  final String nome;
  final String email;
  final String escola;

  const MeusDadosScreen({
    super.key,
    required this.nome,
    required this.email,
    required this.escola,
  });

  @override
  State<MeusDadosScreen> createState() => _MeusDadosScreenState();
}

class _MeusDadosScreenState extends State<MeusDadosScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nomeController;
  late TextEditingController _emailController;
  late TextEditingController _escolaController;

  final ProfessorApiService _professorApiService = ProfessorApiService();
  bool _isLoading = false;

  static const Color _bgColor = Color(0xFFF9F5EC);
  static const Color _primaryTextColor = Color(0xFF4A2525);
  static const Color _secondaryTextColor = Color(0xFF7A6B63);
  static const Color _accentColor = Color(0xFFA1A32D);
  static const Color _cancelColor = Color(0xFFDE5D5D);
  static const Color _borderColor = Color(0xFFE2DDD5);

  @override
  void initState() {
    super.initState();
    _nomeController = TextEditingController(text: widget.nome);
    _emailController = TextEditingController(text: widget.email);
    _escolaController = TextEditingController(text: widget.escola);
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _escolaController.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final novoNome = _nomeController.text.trim();
    final novoEmail = _emailController.text.trim();
    final novaEscola = _escolaController.text.trim();

    final bool emailAlterado = novoEmail.toLowerCase() != widget.email.trim().toLowerCase();

    // Se o e-mail foi alterado, exige confirmação explícita
    if (emailAlterado) {
      final bool? confirmar = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: const [
              Icon(Icons.mark_email_unread_outlined, color: _primaryTextColor),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Alterar E-mail?',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: _primaryTextColor,
                  ),
                ),
              ),
            ],
          ),
          content: Text(
            'Você está solicitando a alteração do seu e-mail de acesso:\n\n'
            '• De: ${widget.email}\n'
            '• Para: $novoEmail\n\n'
            'A alteração de e-mail requer sincronização segura via API. '
            'Caso necessário, um link de confirmação será enviado para o novo endereço.',
            style: const TextStyle(fontSize: 14, color: _secondaryTextColor, height: 1.4),
          ),
          actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancelar', style: TextStyle(color: _secondaryTextColor)),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: _accentColor,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Confirmar Alteração', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );

      if (confirmar != true) return;
      if (!mounted) return;
    }

    final messenger = ScaffoldMessenger.of(context);
    final nav = Navigator.of(context);
    setState(() => _isLoading = true);

    try {
      final result = await _professorApiService.updateProfile(
        nome: novoNome,
        email: novoEmail,
        escola: novaEscola,
      );

      if (!mounted) return;

      messenger.showSnackBar(
        SnackBar(
          content: Text(
            emailAlterado
                ? 'E-mail e dados atualizados! Verifique se uma confirmação foi enviada para $novoEmail.'
                : result.message,
          ),
          backgroundColor: result.isOffline ? const Color(0xFFE5A93C) : _accentColor,
          duration: const Duration(seconds: 4),
        ),
      );

      nav.pop(result.data);
    } on ApiException catch (e) {
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Falha na Atualização', style: TextStyle(color: _cancelColor, fontWeight: FontWeight.bold)),
          content: Text(e.message, style: const TextStyle(color: _secondaryTextColor)),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx),
              style: ElevatedButton.styleFrom(backgroundColor: _cancelColor),
              child: const Text('OK', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(
          content: Text('Erro ao atualizar: $e'),
          backgroundColor: _cancelColor,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      appBar: AppBar(
        backgroundColor: _bgColor,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: _primaryTextColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Image.asset(
          'imagens/Logo-Colli-Booksteste.webp',
          height: 38,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) => const Text(
            'Colli Books',
            style: TextStyle(fontWeight: FontWeight.bold, color: _primaryTextColor, fontSize: 18),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Meus Dados',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: _primaryTextColor,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Atualize suas informações pessoais e credenciais de acesso.',
                  style: TextStyle(
                    fontSize: 14,
                    color: _secondaryTextColor,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 24),

                // Card principal: Informações Pessoais
                Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _borderColor, width: 1.2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Informações Pessoais',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: _primaryTextColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Divider(color: Color(0xFFF0EBE1), thickness: 1),
                      const SizedBox(height: 16),

                      // Campo: Nome Completo
                      _buildFieldLabel('Nome Completo'),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _nomeController,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: _primaryTextColor,
                        ),
                        decoration: _buildInputDecoration(
                          hintText: 'Seu nome completo',
                          prefixIcon: Icons.person_outline_rounded,
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Por favor, informe seu nome completo.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 18),

                      // Campo: E-mail
                      _buildFieldLabel('E-mail'),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFBF4E6),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFEAD9BA)),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Icon(Icons.info_outline_rounded, size: 18, color: Color(0xFF9E651E)),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'A alteração do e-mail atualiza sua credencial de login na API e requer validação de segurança.',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF7A4E17),
                                  height: 1.35,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      TextFormField(
                        controller: _emailController,
                        enabled: !_isLoading,
                        keyboardType: TextInputType.emailAddress,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: _primaryTextColor,
                        ),
                        decoration: _buildInputDecoration(
                          hintText: 'seu.email@escola.com.br',
                          prefixIcon: Icons.email_outlined,
                          fillColor: const Color(0xFFF4F0E8),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Por favor, informe seu e-mail.';
                          }
                          if (!value.contains('@') || !value.contains('.')) {
                            return 'Informe um e-mail válido.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 18),

                      // Campo: Escola / Instituição
                      _buildFieldLabel('Escola/Instituição'),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _escolaController,
                        enabled: !_isLoading,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: _primaryTextColor,
                        ),
                        decoration: _buildInputDecoration(
                          hintText: 'Nome da sua escola ou instituição',
                          prefixIcon: Icons.school_outlined,
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Por favor, informe o nome da escola.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 28),

                      // Botão: Salvar Alterações
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton.icon(
                          onPressed: _isLoading ? null : _salvar,
                          icon: _isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.cloud_upload_outlined, color: Colors.white, size: 22),
                          label: Text(
                            _isLoading ? 'Sincronizando via API...' : 'Salvar Alterações',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _accentColor,
                            disabledBackgroundColor: _accentColor.withValues(alpha: 0.6),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Botão: Cancelar
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton.icon(
                          onPressed: _isLoading ? null : () => Navigator.pop(context),
                          icon: const Icon(Icons.close_rounded, color: Colors.white, size: 20),
                          label: const Text(
                            'Cancelar',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _cancelColor,
                            disabledBackgroundColor: _cancelColor.withValues(alpha: 0.6),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: _primaryTextColor,
      ),
    );
  }

  InputDecoration _buildInputDecoration({
    required String hintText,
    required IconData prefixIcon,
    Color fillColor = Colors.white,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(color: Color(0xFFA3988F), fontSize: 14),
      prefixIcon: Icon(prefixIcon, color: const Color(0xFF8D6E63), size: 20),
      filled: true,
      fillColor: fillColor,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: _borderColor, width: 1.2),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: _borderColor, width: 1.2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: _accentColor, width: 1.8),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: _cancelColor, width: 1.2),
      ),
    );
  }
}
