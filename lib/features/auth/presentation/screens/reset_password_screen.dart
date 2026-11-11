import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/utils/validators.dart';
import '../../data/services/auth_api_service.dart';

const _bgColor = Color(0xFFF9F5EC);
const _primaryText = Color(0xFF4A2525);
const _secondaryText = Color(0xFF6B6B6B);
const _accent = Color(0xFFA1A32D);
const _errorRed = Color(0xFFC62828);

/// Aberta pelo link `collibooks://redefinir-senha?token=...` do e-mail (US04, US06).
class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key, required this.token});

  /// Segredo de uso único: nunca logar nem persistir.
  final String token;

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  bool _submitting = false;
  bool _obscure = true;
  bool _invalidLink = false;

  @override
  void dispose() {
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_submitting) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final service = context.read<AuthApiService>();
    final nav = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    setState(() => _submitting = true);
    try {
      await service.resetPassword(
        token: widget.token,
        newPassword: _passwordCtrl.text,
      );
      nav.popUntil((r) => r.isFirst);
      messenger.showSnackBar(
        const SnackBar(
          content: Text(
            'Senha redefinida com sucesso! Você já pode entrar com sua nova senha.',
          ),
          backgroundColor: _accent,
        ),
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      if (e.code == 'RESET_TOKEN_INVALID') {
        setState(() => _invalidLink = true);
        return;
      }
      _showError(switch (e.code) {
        'WEAK_PASSWORD' => 'A senha deve ter entre 8 e 128 caracteres.',
        'RATE_LIMITED' =>
          'Muitas tentativas. Aguarde um instante e tente de novo.',
        _ => e.message,
      });
    } catch (e, st) {
      debugPrint('Falha inesperada no reset-password: $e\n$st');
      if (!mounted) return;
      _showError('Ocorreu um erro inesperado. Tente novamente.');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: _errorRed,
        duration: const Duration(seconds: 5),
      ),
    );
  }

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
          label: const Text(
            'Voltar',
            style: TextStyle(color: _primaryText, fontSize: 16),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24.0),
              decoration: BoxDecoration(
                color: const Color(0xFFF3EFE4),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFEBE8E0)),
              ),
              child: _invalidLink ? _buildInvalid() : _buildForm(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _title(String text) => Text(
    text,
    style: const TextStyle(
      color: _primaryText,
      fontSize: 22,
      fontWeight: FontWeight.w800,
    ),
  );

  Widget _body(String text) => Text(
    text,
    style: const TextStyle(color: _secondaryText, fontSize: 15, height: 1.45),
  );

  Widget _button({required String label, required VoidCallback? onPressed}) =>
      SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: _accent,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: Text(
            label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
        ),
      );

  Widget _buildInvalid() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Icon(Icons.link_off, size: 40, color: _accent),
      const SizedBox(height: 16),
      _title('Link inválido ou expirado'),
      const SizedBox(height: 10),
      _body(
        'Este link de redefinição já foi usado ou passou do prazo. '
        'Na tela de entrada, use "Esqueci minha senha" para receber um novo.',
      ),
      const SizedBox(height: 24),
      _button(
        label: 'Ir para o login',
        onPressed: () => Navigator.of(context).popUntil((r) => r.isFirst),
      ),
    ],
  );

  Widget _buildForm() => Form(
    key: _formKey,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _title('Redefinir senha'),
        const SizedBox(height: 10),
        _body(
          'Crie uma nova senha para sua conta. Depois, entre com ela no app.',
        ),
        const SizedBox(height: 24),
        TextFormField(
          key: const Key('reset_new_password'),
          controller: _passwordCtrl,
          obscureText: _obscure,
          autofillHints: const [AutofillHints.newPassword],
          validator: FormValidators.validatePassword,
          decoration: InputDecoration(
            labelText: 'Nova senha',
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            suffixIcon: IconButton(
              tooltip: _obscure ? 'Mostrar senha' : 'Ocultar senha',
              icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility),
              onPressed: () => setState(() => _obscure = !_obscure),
            ),
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          key: const Key('reset_confirm_password'),
          controller: _confirmCtrl,
          obscureText: _obscure,
          validator: (v) =>
              v != _passwordCtrl.text ? 'As senhas não conferem.' : null,
          decoration: InputDecoration(
            labelText: 'Confirme a nova senha',
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
          onFieldSubmitted: (_) => _submit(),
        ),
        const SizedBox(height: 24),
        _button(
          label: _submitting ? 'Salvando...' : 'Salvar nova senha',
          onPressed: _submitting ? null : _submit,
        ),
      ],
    ),
  );
}
