import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/utils/validators.dart';
import '../../data/models/invite_result_model.dart';
import '../../data/services/admin_api_service.dart';

const _backgroundColor = Color(0xFFF9F5EC);
const _primaryTextColor = Color(0xFF4A2525);
const _secondaryTextColor = Color(0xFF6B6B6B);
const _buttonGreen = Color(0xFFA1A32D);

class ConvidarProfessorScreen extends StatefulWidget {
  const ConvidarProfessorScreen({super.key});

  @override
  State<ConvidarProfessorScreen> createState() => _ConvidarProfessorScreenState();
}

class _ConvidarProfessorScreenState extends State<ConvidarProfessorScreen> {
  final TextEditingController _emailController = TextEditingController();
  late final AdminApiService _service;

  bool _sending = false;
  bool _created = false; // pelo menos um convite criado: a tela devolve `true` ao fechar
  String? _emailError;
  InviteResultModel? _invite; // não nulo = mostrando o resultado

  @override
  void initState() {
    super.initState();
    _service = context.read<AdminApiService>();
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  // --- Ações ----------------------------------------------------------------

  Future<void> _enviarConvite() async {
    if (_sending) return;

    final email = _emailController.text.trim();
    final validationError = FormValidators.validateEmail(email);
    if (validationError != null) {
      setState(() => _emailError = validationError);
      _showError(validationError);
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(
          'Confirmar Envio',
          style: TextStyle(color: _primaryTextColor, fontWeight: FontWeight.bold),
        ),
        content: Text('Deseja realmente enviar um convite para $email?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Não', style: TextStyle(color: Colors.red)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Sim',
              style: TextStyle(color: _buttonGreen, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() {
      _sending = true;
      _emailError = null;
    });
    try {
      final invite = await _service.createTeacher(email);
      if (!mounted) return;
      setState(() {
        _invite = invite;
        _created = true;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      if (e.code == 'EMAIL_ALREADY_REGISTERED') {
        setState(() => _emailError = 'Já existe uma conta com este e-mail.');
      }
      _showError(_messageFor(e));
    } catch (e, st) {
      debugPrint('Falha inesperada ao convidar professor: $e\n$st');
      if (!mounted) return;
      _showError('Ocorreu um erro inesperado. Tente novamente.');
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  void _convidarOutro() {
    setState(() {
      _invite = null;
      _emailError = null;
      _emailController.clear();
    });
  }

  Future<void> _copy(String label, String value) async {
    await Clipboard.setData(ClipboardData(text: value));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$label copiado.'), duration: const Duration(seconds: 2)),
    );
  }

  // --- Mensagens ------------------------------------------------------------

  String _messageFor(ApiException e) => switch (e.code) {
    'EMAIL_ALREADY_REGISTERED' => 'Já existe uma conta com este e-mail.',
    'VALIDATION_ERROR' => 'Confira o e-mail informado.',
    'FORBIDDEN' => 'Você não tem permissão para convidar professores.',
    'RATE_LIMITED' => 'Muitas tentativas. Aguarde um instante e tente de novo.',
  // POST não é idempotente: sem resposta, o convite pode ter sido criado.
    _ when e.isNetworkError =>
    '${e.message} O convite pode ter sido criado: confira a lista de professores antes de tentar de novo.',
    _ => e.message,
  };

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 5),
      ),
    );
  }

  String _formatExpiry(DateTime utc) {
    final d = utc.toLocal();
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(d.day)}/${two(d.month)}/${d.year} às ${two(d.hour)}:${two(d.minute)}';
  }

  // --- UI -------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final invite = _invite;

    return PopScope(
      // O botão voltar do sistema também devolve se algo foi criado.
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) Navigator.pop(context, _created);
      },
      child: Scaffold(
        backgroundColor: _backgroundColor,
        appBar: AppBar(
          backgroundColor: _backgroundColor,
          elevation: 0,
          leadingWidth: 100,
          leading: TextButton.icon(
            onPressed: () => Navigator.pop(context, _created),
            icon: const Icon(Icons.arrow_back, color: _primaryTextColor, size: 20),
            label: const Text('Voltar', style: TextStyle(color: _primaryTextColor, fontSize: 16)),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Convidar Professor',
                style: TextStyle(color: _primaryTextColor, fontSize: 24, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 12),
              const Text(
                'Envie um convite para que o educador possa acessar a plataforma.',
                style: TextStyle(color: _secondaryTextColor, fontSize: 16, height: 1.4),
              ),
              const SizedBox(height: 32),
              invite == null ? _buildForm() : _buildResult(invite),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildForm() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'E-mail Institucional',
            style: TextStyle(color: _primaryTextColor, fontSize: 14, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          TextField(
            key: const ValueKey('invite_email'),
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            autocorrect: false,
            enableSuggestions: false,
            onSubmitted: (_) => _enviarConvite(),
            onChanged: (_) {
              if (_emailError != null) setState(() => _emailError = null);
            },
            decoration: InputDecoration(
              hintText: 'Ex: maria.silva@escola.edu.br',
              errorText: _emailError,
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFD6D6D6)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFD6D6D6)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: _buttonGreen),
              ),
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _sending ? null : _enviarConvite,
              icon: _sending
                  ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
              )
                  : const Icon(Icons.send_outlined, color: Colors.white, size: 20),
              label: Text(
                _sending ? 'Enviando...' : 'Enviar Convite',
                style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _buttonGreen,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResult(InviteResultModel invite) {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
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
                    'Convite gerado para ${invite.email}. Se o e-mail não chegar, '
                        'envie o código ou o link abaixo por outro canal (ex.: WhatsApp).',
                    style: const TextStyle(color: Color(0xFF1B5E20), fontSize: 12.5, height: 1.35),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _copyField(
            label: 'Código do convite',
            value: invite.inviteCode,
            onCopy: () => _copy('Código', invite.inviteCode),
          ),
          const SizedBox(height: 16),
          _copyField(
            label: 'Link do convite',
            value: invite.inviteLink,
            onCopy: () => _copy('Link', invite.inviteLink),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.schedule, size: 16, color: _secondaryTextColor),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Válido até ${_formatExpiry(invite.inviteExpiresAt)}',
                  style: const TextStyle(color: _secondaryTextColor, fontSize: 12.5),
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context, _created),
              style: ElevatedButton.styleFrom(
                backgroundColor: _buttonGreen,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                elevation: 0,
              ),
              child: const Text(
                'Concluir',
                style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _convidarOutro,
              icon: const Icon(Icons.person_add_alt_1_outlined, color: _primaryTextColor, size: 18),
              label: const Text(
                'Convidar outro professor',
                style: TextStyle(color: _primaryTextColor, fontWeight: FontWeight.bold),
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: const BorderSide(color: Color(0xFFD6D6D6)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _copyField({
    required String label,
    required String value,
    required VoidCallback onCopy,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: _primaryTextColor, fontSize: 14, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.only(left: 14, top: 4, bottom: 4, right: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFD6D6D6)),
          ),
          child: Row(
            children: [
              Expanded(
                child: SelectableText(
                  value,
                  style: const TextStyle(color: _primaryTextColor, fontSize: 13, height: 1.3),
                ),
              ),
              IconButton(
                tooltip: 'Copiar',
                icon: const Icon(Icons.copy_rounded, size: 20, color: _buttonGreen),
                onPressed: onCopy,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: const Color(0xFFF3EFE4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEBE8E0)),
      ),
      child: child,
    );
  }
}