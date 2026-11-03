import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../../core/network/api_exception.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../data/services/invites_api_service.dart';

const _bgColor = Color(0xFFF9F5EC);
const _primaryText = Color(0xFF4A2525);
const _secondaryText = Color(0xFF6B6B6B);
const _accent = Color(0xFFA1A32D);
const _errorRed = Color(0xFFC62828);
const _borderColor = Color(0xFFD6D6D6);

class AcceptInviteScreen extends StatefulWidget {
  const AcceptInviteScreen({super.key, required this.token});

  /// Segredo de uso único: nunca logar nem persistir.
  final String token;

  @override
  State<AcceptInviteScreen> createState() => _AcceptInviteScreenState();
}

class _AcceptInviteScreenState extends State<AcceptInviteScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _schoolCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  late final InvitesApiService _service;

  String? _email; // vem do verify; read-only
  ApiException? _problem; // convite com problema (ou falha ao verificar)
  bool _verifying = true;
  bool _submitting = false;
  bool _attemptedAccept = false; // já houve tentativa de cadastro nesta tela
  bool _obscure = true;
  bool _obscureConfirm = true;
  bool _resending = false;
  bool _resendSent = false;

  /// Erros apontados pelo servidor, por campo (chave em snake_case do backend).
  final Map<String, String> _serverErrors = {};

  @override
  void initState() {
    super.initState();
    _service = context.read<InvitesApiService>();
    _verify();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _schoolCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  // --- Ações ----------------------------------------------------------------

  Future<void> _verify() async {
    setState(() {
      _verifying = true;
      _problem = null;
    });
    try {
      final email = await _service.verify(widget.token);
      if (!mounted) return;
      setState(() => _email = email);
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _problem = e);
    } catch (e, st) {
      debugPrint('Falha inesperada ao verificar convite: $e\n$st');
      if (!mounted) return;
      setState(() => _problem = ApiException.unexpected('$e'));
    } finally {
      if (mounted) setState(() => _verifying = false);
    }
  }

  Future<void> _submit() async {
    if (_submitting) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;

    // Tudo que depende do context é capturado antes do await.
    final auth = context.read<AuthController>();
    final nav = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    setState(() {
      _submitting = true;
      _serverErrors.clear();
    });
    _attemptedAccept = true;

    try {
      final user = await _service.accept(
        token: widget.token,
        fullName: _nameCtrl.text,
        school: _schoolCtrl.text,
        password: _passwordCtrl.text,
      );

      // O AuthGate passa a mostrar a área do professor; as rotas de convite/login
      // empilhadas por cima precisam sair.
      auth.adoptSession(user);
      nav.popUntil((r) => r.isFirst);
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Cadastro concluído! Bem-vindo(a) ao Colli Books.'),
          backgroundColor: _accent,
        ),
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      _onAcceptError(e);
    } catch (e, st) {
      debugPrint('Falha inesperada ao aceitar convite: $e\n$st');
      if (!mounted) return;
      _showError('Ocorreu um erro inesperado. Tente novamente.');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  void _onAcceptError(ApiException e) {
    switch (e.code) {
      case 'INVITE_INVALID' || 'INVITE_EXPIRED' || 'INVITE_ALREADY_USED':
        setState(() => _problem = e); // vira a tela de problema, com a ação certa
      case 'WEAK_PASSWORD':
        setState(() => _serverErrors['password'] = 'A senha deve ter entre 8 e 128 caracteres.');
      case 'VALIDATION_ERROR':
        final fields = e.fieldErrors; // mensagens próprias: as do servidor vêm em inglês
        setState(() {
          if (fields.containsKey('full_name')) {
            _serverErrors['full_name'] = 'Informe seu nome (até 255 caracteres).';
          }
          if (fields.containsKey('school')) {
            _serverErrors['school'] = 'A escola deve ter até 255 caracteres.';
          }
          if (fields.containsKey('password')) {
            _serverErrors['password'] = 'A senha deve ter entre 8 e 128 caracteres.';
          }
        });
        _showError('Confira os campos destacados.');
      case 'RATE_LIMITED':
        _showError('Muitas tentativas. Aguarde um instante e tente de novo.');
      default:
      // POST não é idempotente: sem resposta, o cadastro pode ter sido concluído.
        _showError(
          e.isNetworkError
              ? '${e.message} Se o cadastro chegou a ser concluído, tente entrar com seu e-mail e a senha que você definiu.'
              : e.message,
        );
    }
  }

  Future<void> _resend() async {
    if (_resending) return;
    setState(() => _resending = true);
    try {
      await _service.resend(widget.token);
      if (!mounted) return;
      setState(() => _resendSent = true);
    } on ApiException catch (e) {
      if (!mounted) return;
      _showError(
        e.code == 'RATE_LIMITED'
            ? 'Muitas tentativas. Aguarde um instante e tente de novo.'
            : e.message,
      );
    } catch (e, st) {
      debugPrint('Falha inesperada ao reenviar convite: $e\n$st');
      if (!mounted) return;
      _showError('Ocorreu um erro inesperado. Tente novamente.');
    } finally {
      if (mounted) setState(() => _resending = false);
    }
  }

  void _goToLogin() => Navigator.of(context).popUntil((r) => r.isFirst);

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: _errorRed,
        duration: const Duration(seconds: 5),
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
        leadingWidth: 100,
        leading: TextButton.icon(
          onPressed: _submitting ? null : () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: _primaryText, size: 20),
          label: const Text('Voltar', style: TextStyle(color: _primaryText, fontSize: 16)),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_verifying) {
      return const Padding(
        padding: EdgeInsets.all(48),
        child: Center(child: CircularProgressIndicator(color: _accent)),
      );
    }
    final problem = _problem;
    if (problem != null) return _buildProblem(problem);
    return _buildForm();
  }

  Widget _card(Widget child) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(24.0),
    decoration: BoxDecoration(
      color: const Color(0xFFF3EFE4),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: const Color(0xFFEBE8E0)),
    ),
    child: child,
  );

  // --- Convite com problema ---------------------------------------------------

  Widget _buildProblem(ApiException e) {
    final (IconData icon, String title, String body) = switch (e.code) {
      'INVITE_EXPIRED' => (
      Icons.schedule,
      'Convite expirado',
      'Este convite passou do prazo de validade. Podemos enviar um novo link para o e-mail cadastrado.',
      ),
      'INVITE_ALREADY_USED' => (
      Icons.check_circle_outline,
      'Convite já utilizado',
      _attemptedAccept
          ? 'Seu cadastro pode já ter sido concluído (a conexão pode ter caído antes da confirmação). '
          'Tente entrar com o e-mail e a senha que você definiu.'
          : 'Este convite já foi utilizado e a conta já está ativa. Entre com seu e-mail e senha; '
          'se esqueceu a senha, use "Esqueci minha senha" na tela de entrada.',
      ),
      'INVITE_INVALID' => (
      Icons.link_off,
      'Convite inválido',
      'Este convite não existe ou foi cancelado (um convite mais recente substitui o anterior). '
          'Confira o código ou peça um novo à editora.',
      ),
      'RATE_LIMITED' => (
      Icons.hourglass_top,
      'Muitas tentativas',
      'Aguarde um instante e tente de novo.',
      ),
      _ when e.isNetworkError => (Icons.wifi_off, 'Sem conexão', e.message),
      _ => (Icons.error_outline, 'Algo deu errado', e.message),
    };

    final Widget action = switch (e.code) {
      'INVITE_EXPIRED' => _resendSent
          ? _infoBox(
        'Se este convite estiver expirado, enviamos um novo link para o e-mail cadastrado. '
            'Confira sua caixa de entrada (e o spam).',
      )
          : _primaryButton(
        label: _resending ? 'Enviando...' : 'Enviar novo convite',
        icon: Icons.forward_to_inbox_outlined,
        onPressed: _resending ? null : _resend,
      ),
      'INVITE_ALREADY_USED' =>
          _primaryButton(label: 'Ir para o login', icon: Icons.login, onPressed: _goToLogin),
      'INVITE_INVALID' => _primaryButton(
        label: 'Voltar',
        icon: Icons.arrow_back,
        onPressed: () => Navigator.pop(context),
      ),
      _ => _primaryButton(label: 'Tentar de novo', icon: Icons.refresh, onPressed: _verify),
    };

    return _card(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 40, color: _accent),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(color: _primaryText, fontSize: 22, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 10),
          Text(body, style: const TextStyle(color: _secondaryText, fontSize: 15, height: 1.45)),
          const SizedBox(height: 24),
          action,
        ],
      ),
    );
  }

  Widget _infoBox(String text) => Container(
    width: double.infinity,
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
            text,
            style: const TextStyle(color: Color(0xFF1B5E20), fontSize: 12.5, height: 1.35),
          ),
        ),
      ],
    ),
  );

  Widget _primaryButton({
    required String label,
    required IconData icon,
    required VoidCallback? onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, color: Colors.white, size: 20),
        label: Text(
          label,
          style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: _accent,
          disabledBackgroundColor: _accent.withValues(alpha: 0.6),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 0,
        ),
      ),
    );
  }

  // --- Formulário -----------------------------------------------------------

  Widget _buildForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Complete seu cadastro',
          style: TextStyle(color: _primaryText, fontSize: 24, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 12),
        const Text(
          'Você foi convidado(a) para o portal Colli Books. Informe seus dados e defina uma senha para entrar.',
          style: TextStyle(color: _secondaryText, fontSize: 16, height: 1.4),
        ),
        const SizedBox(height: 28),
        Form(
          key: _formKey,
          child: AutofillGroup(
            child: _card(
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _label('E-mail do convite'),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF4F0E8),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: _borderColor),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.email_outlined, size: 20, color: Color(0xFF8D6E63)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: SelectableText(
                            _email ?? '',
                            style: const TextStyle(
                              color: _secondaryText,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const Icon(Icons.lock_outline_rounded, size: 18, color: Color(0xFFA3988F)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  _label('Nome completo'),
                  const SizedBox(height: 8),
                  _field(
                    controller: _nameCtrl,
                    icon: Icons.person_outline_rounded,
                    hint: 'Seu nome completo',
                    errorKey: 'full_name',
                    capitalization: TextCapitalization.words,
                    autofillHints: const [AutofillHints.name],
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Por favor, informe seu nome completo.'
                        : null,
                  ),
                  const SizedBox(height: 18),
                  _label('Escola/Instituição (opcional)'),
                  const SizedBox(height: 8),
                  _field(
                    controller: _schoolCtrl,
                    icon: Icons.school_outlined,
                    hint: 'Nome da sua escola ou instituição',
                    errorKey: 'school',
                  ),
                  const SizedBox(height: 18),
                  _label('Senha'),
                  const SizedBox(height: 8),
                  _field(
                    controller: _passwordCtrl,
                    icon: Icons.lock_outline,
                    hint: 'Mínimo de 8 caracteres',
                    errorKey: 'password',
                    maxLength: 128,
                    obscure: _obscure,
                    onToggleObscure: () => setState(() => _obscure = !_obscure),
                    autofillHints: const [AutofillHints.newPassword],
                    validator: (v) =>
                    (v == null || v.length < 8) ? 'A senha deve ter no mínimo 8 caracteres.' : null,
                  ),
                  const SizedBox(height: 18),
                  _label('Confirmar senha'),
                  const SizedBox(height: 8),
                  _field(
                    controller: _confirmCtrl,
                    icon: Icons.lock_reset,
                    hint: 'Repita a senha',
                    maxLength: 128,
                    obscure: _obscureConfirm,
                    onToggleObscure: () => setState(() => _obscureConfirm = !_obscureConfirm),
                    autofillHints: const [AutofillHints.newPassword],
                    action: TextInputAction.done,
                    onSubmitted: (_) => _submit(),
                    validator: (v) => v != _passwordCtrl.text ? 'As senhas não coincidem.' : null,
                  ),
                  const SizedBox(height: 28),
                  _primaryButton(
                    label: _submitting ? 'Concluindo...' : 'Concluir Cadastro',
                    icon: Icons.check_circle_outline,
                    onPressed: _submitting ? null : _submit,
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _label(String text) => Text(
    text,
    style: const TextStyle(color: _primaryText, fontSize: 14, fontWeight: FontWeight.w700),
  );

  Widget _field({
    required TextEditingController controller,
    required IconData icon,
    required String hint,
    String? errorKey,
    String? Function(String?)? validator,
    bool obscure = false,
    VoidCallback? onToggleObscure,
    Iterable<String>? autofillHints,
    TextCapitalization capitalization = TextCapitalization.none,
    int maxLength = 255,
    TextInputAction action = TextInputAction.next,
    ValueChanged<String>? onSubmitted,
    String? testKey,
  }) {
    return TextFormField(
      key: testKey == null ? null : ValueKey(testKey),
      controller: controller,
      enabled: !_submitting,
      obscureText: obscure,
      autocorrect: !obscure,
      enableSuggestions: !obscure,
      textCapitalization: capitalization,
      textInputAction: action,
      autofillHints: autofillHints,
      inputFormatters: [LengthLimitingTextInputFormatter(maxLength)],
      validator: validator,
      onFieldSubmitted: onSubmitted,
      // forceErrorText (e não errorText do decoration): o TextFormField sobrescreve
      // o errorText do decoration com o erro do próprio validator.
      forceErrorText: errorKey == null ? null : _serverErrors[errorKey],
      onChanged: (_) {
        if (errorKey != null && _serverErrors.containsKey(errorKey)) {
          setState(() => _serverErrors.remove(errorKey));
        }
      },
      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: _primaryText),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFFA3988F), fontSize: 14),
        prefixIcon: Icon(icon, color: const Color(0xFF8D6E63), size: 20),
        suffixIcon: onToggleObscure == null
            ? null
            : IconButton(
          icon: Icon(
            obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
            color: Colors.grey,
          ),
          onPressed: onToggleObscure,
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: _borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: _borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: _accent, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: _errorRed),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: _errorRed, width: 1.5),
        ),
      ),
    );
  }
}