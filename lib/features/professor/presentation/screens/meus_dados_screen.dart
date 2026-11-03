import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../../core/network/api_exception.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../data/services/profile_api_service.dart';

class MeusDadosScreen extends StatefulWidget {
  const MeusDadosScreen({super.key});

  @override
  State<MeusDadosScreen> createState() => _MeusDadosScreenState();
}

class _MeusDadosScreenState extends State<MeusDadosScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nomeController;
  late final TextEditingController _emailController;
  late final TextEditingController _escolaController;

  // Valores atuais da conta: só o que mudou vai para a API.
  late final String _originalNome;
  late final String _originalEscola;

  bool _isLoading = false;

  /// Erros apontados pelo servidor, por campo (chave em snake_case do backend).
  final Map<String, String> _serverErrors = {};

  static const Color _bgColor = Color(0xFFF9F5EC);
  static const Color _primaryTextColor = Color(0xFF4A2525);
  static const Color _secondaryTextColor = Color(0xFF7A6B63);
  static const Color _accentColor = Color(0xFFA1A32D);
  static const Color _cancelColor = Color(0xFFDE5D5D);
  static const Color _borderColor = Color(0xFFE2DDD5);

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthController>().user;
    _originalNome = user?.fullName?.trim() ?? '';
    _originalEscola = user?.school?.trim() ?? '';
    _nomeController = TextEditingController(text: _originalNome);
    _emailController = TextEditingController(text: user?.email ?? '');
    _escolaController = TextEditingController(text: _originalEscola);
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _escolaController.dispose();
    super.dispose();
  }

  // --- Envio ----------------------------------------------------------------

  Future<void> _salvar() async {
    if (_isLoading) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final novoNome = _nomeController.text.trim();
    final novaEscola = _escolaController.text.trim();
    final nomeMudou = novoNome != _originalNome;
    final escolaMudou = novaEscola != _originalEscola;

    if (!nomeMudou && !escolaMudou) {
      Navigator.pop(context); // nada a salvar
      return;
    }

    // Tudo que depende do context é capturado antes do await.
    final auth = context.read<AuthController>();
    final service = context.read<ProfileApiService>();
    final messenger = ScaffoldMessenger.of(context);
    final nav = Navigator.of(context);

    setState(() {
      _isLoading = true;
      _serverErrors.clear();
    });

    try {
      final updated = await service.updateProfile(
        fullName: nomeMudou ? novoNome : null,
        school: escolaMudou ? novaEscola : null, // '' limpa a escola
      );

      // O perfil e o resto do app observam o AuthController e se atualizam sozinhos.
      auth.updateUser(updated);
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Informações atualizadas com sucesso!'),
          backgroundColor: _accentColor,
          duration: Duration(seconds: 3),
        ),
      );
      if (mounted) nav.pop();
    } on ApiException catch (e) {
      if (!mounted) return;
      final fields = e.fieldErrors;
      final hasFieldErrors = fields.containsKey('full_name') || fields.containsKey('school');

      if (hasFieldErrors) {
        // Mensagens próprias: as do servidor vêm em inglês.
        setState(() {
          if (fields.containsKey('full_name')) {
            _serverErrors['full_name'] = 'Informe um nome válido (até 255 caracteres).';
          }
          if (fields.containsKey('school')) {
            _serverErrors['school'] = 'A escola deve ter até 255 caracteres.';
          }
        });
        messenger.showSnackBar(
          const SnackBar(
            content: Text('Confira os campos destacados.'),
            backgroundColor: _cancelColor,
          ),
        );
      } else {
        await _mostrarFalha(_mensagemDe(e));
      }
    } catch (e, st) {
      debugPrint('Falha inesperada ao atualizar perfil: $e\n$st');
      if (!mounted) return;
      await _mostrarFalha('Ocorreu um erro inesperado. Tente novamente.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _mensagemDe(ApiException e) => switch (e.code) {
    'RATE_LIMITED' => 'Muitas tentativas. Aguarde um instante e tente de novo.',
  // PATCH é idempotente: repetir após falha de rede é seguro.
    _ when e.isNetworkError => '${e.message} Seus dados não foram alterados; tente novamente.',
    _ => e.message,
  };

  Future<void> _mostrarFalha(String message) {
    return showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Falha na Atualização',
          style: TextStyle(color: _cancelColor, fontWeight: FontWeight.bold),
        ),
        content: Text(message, style: const TextStyle(color: _secondaryTextColor)),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            style: ElevatedButton.styleFrom(backgroundColor: _cancelColor),
            child: const Text('OK', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // --- UI -------------------------------------------------------------------

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
                  'Atualize suas informações pessoais.',
                  style: TextStyle(fontSize: 14, color: _secondaryTextColor, height: 1.4),
                ),
                const SizedBox(height: 24),
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

                      // Nome completo
                      _buildFieldLabel('Nome Completo'),
                      const SizedBox(height: 8),
                      TextFormField(
                        key: const ValueKey('meus_dados_name'),
                        controller: _nomeController,
                        enabled: !_isLoading,
                        inputFormatters: [LengthLimitingTextInputFormatter(255)],
                        textCapitalization: TextCapitalization.words,
                        forceErrorText: _serverErrors['full_name'],
                        onChanged: (_) {
                          if (_serverErrors.containsKey('full_name')) {
                            setState(() => _serverErrors.remove('full_name'));
                          }
                        },
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

                      // E-mail (somente leitura)
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
                        child: const Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.info_outline_rounded, size: 18, color: Color(0xFF9E651E)),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'O e-mail é a identidade da sua conta e não pode ser alterado por aqui.',
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
                        readOnly: true, // selecionável, mas não editável
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: _secondaryTextColor,
                        ),
                        decoration: _buildInputDecoration(
                          hintText: 'seu.email@escola.com.br',
                          prefixIcon: Icons.email_outlined,
                          fillColor: const Color(0xFFF4F0E8),
                          suffixIcon: const Icon(Icons.lock_outline_rounded,
                              size: 18, color: Color(0xFFA3988F)),
                        ),
                      ),
                      const SizedBox(height: 18),

                      // Escola (opcional)
                      _buildFieldLabel('Escola/Instituição'),
                      const SizedBox(height: 8),
                      TextFormField(
                        key: const ValueKey('meus_dados_school'),
                        controller: _escolaController,
                        enabled: !_isLoading,
                        forceErrorText: _serverErrors['school'],
                        inputFormatters: [LengthLimitingTextInputFormatter(255)],
                        onChanged: (_) {
                          if (_serverErrors.containsKey('school')) {
                            setState(() => _serverErrors.remove('school'));
                          }
                        },
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: _primaryTextColor,
                        ),
                        decoration: _buildInputDecoration(
                          hintText: 'Nome da sua escola ou instituição (opcional)',
                          prefixIcon: Icons.school_outlined,
                        ),
                      ),
                      const SizedBox(height: 28),

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
                              : const Icon(Icons.save_outlined, color: Colors.white, size: 22),
                          label: Text(
                            _isLoading ? 'Salvando...' : 'Salvar Alterações',
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
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

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
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(color: Color(0xFFA3988F), fontSize: 14),
      prefixIcon: Icon(prefixIcon, color: const Color(0xFF8D6E63), size: 20),
      suffixIcon: suffixIcon,
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
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: _cancelColor, width: 1.8),
      ),
    );
  }
}